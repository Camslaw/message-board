package server;

import java.util.*;
import com.google.gson.Gson;

/**
 * The GroupManager class handles the core logic for managing user groups, messages, 
 * and user states in a server environment. It provides methods for adding/removing 
 * users, managing groups, storing and retrieving messages, and broadcasting notifications.
 *
 * Responsibilities:
 * - Manage user sign-ins and group memberships.
 * - Maintain a mapping of users to their client handlers for communication.
 * - Store and retrieve messages for groups and users.
 * - Broadcast messages and notifications to groups or individual users.
 *
 * Thread Safety:
 * - All public methods are synchronized to ensure thread safety in a multi-threaded environment.
 */

public class GroupManager {
    private final Set<String> signedInUsers = new HashSet<>();
    private final Map<String, Set<String>> groups = new HashMap<>();
    private final Map<String, String> userToGroupMap = new HashMap<>(); // Mapping from username to group
    private final Map<String, ClientHandler> userToClientMap = new HashMap<>();
    private final Map<String, String> messageStore = new HashMap<>();
    private final Map<String, LinkedList<String>> recentMessages = new HashMap<>(); // Tracks the last two messages per group
    private final List<String> predefinedGroups = Arrays.asList(
        "tutoring", "announcements", "homework", "networking", "wellness" // Predefined groups available on the server
    );
    private final Gson gson = new Gson();

    /**
     * Constructor for GroupManager.
     * Initializes the predefined groups and their recent messages trackers.
     */
    public GroupManager() {
        // Initialize groups with predefined group names
        for (String group : predefinedGroups) {
            groups.put(group, new HashSet<>());
            recentMessages.put(group, new LinkedList<>());
        }
    }

    /**
     * Returns the list of predefined groups.
     * @return List of predefined group names.
     */
    public synchronized List<String> getPredefinedGroups() {
        return predefinedGroups;
    }

    /**
     * Adds a user to the list of signed-in users.
     * @param username The username to add.
     * @return True if the user was successfully added, false if the username is already taken.
     */
    public synchronized boolean addUser(String username) {
        if (signedInUsers.contains(username)) {
            System.out.printf("DEBUG: AddUser failed. Username '%s' is already signed in.\n", username);
            return false; // Username is already signed in
        }
        signedInUsers.add(username);
        System.out.printf("DEBUG: AddUser successful. Current signed-in users: %s\n", signedInUsers);
        return true;
    }

    /**
     * Removes a user from the server entirely.
     * @param username The username to remove.
     */
    public synchronized void removeUser(String username) {
        signedInUsers.remove(username);
        userToClientMap.remove(username);
    }

    /**
     * Adds a user to a specific group.
     * @param username The username to add.
     * @param group The group to join.
     * @param handler The ClientHandler associated with the user.
     * @return True if the user was successfully added, false otherwise.
     */
    public synchronized boolean addUserToGroup(String username, String group, ClientHandler handler) {
        groups.putIfAbsent(group, new HashSet<>());
        if (groups.get(group).contains(username)) {
            System.out.printf("DEBUG: AddUserToGroup failed. Username '%s' is already in group '%s'.\n", username, group);
            return false;
        }
        signedInUsers.add(username);
        groups.get(group).add(username);
        userToClientMap.put(username, handler); // Associate username with ClientHandler 
        System.out.printf("DEBUG: User '%s' added to group '%s'.\n", username, group);
        // Send the last two messages to the new user
        return true;
    }

    /**
     * Removes a user from a specific group.
     * @param username The username to remove.
     * @param group The group to leave.
     */
    public synchronized void removeUserFromGroup(String username, String group) {
        if (groups.containsKey(group)) {
            groups.get(group).remove(username);
            System.out.printf("DEBUG: User '%s' removed from group '%s'.\n", username, group);
            broadcastMessage(group, "User '" + username + "' has left the group.", username);
        }
        signedInUsers.remove(username);
        userToClientMap.remove(username);
    }

