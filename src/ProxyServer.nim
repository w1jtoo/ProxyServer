# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.
import argparse
import server, net, asyncdispatch, os, strformat


var p = newParser("proxy server"):
    help("Reversed http proxy server. Tested methods: GET, POST, CONNECT")
    flag("-b", "--ban-list", help="exec proxy server with ban list")
    arg("address", default="127.0.0.1",help="IPv4 of proxy server address")
    arg("port", default="8080", help="port of proxy server")
    run:
        let port = parseInt(opts.port).Port
        let options = ProxyServerOptions(listenAddr:opts.address, listenPort:port)
        var proxy = newProxyServer(options)
        
        try:
          proxy.init()
        except OSError:
          echo fmt"Can't bind address {options.listenAddr}:{options.listenPort}"
          return
      
        asyncCheck proxy.serve()
        runForever()


when isMainModule: 
    try:
        p.run(commandLineParams())  
    except Exception:
        echo p.help
        echo getCurrentException().msg