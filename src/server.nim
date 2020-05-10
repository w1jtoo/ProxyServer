import asyncdispatch, asyncnet, strutils, strformat
import net, httprequets

type ProxyServerOptions* = object
    listenAddr*: string
    listenPort*: Port

type ProxyServer = object of RootObj
    options*: ProxyServerOptions
    server: AsyncSocket

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

proc processHttpMethod(data: string, request: Request, client: AsyncSocket) {.async.} =
    var port = Port(80) # default http port is 80
    
    if request.httpMethod == "CONNECT":
        port = Port(443) # tls/ssl port

    if request.hostPort != "":
        port = Port((uint16) parseInt(request.hostPort))

    let socket = newAsyncSocket(buffered=false)
    
    try:
        await socket.connect(request.host, port)
    except: 
        echo fmt"[{request.httpMethod}] [{port}] {request.host} - can't connct"
        echo data
        await client.send(fmt"{request.httpVersion} 404 NOT FOUND\r\n\r\n")
        socket.close()
        return
    
    echo fmt"[{request.httpMethod}] [{port}] {$request.host}"

    if request.httpMethod == "CONNECT":
        # serve CONNECT method 
        # RFC says that it is not nesseccery to accept the client connection 
        await client.send("{request.httpVersion} 200 Connection established\r\n\r\n")
        
        var connectData: string
        var response: string
        
        # tunneling
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
        
        echo fmt"{$request.host} - served"
    
    else:
        # serve other methods
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

proc init*(this: ref ProxyServer) = 
    this.server = newAsyncSocket(buffered=false)
    this.server.setSockOpt(OptReuseAddr, true)
    this.server.bindAddr(this.options.listenPort, this.options.listenAddr)


proc serve*(this: ref ProxyServer) {.async.} =
    echo fmt"Started proxy server on {this.options.listenAddr}:{this.options.listenPort} "
    this.server.listen()

    while true:
        let client = await this.server.accept()
        asyncCheck this.processClient(client)
