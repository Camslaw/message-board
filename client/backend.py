from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot
from protocol import client_socket, send_json, receive_data
import threading
import atexit


class Backend(QObject):
    loginError = pyqtSignal(str)  # Signal for login errors
    loginSuccess = pyqtSignal()
    notification = pyqtSignal(str)
    messageRetrieved = pyqtSignal(str)
    uiReady = pyqtSignal(str)

    def __init__(self):
        super().__init__()
        self.running = True
        # self._last_group = None
        atexit.register(self.cleanup)

    @pyqtSlot(str)  # Slot to handle the UI ready signal
    def handleUIReady(self, group):
        print(f"DEBUG: handleUIReady sending request for {group}")
        data = {
            "type": "user_list",
            "data": {"group": group}
        }
        send_json(client_socket, data)

    def startReceiving(self):
        # Thread for receiving data
        threading.Thread(target=self.receiveData, daemon=True).start()

    def receiveData(self):
        # Pass appropriate callbacks to `receive_data`
        callbacks = {
            "error": self.loginError.emit,  # Emits an error signal for the UI
            "success": self.loginSuccess.emit,  # Emits a success signal for the UI
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
                self.loginError.emit(msg)  # Emit the error message for UI display
            )
        }
        receive_data(callbacks)

    @pyqtSlot(str, str)
    def handleLoginRequest1(self, username, group):
        # Send login request to the server
        data = {
            "type": "login",
            "data": {"username": username, "group": group}
        }
        send_json(client_socket, data)

    @pyqtSlot(str)
    def handleLoginRequest2(self, username):
        # Send login request to the server
        data = {
            "type": "login",
            "data": {"username": username}
        }
        send_json(client_socket, data)

    @pyqtSlot()
    def handleLogoutRequestGroup(self):
        # Send logout request to the server
        data = {
            "type": "logout",
            "data": {"group": "public"} # specify group to leave
        }
        send_json(client_socket, data)
        self._last_group = None  # Reset _last_group on logout

    @pyqtSlot()
    def handleLogoutRequestSolo(self):
        # Send logout request to the server
        data = {
            "type": "logout" # specify group to leave
        }
        send_json(client_socket, data)

    @pyqtSlot(str)
    def requestUserList(self, group):
        # Send a JSON request to the server for the user list
        data = {
            "type": "user_list",
            "data": {"group": group}
        }
        send_json(client_socket, data)

    @pyqtSlot(str, str, str)  # Slot to handle message posting
    def postMessage(self, group, subject, content):
        """
        Send a post message request to the server.
        Args:
            group (str): Group name.
            subject (str): Message subject.
            content (str): Message content.
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
        Retrieve a message by its ID.
        Args:
            message_id (str): The ID of the message.
        """
        data = {
            "type": "get_message",
            "data": {"content": message_id}
        }
        send_json(client_socket, data)

    def cleanup(self):
        # Send a logout request when the application exits
        if client_socket:
            print("Cleaning up and notifying the server...")
            data = {"type": "logout"}
            send_json(client_socket, data)
        self.running = False
