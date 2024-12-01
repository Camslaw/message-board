import sys
import os

# Set the style for Qt Quick Controls to "Fusion" more customizability
os.environ["QT_QUICK_CONTROLS_STYLE"] = "Fusion"

from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from protocol import client_socket
from backend import Backend

def main():
    """
    Main entry point for the application.
    Sets up the QML engine, integrates the backend, and starts the app event loop.
    """
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)
    backend.uiReady.connect(backend.handleUIReady)

    # Start networking threads
    backend.startReceiving()
    
    engine.addImportPath(sys.path[0])
    engine.loadFromModule("gui", "gui")
    if not engine.rootObjects():
        sys.exit(-1)

    exit_code = app.exec()
    backend.running = False
    backend.cleanup()
    client_socket.close()
    del engine
    sys.exit(exit_code)


if __name__ == "__main__":
    main()