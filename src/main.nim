# import server, net, asyncdispatch


import asynchttpserver, asyncdispatch, httpclient, uri, httpcore, strutils

proc pp(req: Request) {.async.} =
    echo req.url
    echo $req.reqMethod
    var client = newHttpClient(timeout = 10000)
    let response = client.request($req.url, $req.reqMethod)
    echo response.status
    await req.respond(HttpCode(parseInt(response.status[0..2])), response.body)
    client.close()

when isMainModule: 
    # let opts = ProxyServerOptions(listenAddr:"127.0.0.1", listenPort:8088.Port)
    # var f = newProxyServer(opts)
    # asyncCheck f.serve()
    # runForever()
    
    
    proc cb(req: Request) {.async.} =
        try:
            await pp(req)
        except:
            echo getCurrentException().msg

    var server = newAsyncHttpServer() 
    
    asyncCheck server.serve(Port(8088), cb)
    runForever()
