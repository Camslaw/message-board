from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot
from protocol import client_socket, send_json, receive_data
import threading
import atexit

class Backend(QObject):
    """
    Backend class that manages communication between the UI and the server using PyQt signals and slots.
    """
    
    # Signals to communicate with the UI
    loginError = pyqtSignal(str)
    loginSuccess = pyqtSignal()
    notification = pyqtSignal(str)
    messageRetrieved = pyqtSignal(str)
    recentMessageReceived = pyqtSignal(str)
    recentMessageReceived2 = pyqtSignal(str)
    uiReady = pyqtSignal(str)

    def __init__(self):
        """
        Initialize the Backend object.
        """
        super().__init__()
        self.running = True
        self.uiInitialized = False
        self.messageBuffer = []  # Buffer for recent messages
        self.current_group = None  # Tracks the current group the user is in
        self.current_user = ""
        atexit.register(self.cleanup)

    @pyqtSlot(str)
    def handleUIReady(self, group):
        """
        Handles the UI ready signal, sending a request for the user list and flushing buffered messages.
        Args:
            group (str): The group to request user information for.
        """
        print(f"DEBUG: handleUIReady sending request for {group}")
        data = {
            "type": "user_list",
            "data": {"group": group}
        }
        send_json(client_socket, data)

        # Send buffered recent messages to the UI
        print("DEBUG: Flushing buffered recent messages")
        for message in self.messageBuffer:
            self.recentMessageReceived.emit(message)
        self.messageBuffer.clear()

    def startReceiving(self):
        """
        Starts a background thread for continuously receiving data from the server.
        """
        threading.Thread(target=self.receiveData, daemon=True).start()

    def receiveData(self):
        """
        Continuously listens for server messages and processes them with the appropriate callbacks.
        """
        callbacks = {
            "error": self.loginError.emit,
            "success": self.loginSuccess.emit,
            "notification": lambda msg: (
                print(f"DEBUG: Emitting notification: {msg}"),
                self.notification.emit(msg)
            ),
            "message": lambda msg: (
                print(f"DEBUG: Emitting messageRetrieved: {msg}"),
                self.messageRetrieved.emit(msg)
            ),
            "user_state": lambda msg: (
                print(f"DEBUG: User state error: {msg}"),
                self.loginError.emit(msg)
            ),
            "recent_message": lambda msg: (
                print(f"DEBUG: Recent message received: {msg}"),
                self.recentMessageReceived.emit(msg) if self.uiInitialized else self.messageBuffer.append(msg)
            ),
            "recent_message2": lambda msg: (
                print(f"DEBUG: Recent message received: {msg}"),
                self.recentMessageReceived2.emit(msg)
            )
        }
        receive_data(callbacks)

    @pyqtSlot(str, str)
    def handleLoginRequest1(self, username, group):
        """
        Sends a login request with username and group information.
        """
        data = {
            "type": "login",
            "data": {"username": username, "group": group}
        }
        send_json(client_socket, data)

    @pyqtSlot(str)
    def handleLoginRequest2(self, username):
        """
        Sends a login request with username only.
        """
        data = {
            "type": "login2",
            "data": {"username": username}
        }
        send_json(client_socket, data)

    @pyqtSlot(str)
    def handleLogoutRequestGroup(self, group):
        """
        Sends a logout request for a specific group and updates the current group state.
        """
        data = {
            "type": "logout",
            "data": {"group": group}
        }
        send_json(client_socket, data)
        self._last_group = None  # Reset _last_group on logout
        if self.current_group == group:
            self.current_group = None # Reset current_group on logout

    @pyqtSlot(str)
    def handleLogoutRequestSolo(self, username):
        """
        Sends a logout request for a specific username, used for logging out when a user
        is not joined to a group.
        """
        data = {
            "type": "logout2",
            "data": {"username": username}
        }
        send_json(client_socket, data)

    @pyqtSlot(str)
    def requestUserList(self, group):
        """
        Requests the list of users in a group from the server.
        """
        data = {
            "type": "user_list",
            "data": {"group": group}
        }
        send_json(client_socket, data)

    @pyqtSlot(str, str, str)
    def postMessage(self, group, subject, content):
        """
        Sends a post message request to the server.
        """
        data = {
            "type": "post_message",
            "data": {
                "group": group,
                "subject": subject,
                "content": content
            }
        }
        send_json(client_socket, data)

    @pyqtSlot(str)
    def getMessageById(self, message_id):
        """
        Requests a message by its ID from the server.
        """
        data = {
            "type": "get_message",
            "data": {"content": message_id}
        }
        send_json(client_socket, data)

    @pyqtSlot(str)
    def handleJoinGroup(self, group):
        """
        Sends a request to join a group and updates the current group.
        """
        self.current_group = group
        data = {
            "type": "join_group",
            "data": {"group": group}
        }
        send_json(client_socket, data)
        print(f"DEBUG: Joined group {group}")

    @pyqtSlot(str)
    def handleLeaveGroup(self, group):
        """
        Sends a request to leave a group and clears the current group if applicable.
        """
        if self.current_group == group:
            self.current_group = None
        data = {
            "type": "leave_group",
            "data": {"group": group}
        }
        send_json(client_socket, data)
        print(f"DEBUG: Left group {group}")

    @pyqtSlot(result=bool)
    def isInGroup(self):
        """
        Checks if the user is currently in a group.
        """
        return self.current_group is not None
    
    def cleanup(self):
        """
        Ensures proper cleanup by sending a logout request when the application exits.
        """
        if client_socket:
            print("Cleaning up and notifying the server...")
            data = {"type": "logout"}
            send_json(client_socket, data)
        self.running = False
