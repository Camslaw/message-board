package server;

import java.util.*;
import com.google.gson.Gson;

public class GroupManager {
    private final Set<String> signedInUsers = new HashSet<>();
    private final Map<String, Set<String>> groups = new HashMap<>();
    private final Map<String, String> userToGroupMap = new HashMap<>(); // Mapping from username to group
    private final Map<String, ClientHandler> userToClientMap = new HashMap<>();
    private final Gson gson = new Gson();

    public synchronized boolean addUser(String username) {
        if (signedInUsers.contains(username)) {
            System.out.printf("DEBUG: AddUser failed. Username '%s' is already signed in.\n", username);
            return false; // Username is already signed in
        }
        signedInUsers.add(username);
        System.out.printf("DEBUG: AddUser successful. Current signed-in users: %s\n", signedInUsers);
        return true;
    }

    public synchronized void removeUser(String username) {
        if (signedInUsers.remove(username)) {
            System.out.printf("DEBUG: RemoveUser successful. Removed '%s'. Current signed-in users: %s\n", username, signedInUsers);
        } else {
            System.out.printf("DEBUG: RemoveUser failed. Username '%s' was not signed in.\n", username);
        }
    }

    public synchronized boolean addUserToGroup(String username, String group, ClientHandler handler) {
        groups.putIfAbsent(group, new HashSet<>());
        if (signedInUsers.contains(username)) {
            System.out.printf("DEBUG: AddUserToGroup failed. Username '%s' is already in group '%s'.\n", username, group);
            return false;
        }
        signedInUsers.add(username);
        groups.get(group).add(username);
        userToClientMap.put(username, handler); // Associate username with ClientHandler
        System.out.printf("DEBUG: User '%s' added to group '%s'.\n", username, group);
        broadcastMessage(group, "User '" + username + "' has joined the group."); // Notify group members
        return true;
    }

    public synchronized void removeUserFromGroup(String username, String group) {
        if (groups.containsKey(group)) {
            groups.get(group).remove(username);
            System.out.printf("DEBUG: User '%s' removed from group '%s'.\n", username, group);
            broadcastMessage(group, "User '" + username + "' has left the group.");
        }
        signedInUsers.remove(username);
        userToClientMap.remove(username);
    }

    public synchronized void broadcastMessage(String group, String message) {
        if (groups.containsKey(group)) {
            for (String member : groups.get(group)) {
                // Send message to each member (pseudo-code)
                sendMessageToUser(member, gson.toJson(Map.of("notification", message)));
            }
            System.out.printf("DEBUG: Broadcast to group '%s': %s\n", group, message);
        }
    }

    public synchronized void sendGroupUserList(String username, String group) {
        if (groups.containsKey(group)) {
            Set<String> usersInGroup = getUsersInGroup(group);
            Set<String> filteredUsers = new HashSet<>(usersInGroup);
            filteredUsers.remove(username);
            String message = "Users in group '" + group + "': " + String.join(", ", filteredUsers);
            sendMessageToUser(username, gson.toJson(Map.of("notification", message))); // Use "notification" for consistency
        } else {
            System.out.printf("DEBUG: Group '%s' does not exist. Cannot send user list to '%s'.\n", group, username);
        }
    }


    private void sendMessageToUser(String username, String message) {
        // Logic to send a message to a specific user (e.g., via their socket connection)
        // This assumes a mapping from username to socket/output stream exists.
        ClientHandler clientHandler = userToClientMap.get(username); // Map username to handler
        if (clientHandler != null) {
            clientHandler.sendMessage(message);
        }
    }

    public synchronized Set<String> getUsersInGroup(String group) {
        return groups.getOrDefault(group, new HashSet<>());
    }
}


