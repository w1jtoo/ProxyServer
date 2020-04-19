import server, net, asyncdispatch

when isMainModule: 
    let opts = ProxyServerOptions(listenAddr:"127.0.0.1", listenPort:8088.Port)
    var f = newProxyServer(opts)
    asyncCheck f.serve()
    runForever()
