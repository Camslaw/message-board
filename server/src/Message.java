package server;

public class Message {
    private String type;
    private Data data;

    public String getType() {
        return type;
    }

    public Data getData() {
        return data;
    }

    public static class Data {
        private String username;
        private String group;
        private String subject;
        private String content;

        // Getters and Setters
        public String getUsername() {
            return username;
        }

        public void setUsername(String username) {
            this.username = username;
        }

        public String getGroup() {
            return group;
        }

        public void setGroup(String group) {
            this.group = group;
        }

        public String getSubject() {
            return subject;
        }

        public void setSubject(String subject) {
            this.subject = subject;
        }

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }
    }
}
