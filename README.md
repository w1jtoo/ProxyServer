# proxy-server

[Reverse](https://en.wikipedia.org/wiki/Reverse_proxy) HTTP proxy server written in [nim](https://github.com/nim-lang/Nim). Made due to Internet Protocols course in second year study of Institute of Mathematics and Mechanics UrFU.

Work on: Linux, Windows.

![Review](pics/preview.png)

## Download

Download binaries from [github release page](https://github.com/w1jtoo/ProxyServer/releases).

## Build

Proxy can be easy compiled by python build script:

```zsh
git clone https://github.com/w1jtoo/ProxyServer
cd ProxyServer
py build.py
```

Using only nim packet manager:

``` zsh
nimble build
```

## Getting started

Run proxy with IP 127.0.0.1 and port 25580:

```zsh
./ProxyServer 127.0.0.1 25580
```

Or just run proxy using default params:

```zsh
./ProxyServer
```

## Configuration

Run with configuration file using _--config_ run option:

```zsh
./ProxyServer --config
```

Now config.yaml should be in same dir as executable file.

Fields:

- banAddresses - contains list of addresses that proxy will not serve.
