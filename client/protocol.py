import socket
import json

# Note:
# This module is designed for socket communication and JSON message handling.
# It does not manage threads or the application's main event loop.
# Threading and higher-level logic should be implemented in `backend.py` or `main.py`.

# Server connection details
SERVER_HOST = '127.0.0.1'
SERVER_PORT = 12345

# Establish socket connection
try:
    # Create a TCP socket
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
        # Convert the dictionary to a JSON-formatted string
        json_data = json.dumps(data)
        # Send the JSON string with a newline character (required for server parsing)
        sock.sendall((json_data + '\n').encode())
    except Exception as e:
        print(f"Error sending data: {e}")

def receive_json(sock):
    """
    Receive and parse a JSON object from the server.

    Args:
        sock (socket): The client socket to receive data from.

    Returns:
        list: A list of parsed JSON objects. If parsing fails, returns an empty list.
    """
    try:
        data = sock.recv(4096).decode()  # Adjust buffer size if needed
        if not data:
            print("DEBUG: Received empty response")
            return []

        print(f"DEBUG: Raw data received: {data}")

        # Split the received data by newline to handle multiple JSON objects
        messages = data.strip().split("\n")
        parsed_messages = []

        # Parse each JSON object
        for message in messages:
            try:
                parsed_messages.append(json.loads(message)) # Convert JSON string to a dictionary
            except json.JSONDecodeError as e:
                print(f"Error decoding JSON: {e}")
                print(f"DEBUG: Malformed JSON: {message}")

        return parsed_messages
    except Exception as e:
        print(f"Error receiving data: {e}")
        return []

def receive_data(callbacks):
    """
    Continuously receive data from the server and handle responses using callbacks.

    Args:
        callbacks (dict): A dictionary of callback functions to handle specific response types.
                          Keys include:
                          - 'error': Called with error messages
                          - 'success': Called on successful operations
                          - 'notification': Called with notifications
                          - 'message': Called with regular messages
                          - 'recent_message': Called with recent message data
                          - 'recent_message2': Called with additional recent message data
    """
    if not client_socket:
        print("Client socket is not connected.")
        return

    while True:
        # Continuously receive and process data from the server
        responses = receive_json(client_socket)
        if responses is None:
            break
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
                elif response["type"] == "recent_message2" and "recent_message2" in callbacks:
                    callbacks["recent_message2"](response.get("message2", ""))
                continue  # Skip further processing for known types

            # Handle 'status' field in the response
            if "status" in response:
                if response["status"] == "error":
                    if "user_state" in response and "user_state" in callbacks:
                        callbacks["user_state"](response["user_state"])
                    elif "error" in callbacks:
                        callbacks["error"](response.get("message", "Unknown error"))
                elif response["status"] == "success" and "success" in callbacks:
                    callbacks["success"]()

            # Handle 'message' field in the response
            if "message" in response and "message" in callbacks:
                callbacks["message"](response["message"])

            # Handle 'notification' field in the response
            if "notification" in response and "notification" in callbacks:
                callbacks["notification"](response["notification"])
