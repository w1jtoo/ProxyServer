import ../src/server

when isMainModule: 
    # adress tests
    doAssert parseAdress("CONNECT ws.mmstat.com:443 HTTP/1.1") == "ws.mmstat.com", parseAdress("CONNECT ws.mmstat.com:443 HTTP/1.1")
    doAssert parseAdress("GET http://ws.mmstat.com HTTP/1.1") == "ws.mmstat.com",parseAdress("GET http://ws.mmstat.com HTTP/1.1")
    doAssert parseAdress("GET http://ws.mmstat.com/ HTTP/1.1") == "ws.mmstat.com", parseAdress("GET http://ws.mmstat.com/ HTTP/1.1")

    # adress tests
    doAssert parsePort("CONNECT ws.mmstat.com:443 HTTP/1.1") == 443, $parsePort("CONNECT ws.mmstat.com:443 HTTP/1.1")
    doAssert parsePort("GET http://univer2005-73.narod.ru/ HTTP/1.1") == 80, $parsePort("GET http://univer2005-73.narod.ru/ HTTP/1.1")
    doAssert parsePort("POST http://ocsp.pki.goog/gts1o1 HTTP/1.1") == 80, $parsePort("POST http://ocsp.pki.goog/gts1o1 HTTP/1.1")