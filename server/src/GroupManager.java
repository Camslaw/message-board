package server;

import java.util.*;

public class GroupManager {
    private final Set<String> signedInUsers = new HashSet<>();
    private final Map<String, Set<String>> groups = new HashMap<>();
    private final Map<String, String> userToGroupMap = new HashMap<>(); // Mapping from username to group

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

    public synchronized boolean addUserToGroup(String username, String group) {
        groups.putIfAbsent(group, new HashSet<>());
        if (signedInUsers.contains(username)) {
            System.out.printf("DEBUG: AddUserToGroup failed. Username '%s' is already in group '%s'.\n", username, group);
            return false;
        }
        signedInUsers.add(username);
        groups.get(group).add(username);
        System.out.printf("DEBUG: User '%s' added to group '%s'.\n", username, group);
        return true;
    }

    public synchronized void removeUserFromGroup(String username, String group) {
        if (groups.containsKey(group)) {
            groups.get(group).remove(username);
            System.out.printf("DEBUG: User '%s' removed from group '%s'.\n", username, group);
        }
        signedInUsers.remove(username);
    }
}


