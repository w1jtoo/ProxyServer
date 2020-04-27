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


proc processConnectMethod(data: string, client: AsyncSocket, sendClient: AsyncSocket) {.async.} =
    echo "can't process CONNECT method" 

proc processHttpMethod(data: string, request: Request, client: AsyncSocket) {.async.} =
    var port = Port(80) # default port due to RFC is 80
    if request.host.port != "":
        port = Port((int16) parseInt(request.host.port))

    let socket = newAsyncSocket(buffered=false)
    
    try:
        await socket.connect($request.host, port)
    except: 
        echo fmt"[{request.httpMethod}] {$request.host} - can't connct"
        echo data
        await client.send("HTTP/1.1 404 NOT FOUND")
        socket.close()
        return
    

    echo fmt"[{request.httpMethod}] {$request.host}"

    if request.httpMethod == "CONNECT":
        echo "GOT CONNECT"
        echo data
        # RFC says that it is not nesseccery to accept the client connection 
        await client.send("HTTP/1.1 200 Connection established\n\r\n\r")
        # await socket.send("HTTP/1.1 200 Connection established\n\r\n\r")
        
        while not socket.isClosed and not client.isClosed:
            let connectData = await readDataFromSocket(client)
            #echo connectData
            await socket.send(connectData)
            let response = await readDataFromSocket(socket)
            #echo response
            await client.send(response)
            

            echo connectData
            echo response
            if connectData.len() == 0:
                client.close()

            if response.len() == 0:
                socket.close()

        # # if client or server closed closed connecntion with not served data then send it 
        # if not socket.isClosed:
        #     let connectData = await readDataFromSocket(client)
        #     await socket.send(connectData)

        # if not client.isClosed:
        #     let connectData = await readDataFromSocket(socket)
        #     await client.send(connectData)
        
        echo fmt"[{request.httpMethod}] {$request.host} - served"
    
    else:
        await socket.send(data)
        let response = await readDataFromSocket(socket)
        await client.send(response)
    
    if not socket.isClosed:
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
        asyncCheck clientHasData()
    except:
        echo getCurrentExceptionMsg()


proc serve*(this: ref ProxyServer) {.async.} =
    var server = newAsyncSocket(buffered=false)
    server.setSockOpt(OptReuseAddr, true)
    server.bindAddr(this.options.listenPort, this.options.listenAddr)
    echo fmt"Started proxy server {this.options.listenAddr}:{this.options.listenPort} "
    server.listen()

    while true:
        let client = await server.accept()
        asyncCheck this.processClient(client)
