import tables, uri
import strutils, net

type Request* = object
    httpMethod*: string
    uri*: Uri
    host*, hostPort*: string
    headers*: TableRef[string, string]

proc newRequest*(): Request =
    result = Request()

proc parsePort*(url: string): string =
    var rawUrl = url
    if rawUrl.startsWith("http://"):
        rawUrl = rawUrl[7..^1]
    let port_position = rawUrl.find(":")
    result = ""
    if port_position != -1:
        result = url[port_position + 1 .. ^1]

proc parseAdress*(url: string): string =
    result = url
    if result.startsWith("http://"):
        result = result[7..^1]
    let port_position = result.find(":")
    if port_position != -1:
        result = url[0..(port_position-1)]

proc parseRequest*(data: string): Request =
    result = newRequest()
    let splited = data.split("\n")
    let first_line = splited[0].split(" ")
    result.httpMethod = first_line[0]
    result.uri = parseUri(first_line[1])
    result.headers =  newTable[string, string]()
    
    for line in splited[1..^1]:
        if not line.contains(":"):
            break
        let pair = line.split(":")
        result.headers[pair[0].strip()] = join(pair[1..^1], ":").strip()
    
    result.host = parseAdress(result.headers["Host"])
    result.hostPort = parsePort(result.headers["Host"])
    # if result.headers["Host"].contains(":"):
    #     result.host.port = result.headers["Host"].split(":")[1]
