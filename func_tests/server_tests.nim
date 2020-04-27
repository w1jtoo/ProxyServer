import ../src/httprequets
import uri

when isMainModule: 
    # request tests
    let request = """CONNECT ekt1.companion.tele2.ru.prod.hosts.ooklaserver.net:8080 HTTP/1.1
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:75.0) Gecko/20100101 Firefox/75.0
Proxy-Connection: keep-alive
Connection: keep-alive
Host: ekt1.companion.tele2.ru.prod.hosts.ooklaserver.net:8080
""" 
    let parsed = parseRequest(request)
    doAssert parsed.host == "ekt1.companion.tele2.ru.prod.hosts.ooklaserver.net", parsed.host
    doAssert parsed.hostPort == "8080"
    doAssert parsed.httpMethod == "CONNECT"
    doAssert $parsed.uri == "ekt1.companion.tele2.ru.prod.hosts.ooklaserver.net:8080"
    # doAssert parsed.headers["Connection"] == "keep-alive"

