import server, net, asyncdispatch


# import asynchttpserver, asyncdispatch, httpclient, uri


when isMainModule: 
    let opts = ProxyServerOptions(listenAddr:"127.0.0.1", listenPort:8088.Port)
    var f = newProxyServer(opts)
    asyncCheck f.serve()
    runForever()
    
    
    # proc cb(req: Request) {.async.} =
    #     echo req
    #     if req.reqMethod == HttpGet:
    #         var client = newHttpClient()
    #         let content =  client.getContent($req.url)
    #         await req.respond(Http200, content)

    # var server = newAsyncHttpServer() 
    
    # asyncCheck server.serve(Port(8088), cb)
    # runForever()