    /**
     * Broadcasts a message to all users in a group.
     * @param group The target group.
     * @param message The message to broadcast.
     */
    public synchronized void broadcastMessages1(String group, String message) {        
        if (groups.containsKey(group)) {
            for (String member : groups.get(group)) {
                sendMessageToUser(member, gson.toJson(Map.of("notification", message)));
            }
            System.out.printf("DEBUG: Broadcast to group '%s': %s\n", group, message);
        }
    }

    /**
     * Sends a message to all users in a group, excluding the sender.
     * @param group The target group.
     * @param message The message to broadcast.
     * @param sender The sender's username.
     */
    public synchronized void broadcastMessage(String group, String message, String sender) {        
        if (groups.containsKey(group)) {
            for (String member : groups.get(group)) {
                if (!member.equals(sender)) {
                    sendMessageToUser(member, gson.toJson(Map.of("notification", message)));
                }
            }
            System.out.printf("DEBUG: Broadcast to group '%s': %s\n", group, message);
        }
    }

     /**
     * Sends the list of users in a group to a specific user.
     * @param username The username of the recipient.
     * @param group The target group.
     */
    public synchronized void sendGroupUserList(String username, String group) {
        if (groups.containsKey(group)) {
            Set<String> usersInGroup = getUsersInGroup(group);
            Set<String> filteredUsers = new HashSet<>(usersInGroup);
            filteredUsers.remove(username);
            String message = "Users in group '" + group + "': { " + String.join(", ", filteredUsers) + " }";
            sendMessageToUser(username, gson.toJson(Map.of("notification", message))); // Use "notification" for consistency
        } else {
            System.out.printf("DEBUG: Group '%s' does not exist. Cannot send user list to '%s'.\n", group, username);
        }
    }

    /**
     * Sends a message to a specific user via their ClientHandler.
     * @param username The username of the recipient.
     * @param message The message to send.
     */
    private void sendMessageToUser(String username, String message) {
        // Logic to send a message to a specific user (e.g., via their socket connection)
        // This assumes a mapping from username to socket/output stream exists.
        ClientHandler clientHandler = userToClientMap.get(username); // Map username to handler
        if (clientHandler != null) {
            clientHandler.sendMessage(message);
        }
    }

    /**
     * Retrieves the users in a group.
     * @param group The target group.
     * @return A set of usernames in the group.
     */
    public synchronized Set<String> getUsersInGroup(String group) {
        return groups.getOrDefault(group, new HashSet<>());
    }

    /**
     * Stores a message for later retrieval.
     * @param group The group where the message was posted.
     * @param id The unique ID of the message.
     * @param message The content of the message.
     */
    public synchronized void storeMessage(String group, String id, String message) {
        messageStore.put(id, message);
    }

    /**
     * Retrieves a message by its unique ID.
     * @param id The unique ID of the message.
     * @return The message content, or null if not found.
     */
    public synchronized String getMessage(String id) {
        return messageStore.get(id);
    }

    /**
     * Adds a recent message to the recent messages tracker for a group.
     * Ensures only the last two messages are stored.
     * @param group The target group.
     * @param message The message to add.
     */
    public synchronized void addRecentMessage(String group, String message) {
        recentMessages.putIfAbsent(group, new LinkedList<>());
        LinkedList<String> groupMessages = recentMessages.get(group);

        if (groupMessages.size() == 2) {
            groupMessages.poll(); // Remove the oldest message if size exceeds two
        }
        groupMessages.offer(message); // Add the new message
    }

    /**
    * Retrieves the recent messages for a group.
    * @param group The target group.
    * @return A list of the most recent messages in the group.
    */
    public synchronized List<String> getRecentMessages(String group) {
        recentMessages.putIfAbsent(group, new LinkedList<>());
        return new ArrayList<>(recentMessages.getOrDefault(group, new LinkedList<>()));
    }

}


