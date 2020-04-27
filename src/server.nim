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
    var port = Port(80) # default http port is 80
    
    if request.httpMethod == "CONNECT":
        port = Port(443)

    if request.hostPort != "":
        port = Port((uint16) parseInt(request.hostPort))

    let socket = newAsyncSocket(buffered=false)
    
    try:
        await socket.connect(request.host, port)
    except: 
        echo fmt"[{request.httpMethod}] [{port}] {request.host} - can't connct"
        echo data
        await client.send("HTTP/1.1 404 NOT FOUND")
        socket.close()
        return
    
    echo fmt"[{request.httpMethod}] [{port}] {$request.host}"

    if request.httpMethod == "CONNECT":
        # RFC says that it is not nesseccery to accept the client connection 
        await client.send("HTTP/1.1 200 Connection established\n\r\n\r")
        # await socket.send("HTTP/1.1 200 Connection established\n\r\n\r")
        
        var connectData: string
        var response: string
        
        while not socket.isClosed and not client.isClosed:
            connectData = await readDataFromSocket(client)
            await socket.send(connectData)
            response = await readDataFromSocket(socket)
            await client.send(response)
            if response.len() == 0 or connectData.len() == 0:
                break


        # # if client or server closed closed connecntion with not served data then send it 
        if not socket.isClosed and connectData.len() != 0:
            let connectData = await readDataFromSocket(client)
            await socket.send(connectData)

        if not client.isClosed and response.len() != 0:
            let connectData = await readDataFromSocket(socket)
            await client.send(connectData)
        
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
        if not client.isClosed:
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
