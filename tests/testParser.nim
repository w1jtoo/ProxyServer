# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import ../src/httprequets
import uri

test "Complite packet parser test":
    let request = """CONNECT ekt1.companion.tele2.ru.prod.hosts.ooklaserver.net:8080 HTTP/1.1
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:75.0) Gecko/20100101 Firefox/75.0
Proxy-Connection: keep-alive
Connection: keep-alive
Host: ekt1.companion.tele2.ru.prod.hosts.ooklaserver.net:8080
""" 
    let parsed = parseRequest(request)
    check parsed.host == "ekt1.companion.tele2.ru.prod.hosts.ooklaserver.net"
    check parsed.hostPort == "8080"
    check parsed.httpMethod == "CONNECT"
    check $parsed.uri == "ekt1.companion.tele2.ru.prod.hosts.ooklaserver.net:8080"
    check parsed.httpVersion == "HTTP/1.1"
