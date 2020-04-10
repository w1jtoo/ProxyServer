# import server, net, asyncdispatch


import asynchttpserver, asyncdispatch, httpclient, uri, httpcore


when isMainModule: 
    # let opts = ProxyServerOptions(listenAddr:"127.0.0.1", listenPort:8088.Port)
    # var f = newProxyServer(opts)
    # asyncCheck f.serve()
    # runForever()
    
    
    proc cb(req: Request) {.async.} =
        var client = newHttpClient()
        echo req.url
        echo $req.reqMethod
        let response = client.request($req.url, $req.reqMethod)
        echo response.body
        echo response.headers
        await req.respond(Http200, response.body)

    var server = newAsyncHttpServer() 
    
    asyncCheck server.serve(Port(8088), cb)
    runForever()
