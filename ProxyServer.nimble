# Package

version       = "0.1.0"
author        = "w1jtoo"
description   = "http reverse proxy"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["ProxyServer"]



# Dependencies

requires "nim >= 1.2.0"
requires "argparse >= 0.10.1"
requires "yaml"
