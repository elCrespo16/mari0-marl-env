
import json
from queue import Empty, Full, Queue
import socket              # Import socket module
import os
import fcntl
import time


def controller(env_channel: Queue, send_channel: Queue, port: int):
    # Create a socket object
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    host = socket.gethostname()  # Get local machine name
    fcntl.fcntl(s, fcntl.F_SETFL, os.O_NONBLOCK)

    # Test if game already running
    start_communication = False
    while not start_communication:
        aux = s.connect_ex((host, port))
        if aux == 0:
            time.sleep(2)
        else:
            start_communication = True

    # When game already running, connect and send messages
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        try:
            s.connect((host, port))
        except:
            close_socket = True
        close_socket = False
        while not close_socket:
            # Try get commands
            try:
                data = env_channel.get(timeout=90)
            except Empty:
                return
            wait_for_response = False
            # Check if close command or if command needs response
            for c in data:
                if c["name"] == "Close":
                    close_socket = True
                if c["need_response"]:
                    wait_for_response = True
            data_json = json.dumps(data)  # Parse command into json
            try:
                s.sendall(f"{data_json} \n".encode("utf_8"))
            except:
                close_socket = True
            # If command needs response then wait for response
            reward_json = None
            while wait_for_response and not close_socket:
                try:
                    reward_json = s.recv(1024)
                except socket.error as e:
                    close_socket = True
                if reward_json:
                    wait_for_response = False
                    reward = json.loads(reward_json)
                    # Comprobation just for debug purposes
                    if reward != "NP":
                        if reward == "CLOSE":
                            close_socket = True
                        else:
                            try:
                                send_channel.put(reward, timeout=5)
                            except Full:
                                pass
