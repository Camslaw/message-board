# CS4065 Programming Assignment 2 - A Simple Bulletin Board Using Socket Programming

## Team Members
- Cameron Estridge
- Shawn Lasrado
- Sai Venkata Subhash Vakkalagadda

## Introduction
This project implements a simple bulletin board system for **CS4065: Computer Networks and Networked Computing** at the **University of Cincinnati**. The system is built using **Java** for the server and **Python with PyQt6** for the client. The project demonstrates socket programming and basic client-server communication.

## Architecture Overview
 - Client-Server Communication: The client communicates with the server using a JSON-based protocol over a TCP socket.
 - Server: Handles all backend operations, including user management, group management, and message broadcasting.
 - Client: Provides a user-friendly GUI for interacting with the server. Utilizes signals and slots in PyQt6 to handle real-time updates and notifications.

## Technical Details
1. Server  
    a. Listens on port 12345 for incoming connections.  
    b. Utilizes a thread pool for managing client handlers.  
    c. Implements group and message management with Java Collections Framework.
2. Client  
    a. Communicates with the server using a custom JSON protocol.  
    b. Handles real-time updates using multi-threading.  
    c. Provides a PyQt6-based GUI for user interactions.

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
1. Download and install **Java SDK 21**.  
    [Download Java](https://www.oracle.com/java/technologies/javase-downloads.html)  
    **Important:** Java SDK 23 is not compatible with this project.  
2. Verify the Java installation:  
    ```java --version```  
    and  
    ```javac --version```

## Usage

### Without Makefile

#### Start the server
1. Navigate to the project directory:
2. Compile the Java code:  
    ```javac -cp "server/lib/gson-2.11.1-SNAPSHOT.jar" server/src/*.java -d server/build```
3.  Start the server:  
    ```java -cp "server/lib/gson-2.11.1-SNAPSHOT.jar;server/build" server.Main```

#### Start the client
1. Navigate to the 'client' directory:  
    ```cd client```
2. Run the client application:  
    ```python main.py```

### With Makefile (Optional)

Navigate to the project directory (message-board)

#### Start the server

   1. Enter the command:  
    ```make start-server```

#### Start the client

   1. Enter the command:  
    ```make run-client```  

Note: For Windows users, You can use the Chocolatey package manager to install make.

---

## Notes
- Ensure the **server** is running before starting the **client**
- Both the client and server must be on the same network for proper communication. For now, they are both setup to communicate via localhost.
- The server uses **Gson** for JSON handling, located in `server/lib/`.
