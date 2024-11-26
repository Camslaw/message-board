import sys
import os
import threading
os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtCore import QObject, pyqtSlot
from protocol import client_socket, send_json, receive_data
from backend import Backend

def main():
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)

    # Start networking threads
    backend.startReceiving()
    
    engine.addImportPath(sys.path[0])
    engine.loadFromModule("gui", "gui")
    if not engine.rootObjects():
        sys.exit(-1)

    exit_code = app.exec()
    backend.running = False
    backend.cleanup()
    # Clean up socket and threads
    client_socket.close()
    del engine
    sys.exit(exit_code)


if __name__ == "__main__":
    main()