import tables, uri
import strutils, net

type Request* = object
    httpMethod*: string
    uri*, host*: Uri
    headers*: TableRef[string, string]

proc newRequest*(): Request =
    result = Request()

proc parseRequest*(data: string): Request =
    result = newRequest()
    let splited = data.split("\n")
    let first_line = splited[0].split(" ")
    result.httpMethod = first_line[0]
    result.uri = parseUri(first_line[1])
    result.headers =  newTable[string, string]()
    
    for line in splited:
        if line == "":
            break

        if not line.contains(":"):
            continue
        
        let pair = line.split(":")
        result.headers[pair[0].strip()] = pair[1].strip()
    result.host = parseUri(result.headers["Host"])