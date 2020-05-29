# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.
import argparse
import server, net, asyncdispatch, os, strformat


var p = newParser("proxy server"):
    help("Reversed http proxy server. Tested methods: GET, POST, CONNECT")
    flag("-b", "--ban-list", help="exec proxy server with ban list")
    flag("-c", "--config", help="set settings from 'config.yaml'")
    arg("address", default="127.0.0.1",help="IPv4 of proxy server address")
    arg("port", default="8080", help="port of proxy server")
    run:
        let port = parseUint(opts.port).Port
        let fname = "config.yaml"
        
        var proxyOptions = emptyOptions()

        if opts.config:
            if fileExists(fname):
                proxyOptions = optionsFromFile(fname)
                echo "Found config:"
                echo fmt"    file {fname}"
                echo fmt"    with {proxyOptions.banAddresses.len} banned addresses."
            else:
                echo fmt"Can't find {fname}"
                return

        var proxy = newProxyServer(opts.address, port, proxyOptions)

        try:
            proxy.init()
        except OSError:
            echo fmt"Can't bind address {opts.address}:{port}"
            return

        asyncCheck proxy.serve()
        runForever()


when isMainModule: 
    try:
        p.run(commandLineParams())  
    except Exception:
        echo p.help
        echo getCurrentException().msg
