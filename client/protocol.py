import socket
import json

# Server connection details
SERVER_HOST = '127.0.0.1'
SERVER_PORT = 12345

# Establish socket connection
try:
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    client_socket.connect((SERVER_HOST, SERVER_PORT))
    print("Connected to the server.")
except Exception as e:
    client_socket = None
    print(f"Connection error: {e}")

def send_json(sock, data):
    """
    Serialize and send a JSON object to the server.

    Args:
        sock (socket): The client socket.
        data (dict): The data to send.
    """
    try:
        json_data = json.dumps(data)
        sock.sendall((json_data + '\n').encode())  # Java server requires a newline
    except Exception as e:
        print(f"Error sending data: {e}")

def receive_json(sock):
    """
    Receive and parse a JSON object from the server.

    Args:
        sock (socket): The client socket.

    Returns:
        dict: The parsed JSON object.
    """
    try:
        data = sock.recv(1024).decode()
        return json.loads(data)
    except json.JSONDecodeError:
        print("Error decoding JSON")
        return None
    except Exception as e:
        print(f"Error receiving data: {e}")
        return None

def receive_data(callbacks):
    """
    Continuously receive data from the server and handle responses.

    Args:
        callbacks (dict): A dictionary of callback functions for handling responses.
                          Keys are 'error' and 'success', with values as functions.
    """
    if not client_socket:
        print("Client socket is not connected.")
        return

    while True:
        response = receive_json(client_socket)
        if not response:
            print("Connection closed by the server.")
            break
        print(f"Server response: {response}")

        # Handle response with callbacks
        if "status" in response:
            if response["status"] == "error" and "error" in callbacks:
                callbacks["error"](response["message"])
            elif response["status"] == "success" and "success" in callbacks:
                callbacks["success"]()

# This module does not start threads or run code directly.
# Threading should be managed in `backend.py` or `main.py`.
