package server;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * The Main class serves as the entry point for the server application.
 * It listens for incoming client connections and delegates their handling 
 * to separate threads managed by a thread pool.
 *
 * Key Features:
 * - Listens for incoming client connections on a specified port.
 * - Uses a thread pool to handle multiple client connections concurrently.
 * - Manages group membership and messaging using the GroupManager class.
 */
public class Main {
    private static final int PORT = 12345;
    private static final ExecutorService threadPool = Executors.newFixedThreadPool(10); // Thread pool for managing client threads
    private static final GroupManager groupManager = new GroupManager(); // Centralized manager for groups and messages

    public static void main(String[] args) {
        // Create a ServerSocket to listen for incoming connections
        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("Server started on port " + PORT);

            while (true) {
                // Accept an incoming client connection
                Socket clientSocket = serverSocket.accept();
                System.out.println("New client connected");

                // Assign a ClientHandler to the client and execute it in the thread pool
                threadPool.execute(new ClientHandler(clientSocket, groupManager));
            }
        } catch (IOException e) {
            System.out.println("Server error: " + e.getMessage());
        } finally {
            // Ensure the thread pool is properly shut down when the server exits
            threadPool.shutdown(); 
        }
    }
}

