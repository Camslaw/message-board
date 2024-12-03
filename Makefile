# Variables
JAVA_SRC_DIR = server/src
JAVA_BUILD_DIR = server/build
JAVA_LIB_DIR = server/lib
JAVA_CLASSPATH = $(JAVA_LIB_DIR)/gson-2.11.1-SNAPSHOT.jar
MAIN_CLASS = server.Main

PYTHON_MAIN = client/main.py

# Targets
.PHONY: all clean server client

all: server client

server:
	javac -cp "$(JAVA_CLASSPATH)" $(JAVA_SRC_DIR)/*.java -d $(JAVA_BUILD_DIR)

run-server: server
	java -cp "$(JAVA_CLASSPATH);$(JAVA_BUILD_DIR)" $(MAIN_CLASS)

client:
	@echo "Client setup is managed via Python and PyQt6. Ensure PyQt6 is installed."
	@echo "To run the client: python $(PYTHON_MAIN)"

run-client:
	python $(PYTHON_MAIN)

clean:
	rm -rf $(JAVA_BUILD_DIR)
	@echo "Cleaned up server build directory."
