package server;

/**
 * The Message class represents a client-server communication message.
 * It encapsulates the type of the message and the associated data payload.
 *
 * Structure:
 * - A `Message` object contains a `type` field indicating the kind of message (e.g., "login", "post_message").
 * - The `data` field holds additional details about the message, represented by the nested `Data` class.
 *
 * Use Cases:
 * - Facilitates structured communication between the client and server using JSON serialization.
 * - Simplifies parsing and handling of different types of client requests.
 */
public class Message {
    private String type;
    private Data data;

    /**
     * Retrieves the type of the message.
     * @return The message type.
     */
    public String getType() {
        return type;
    }

    /**
     * Retrieves the data payload of the message.
     * @return The `Data` object containing message details.
     */
    public Data getData() {
        return data;
    }

    /**
     * The Data class represents the payload of a `Message` object.
     * It contains fields such as username, group, subject, and content, 
     * which provide detailed information about the message.
     */
    public static class Data {
        private String username;
        private String group;
        private String subject;
        private String content;

        /**
         * Retrieves the username associated with the message.
         * @return The username.
         */
        public String getUsername() {
            return username;
        }

        /**
         * Sets the username associated with the message.
         * @param username The username to set.
         */
        public void setUsername(String username) {
            this.username = username;
        }

        /**
         * Retrieves the group associated with the message.
         * @return The group name.
         */
        public String getGroup() {
            return group;
        }

        /**
         * Sets the group associated with the message.
         * @param group The group name to set.
         */
        public void setGroup(String group) {
            this.group = group;
        }

        /**
         * Retrieves the subject of the message.
         * @return The subject.
         */
        public String getSubject() {
            return subject;
        }

        /**
         * Sets the subject of the message.
         * @param subject The subject to set.
         */
        public void setSubject(String subject) {
            this.subject = subject;
        }

        /**
         * Retrieves the content of the message.
         * @return The message content.
         */
        public String getContent() {
            return content;
        }

        /**
         * Sets the content of the message.
         * @param content The content to set.
         */
        public void setContent(String content) {
            this.content = content;
        }
    }
}
