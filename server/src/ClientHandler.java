package server;

import com.google.gson.Gson;
import java.util.Map;
import java.util.Set;
import java.util.List;

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
                groupManager.removeUserFromGroup(username, "public");
                System.out.printf("DEBUG: %s's application closed.\n", username);
            }
            try {
                if (!clientSocket.isClosed()) {
                    clientSocket.close();   
                }
            } catch (IOException e) {
                System.out.println("Error closing client socket: " + e.getMessage());
            }
        }
    }

    private void handleRequest(Message message, PrintWriter writer) {
        String logoutGroup = message.getData().getGroup(); // Get group name
        switch (message.getType()) {
            case "login": // Handle user sign-in
                username = message.getData().getUsername();
                String group = message.getData().getGroup();

                // Check if username is already in use
                if (!groupManager.addUserToGroup(username, group, this)) { // Pass 'this' for ClientHandler
                    writer.println(gson.toJson(Map.of(
                        "status", "error",
                        "user_state", "Username '" + username + "' is already taken"
                    )));
                    System.out.printf("DEBUG: Rejected username '%s' - already signed in.\n", username);
                    return;
                } else {
                    // Debug message
                    System.out.printf("DEBUG: User '%s' signed in and joined group '%s'.\n", username, group);
                    writer.println(gson.toJson(Map.of(
                        "status", "success",
                        "user_state", "Signed in as " + username + " in group " + group
                    )));
                    groupManager.broadcastMessage(group, "User '" + username + "' has joined the group.", username);
                }

                // Send the last two messages in the group
                List<String> recentMessages = groupManager.getRecentMessages(group);
                for (String recentMessage : recentMessages) {
                    writer.println(gson.toJson(Map.of(
                        "type", "recent_message",
                        "message", recentMessage
                    )));
                }

                // // Get the list of users in the group and send it to the new user
                // groupManager.sendGroupUserList(username, group);
                // groupManager.sendRecentMessagesToUser(group, this);
                break;

            case "login2": // Handle user sign-in
                username = message.getData().getUsername();

                // Check if username is already in use
                if (!groupManager.addUser(username)) { // Pass 'this' for ClientHandler
                    writer.println(gson.toJson(Map.of(
                        "status", "error",
                        "user_state", "Username '" + username + "' is already taken"
                    )));
                    System.out.printf("DEBUG: Rejected username '%s' - already signed in.\n", username);
                    return;
                }
                // Debug message
                System.out.printf("DEBUG: User '%s' signed in.\n", username);

                writer.println(gson.toJson(Map.of(
                    "status", "success",
                    "user_state", "Signed in as " + username
                )));
                break;

            case "logout": // Handle explicit logout
                if (username != null && logoutGroup != null) {
                    groupManager.removeUserFromGroup(username, logoutGroup);
                    writer.println(gson.toJson(Map.of("status", "success", "message", "Logged out successfully")));
                    System.out.printf("DEBUG: User '%s' logged out and left group '%s'.\n", username, logoutGroup);
                    username = null; // Clear username to prevent double removal
                } else {
                    writer.println(gson.toJson(Map.of("status", "error", "message", "Logout failed: Missing data")));
                }
                break;

            case "logout2": // Handle explicit logout
                if (username != null) {
                    groupManager.removeUser(username);
                    writer.println(gson.toJson(Map.of("status", "success", "message", "Logged out successfully")));
                    System.out.printf("DEBUG: User '%s' logged out.\n", username);
                    username = null; // Clear username to prevent double removal
                } else {
                    writer.println(gson.toJson(Map.of("status", "error", "message", "Logout failed: Missing data")));
                }
                break;

            case "user_list": // Handle request for user list
                String requestedGroup = message.getData().getGroup();
                groupManager.sendGroupUserList(username, requestedGroup); // Send the list back to the user
                break;

            case "post_message":
                String postGroup = message.getData().getGroup();
                String postSubject = message.getData().getSubject();
                String postContent = message.getData().getContent();
                String newMessageId = String.valueOf(System.currentTimeMillis()); // Unique message ID

                // Correctly format the message for display
                String formattedMessage = String.format(
                    "Message ID: %s, Group: %s, Sender: %s, Post Date: %s, Subject: %s",
                    newMessageId, postGroup, username, new java.util.Date(), postSubject
                );

                // Add the message to the recent list and store it
                groupManager.addRecentMessage(postGroup, formattedMessage);

                // Store the message for retrieval
                groupManager.storeMessage(postGroup, newMessageId, String.format(
                    "Group: %s, Sender: %s\nDate: %s\nSubject: %s\nContent: %s",
                    postGroup, username, new java.util.Date(), postSubject, postContent
                ));

                // Broadcast the formatted message
                groupManager.broadcastMessages1(postGroup, formattedMessage);
                System.out.printf("DEBUG: Message posted to group '%s': %s\n", postGroup, formattedMessage);
                break;

            case "get_message": // Handle retrieving a message by ID
                String requestedMessageId = message.getData().getContent();
                String retrievedMessage = groupManager.getMessage(requestedMessageId);

                if (retrievedMessage != null && !retrievedMessage.trim().isEmpty()) {
                    writer.println(gson.toJson(Map.of(
                        "status", "success",
                        "message", "Message ID: " + requestedMessageId + "\n" + retrievedMessage
                    )));
                } else {
                    writer.println(gson.toJson(Map.of(
                        "status", "error",
                        "message", "Message not found"
                    )));
                }
                break;

            case "join_group":
                if (username != null) {
                    String groupToJoin = message.getData().getGroup();
                    if (groupManager.addUserToGroup(username, groupToJoin, this)) {
                        writer.println(gson.toJson(Map.of(
                            "status", "success",
                            "message", "Joined group " + groupToJoin
                        )));
                        // Notify other users in the group, excluding the sender
                        groupManager.broadcastMessage(groupToJoin, "User '" + username + "' has joined the group '" + groupToJoin + "'", username);
                        // Send the last two messages in the group
                        List<String> recentMessages2 = groupManager.getRecentMessages(groupToJoin);
                        for (String recentMessage : recentMessages2) {
                            writer.println(gson.toJson(Map.of(
                                "type", "recent_message2",
                                "message2", recentMessage
                            )));
                        }
                    } else {
                        writer.println(gson.toJson(Map.of(
                            "status", "error",
                            "message", "Failed to join group " + groupToJoin
                        )));
                    }
                } else {
                    writer.println(gson.toJson(Map.of(
                        "status", "error",
                        "message", "You must log in before joining a group."
                    )));
                }
                break;

            case "leave_group":
                if (username != null) {
                    groupManager.removeUserFromGroup(username, message.getData().getGroup());
                    writer.println(gson.toJson(Map.of(
                        "status", "success",
                        "message", "Left group " + message.getData().getGroup()
                    )));
                } else {
                    writer.println(gson.toJson(Map.of(
                        "status", "error",
                        "message", "You must log in before leaving a group."
                    )));
                }
                break;

            case "exit": // Handle user sign-out
                if (username != null) {
                    groupManager.removeUserFromGroup(username, logoutGroup);
                    writer.println(gson.toJson(Map.of("status", "success", "message", "Goodbye!")));
                    System.out.printf("DEBUG: User '%s' exited the client and left group '%s'.\n", username, logoutGroup);
                }
                break;

            default:
                writer.println(gson.toJson(Map.of("status", "error", "message", "Unknown command")));
        }
    }

    public void sendMessage(String message) {
        try {
            if (message == null || message.trim().isEmpty()) {
                System.out.printf("DEBUG: Skipping empty message for '%s'\n", username);
                return; // Skip empty messages
            }
            PrintWriter writer = new PrintWriter(clientSocket.getOutputStream(), true);
            writer.println(message);
            System.out.printf("DEBUG: Sent to '%s': %s\n", username, message);
        } catch (IOException e) {
            System.out.printf("ERROR: Unable to send message to '%s': %s\n", username, e.getMessage());
        }
    }
}
