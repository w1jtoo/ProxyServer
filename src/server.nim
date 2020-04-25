import asyncdispatch, asyncnet, strutils, uri, strformat
import net, httprequets

type ProxyServerOptions* = object
    listenAddr*: string
    listenPort*: Port

type ProxyServer = object of RootObj
    options*: ProxyServerOptions

proc newProxyServer* (opts: ProxyServerOptions): ref ProxyServer =
    result = new(ProxyServer)
    result.options = opts

proc parsePort*(line: string): int16 =
    var url = line.split(' ')[1]
    if url.startsWith("http://"):
        url = url[7..^1]
    let port_position = url.find(":")
    if port_position == -1: 
        result = 80
    else: 
        result = (int16) parseInt(url[port_position + 1 .. ^1]) 


proc parseAdress*(line: string): string =
    result = line.split(' ')[1].strip()
    if result.startsWith("http://"):
        result = result[7..^1]

    let port_pos = result.find(":") # find the port pos (if any)
    if port_pos != -1: 
        result = result[0..port_pos-1]
    
    if result.endsWith("/"):
        result = result[0..^2]

proc readDataFromSocket(socket: AsyncSocket): Future[string] {.async.} =
    ## Reads socket stored data into one string  
    var data = await socket.recv(512)
    result.add(data) 
    while data.len == 512:
        data = await socket.recv(512)
        result.add(data) 


proc processConnectMethod(data: string, request: Request, client: AsyncSocket) {.async.} =
    echo "can't process CONNECT method" 

proc processHttpMethod(data: string, request: Request, client: AsyncSocket) {.async.} =
    if request.httpMethod == "CONNECT":
        await processConnectMethod(data, request, client)
    else:
        let socket = newAsyncSocket(buffered=false)
        
        var port = Port(8080)
        if request.host.port != "":
            port = Port((int16) parseInt(request.host.port))
        
        echo "http://" & $request.host
        await socket.connect($request.host, port)
        await socket.send(data)
        let response = await readDataFromSocket(socket)
        await client.send(response)
        socket.close()


proc processClient(this: ref ProxyServer, client: AsyncSocket) {.async.} =
    proc clientHasData() {.async.} =
        # read data from client socket 
        let data = await readDataFromSocket(client)
        var request = newRequest()
        try: 
            request = parseRequest(data)
        except:
            echo "can't parse packet" 
        
        await processHttpMethod(data, request, client)
        client.close()

    try:
        echo "Got connection"
        asyncCheck clientHasData()
    except:
        echo getCurrentExceptionMsg()
    finally: 
        echo "Connection closed"


proc serve*(this: ref ProxyServer) {.async.} =
    var server = newAsyncSocket(buffered=false)
    server.setSockOpt(OptReuseAddr, true)
    server.bindAddr(this.options.listenPort, this.options.listenAddr)
    echo fmt"Started proxy server {this.options.listenAddr}:{this.options.listenPort} "
    server.listen()

    while true:
        let client = await server.accept()
        asyncCheck this.processClient(client)
