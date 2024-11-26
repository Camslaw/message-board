package server;

import com.google.gson.Gson;
import java.util.Map;

import java.io.*;
import java.net.Socket;

public class ClientHandler implements Runnable {
    private final Socket clientSocket;
    private final GroupManager groupManager;
    private final Gson gson = new Gson();
    private String username;

    public ClientHandler(Socket socket, GroupManager manager) {
        this.clientSocket = socket;
        this.groupManager = manager;
    }

    @Override
    public void run() {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(clientSocket.getInputStream()));
             PrintWriter writer = new PrintWriter(clientSocket.getOutputStream(), true)) {

            String line;
            while ((line = reader.readLine()) != null) {
                System.out.printf("DEBUG: Raw data received: %s\n", line); // Log raw input
                Message message = gson.fromJson(line, Message.class);
                handleRequest(message, writer);
            }
        } catch (IOException e) {
            System.out.println("Connection error: " + e.getMessage());
        } finally {
            if (username != null) {
                groupManager.removeUser(username);
                System.out.printf("DEBUG: Connection closed. Username '%s' removed.\n", username);
            }
            try {
                clientSocket.close();
            } catch (IOException e) {
                System.out.println("Error closing client socket: " + e.getMessage());
            }
        }
    }

    private void handleRequest(Message message, PrintWriter writer) {
        switch (message.getType()) {
            case "login": // Handle user sign-in
                username = message.getData().getUsername();

                // Check if username is already in use
                if (!groupManager.addUser(username)) {
                    writer.println(gson.toJson(Map.of(
                        "status", "error",
                        "message", "Username '" + username + "' is already taken"
                    )));
                    System.out.printf("DEBUG: Rejected username '%s' - already signed in.\n", username);
                    return;
                }
                // Debug message
                System.out.printf("DEBUG: User '%s' signed in.\n", username);

                writer.println(gson.toJson(Map.of(
                    "status", "success",
                    "message", "Signed in as " + username
                )));
                break;

            case "logout": // Handle explicit logout
                if (username != null) {
                    groupManager.removeUser(username);
                    writer.println(gson.toJson(Map.of("status", "success", "message", "Logged out successfully")));
                    System.out.printf("DEBUG: User '%s' logged out.\n", username);
                    username = null; // Clear username to prevent double removal
                }
                break;

            case "exit": // Handle user sign-out
                if (username != null) {
                    groupManager.removeUser(username);
                    writer.println(gson.toJson(Map.of("status", "success", "message", "Goodbye!")));
                    System.out.printf("DEBUG: User '%s' signed out.\n", username);
                }
                break;

            default:
                writer.println(gson.toJson(Map.of("status", "error", "message", "Unknown command")));
        }
    }
}
