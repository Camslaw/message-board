import socket
import threading
import json

# Server connection details
SERVER_HOST = '127.0.0.1'
SERVER_PORT = 12345

# Establish socket connection
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
try:
    client_socket.connect((SERVER_HOST, SERVER_PORT))
    print("Connected to the server.")
except Exception as e:
    print(f"Connection error: {e}")

# Serialize and send JSON
def send_json(socket, data):
    try:
        json_data = json.dumps(data)
        # print(f"DEBUG: Serialized JSON: {json_data}")
        socket.sendall((json_data + '\n').encode()) # Java server requires a newline
        # print("DEBUG: Data sent successfully")
    except Exception as e:
        print(f"Error sending data: {e}")

# Receive and parse JSON
def receive_json(socket):
    try:
        data = socket.recv(1024).decode()
        return json.loads(data)
    except json.JSONDecodeError:
        print("Error decoding JSON")
        return None

# Function to receive data
def receive_data():
    while True:
        response = receive_json(client_socket)
        if not response:
            break
        print(f"Server response: {response}")

# Threads for send and receive
receive_thread = threading.Thread(target=receive_data)

