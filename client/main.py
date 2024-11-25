import sys
import os
import threading
os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QObject, pyqtSlot
from networking import client_socket, send_json, receive_data

class Backend(QObject):
    @pyqtSlot(str)
    def handleLoginRequest(self, username):
        # Send login request to the server
        data = {
            "type": "login",
            "data": {"username": username}
        }
        # print(f"DEBUG: Sending data to server: {data}")
        send_json(client_socket, data)
        # print(f"DEBUG: Login request sent: username={username}")

def main():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)
    
    engine.addImportPath(sys.path[0])
    engine.loadFromModule("gui", "gui")
    if not engine.rootObjects():
        sys.exit(-1)

    # Start networking threads
    receive_thread = threading.Thread(target=receive_data, daemon=True)
    receive_thread.start()

    exit_code = app.exec()

    # Clean up socket and threads
    client_socket.close()
    receive_thread.join()
    del engine
    sys.exit(exit_code)


if __name__ == "__main__":
    main()