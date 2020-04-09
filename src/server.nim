import net, asyncdispatch, asyncnet, strutils, lists, strformat

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
    let data = await socket.recv(1024)
    result.add(data) 
        # if data.len == 0:
        #     break

proc processClient(this: ref ProxyServer, client: AsyncSocket) {.async.} =
    proc clientHasData() {.async.} =
        var s = newAsyncSocket()
        var data = await readDataFromSocket(client)
        let line = data.split("\n")[0]
        echo "got data:" & data


        let webserver = parseAdress(line)
        let port = parsePort(line)
        echo webserver
        echo port
        await s.connect(webserver, Port(port))
        
        await s.send(data)

        echo fmt"sent data to {webserver} with port {port}"

        while true:
            let data = await s.recv(1024)
            if data.len > 0:
                await client.send(data)
            else:
                break

            # await client.send(response)
        s.close()
        client.close()


    try:
        asyncCheck clientHasData()
    except:
        echo getCurrentExceptionMsg()


proc serve*(this: ref ProxyServer) {.async.} =
    var server = newAsyncSocket(buffered=true)
    server.setSockOpt(OptReuseAddr, true)
    server.bindAddr(this.options.listenPort, this.options.listenAddr)
    echo fmt"Started proxy server {this.options.listenAddr}:{this.options.listenPort} "
    server.listen()

    while true:
        let client = await server.accept()
        echo "Got connection"
        asyncCheck this.processClient(client)
