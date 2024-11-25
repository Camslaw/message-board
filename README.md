# CS4065 Programming Assignment 2 - A Simple Bulletin Board Using Socket Programming

## Team Members
- Cameron Estridge
- Shawn Lasrado
- Sai Venkata Subhash Vakkalagadda

## Introduction
This project implements a simple bulletin board system for **CS4065: Computer Networks and Networked Computing** at the **University of Cincinnati**. The system is built using **Java** for the server and **Python with PyQt6** for the client. The project demonstrates socket programming and basic client-server communication.

## Prerequisites

### Python Setup
1. Install Python (version 3.9 or later recommended).
    [Download Python](https://www.python.org/downloads/)
2. Verify the installation:
    ```python --version```
    or
    ```python3 --version```
3. Install PyQt6:
    ```pip install PyQt6```

### Java Setup
1. Download and install **Java SDK 21**. **Important:** Java SDK 23 is not compatible with this project. [Download Java](https://www.oracle.com/java/technologies/javase-downloads.html)
2. Verify the Java installation:
    ```java --version```
    and
    ```javac --version```

## How to Run

### Start the server
1. Navigate to the project directory:
2. Compile the Java server code:
    ```javac -cp "server/lib/gson-2.11.1-SNAPSHOT.jar" server/src/*.java -d server/build```
3.  Start the server:
    ```java -cp "server/lib/gson-2.11.1-SNAPSHOT.jar;server/build" server.Main```

### Start the client
1. Navigate to the 'client' directory:
    ```cd client```
2. Run the client application:
    ```python main.py```

---

## Notes
- Ensure the **server** is running before starting the **client**
- Both the client and server must be on the same network for proper communication. For now, they are both setup to communicate via localhost.
- The server uses **Gson** for JSON handling, located in `server/lib/`.