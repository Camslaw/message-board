from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot
from protocol import client_socket, send_json, receive_data
import threading
import atexit


class Backend(QObject):
    loginError = pyqtSignal(str)  # Signal for login errors
    loginSuccess = pyqtSignal()

    def __init__(self):
        super().__init__()
        self.running = True
        atexit.register(self.cleanup)

    def startReceiving(self):
        # Thread for receiving data
        threading.Thread(target=self.receiveData, daemon=True).start()

    def receiveData(self):
        # Pass appropriate callbacks to `receive_data`
        callbacks = {
            "error": self.loginError.emit,  # Emits an error signal for the UI
            "success": self.loginSuccess.emit  # Emits a success signal for the UI
        }
        receive_data(callbacks)

    @pyqtSlot(str)
    def handleLoginRequest(self, username):
        # Send login request to the server
        data = {
            "type": "login",
            "data": {"username": username}
        }
        send_json(client_socket, data)

    @pyqtSlot()
    def handleLogoutRequest(self):
        # Send logout request to the server
        data = {
            "type": "logout",
        }
        send_json(client_socket, data)

    def cleanup(self):
        # Send a logout request when the application exits
        if client_socket:
            print("Cleaning up and notifying the server...")
            data = {"type": "logout"}
            send_json(client_socket, data)
        self.running = False
