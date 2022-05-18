from encodings import utf_8
from queue import Queue
import socket
from time import sleep               # Import socket module

def controller(env_channel: Queue, send_channel: Queue):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)         # Create a socket object
    host = socket.gethostname() # Get local machine name
    port = 55555                # Reserve a port for your service.

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect((host, port))
        while True:
            data = env_channel.get()
            s.sendall(f"{data} \n".encode(utf_8))
            if data == "close":
                break
            reward = s.recv(1024)
            send_channel.put(f"{reward!r}")


s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)         # Create a socket object
host = socket.gethostname() # Get local machine name
port = 55555                # Reserve a port for your service.

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((host, port))
    s.sendall(b"jejexd \n")
    s.sendall(b"close \n")