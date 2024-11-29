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
        data = sock.recv(4096).decode()  # Adjust buffer size if needed
        if not data:
            print("DEBUG: Received empty response")
            return []

        print(f"DEBUG: Raw data received: {data}")

        # Split data by newline to handle multiple JSON objects
        messages = data.strip().split("\n")
        parsed_messages = []

        for message in messages:
            try:
                parsed_messages.append(json.loads(message))
            except json.JSONDecodeError as e:
                print(f"Error decoding JSON: {e}")
                print(f"DEBUG: Malformed JSON: {message}")

        return parsed_messages
    except Exception as e:
        print(f"Error receiving data: {e}")
        return []

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
        responses = receive_json(client_socket)
        if responses is None:
            continue
        elif responses == {}:
            print("Connection closed by the server.")
            break
        print(f"DEBUG: Parsed responses: {responses}")

        
        for response in responses:
            print(f"DEBUG: Parsed response: {response}")
            # Process specific types of responses
            if "type" in response:
                if response["type"] == "recent_message" and "recent_message" in callbacks:
                    callbacks["recent_message"](response.get("message", ""))
                continue  # Skip further processing for known types

            # Process 'status' field
            if "status" in response:
                if response["status"] == "error":
                    if "user_state" in response and "user_state" in callbacks:
                        callbacks["user_state"](response["user_state"])
                    elif "error" in callbacks:
                        callbacks["error"](response.get("message", "Unknown error"))
                elif response["status"] == "success" and "success" in callbacks:
                    callbacks["success"]()

            # Process 'message' field
            if "message" in response and "message" in callbacks:
                callbacks["message"](response["message"])

            # Process 'notification' field
            if "notification" in response and "notification" in callbacks:
                callbacks["notification"](response["notification"])

# This module does not start threads or run code directly.
# Threading should be managed in `backend.py` or `main.py`.
