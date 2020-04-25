import requests
import os
from sys import platform, executable, stdout
from subprocess import Popen
import eventlet

DETACHED_PROCESS = 0x00000008
SERVER_PORT = 8088
SERVER_ADRESS = "http://127.0.0.1:8088"


def spawn_proxy(path):
    print(os.path.join(os.path.curdir, path))
    cmd = [
        os.path.join(os.path.curdir, path),
    ]
    p = Popen(
        cmd,
        shell=False,
        stdin=None,
        stdout=stdout,
        stderr=None,
        close_fds=True,
        creationflags=DETACHED_PROCESS,
    )


def setup():
    if platform == "linux" or platform == "linux2":
        spawn_proxy("bin/debug/main")
    elif platform == "win32":
        spawn_proxy("bin\\debug\\main.exe")


#
proxy_dict = {
    "http": SERVER_ADRESS,
}


def test_google_dns_get():
    setup()
    # with eventlet.Timeout(1):
    with requests.get("http://google.com", proxies=proxy_dict) as proxy_response:
        with requests.get("http://google.com") as clean_response:
            assert str(proxy_response).encode() == str(clean_response).encode()
