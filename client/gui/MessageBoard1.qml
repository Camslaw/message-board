import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: stackView.width
    height: stackView.height

    signal signOut1()  // Signal to notify when the user wants to sign out
    signal uiReady()

    Component.onCompleted: {
        if (!uiInitialized) {
            console.log("DEBUG: Connecting to backend");
            uiInitialized = true;
            backend.uiReady("public");
        }
    }

    property bool uiInitialized: false

    Row {
        anchors.fill: parent
        spacing: 10

        // Group List and Controls
        Column {
            id: groupColumn
            width: parent.width * 0.25
            spacing: 10

            Text {
                id: errorMessage
                text: ""
                color: "red"
                font.pointSize: 12
                visible: text.length > 0
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter

                Button {
                    background: Rectangle {
                        radius: 8
                    }
                    text: "Check public users"
                    onClicked: {
                        backend.requestUserList("public");
                    }
                }
            }

            Button {
                background: Rectangle {
                    radius: 8
                }
                text: "Sign Out (leave group and go back to login screen)"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    backend.handleLogoutRequestGroup();
                    uiInitialized = false;
                    messageBox.text = ""; // Clear the message box
                    signOut1();
                }
            }

            Button {
                background: Rectangle {
                    radius: 8
                }
                text: "Exit"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    Qt.quit(); // Closes the application
                }
            }
        }

        // Main Content Area
        Column {
            spacing: 20
            width: parent.width * 0.75

            // Title
            Text {
                text: "Message Board"
                font.pointSize: 24
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ScrollView {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9
                height: parent.height * 0.5
                clip: true

                TextArea {
                    id: messageBox
                    readOnly: true
                    wrapMode: Text.Wrap
                    font.pointSize: 14
                    color: "white"
                    background: Rectangle {
                        color: "#585c63"
                        radius: 8
                    }
                    text: "Welcome to the Message Board!\n"  // Initial message
                }
            }

            Column {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9

                // Subject Input
                Row {
                    spacing: 10
                    Text {
                        text: "Subject:"
                        color: "white"
                        font.pointSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: subjectField
                        background: Rectangle {
                            color: "#585c63"
                            radius: 10
                        }
                        color: "white"
                        placeholderText: "Enter subject"
                        width: parent.width * 0.6
                    }
                }

                // Message Body Input
                Row {
                    spacing: 10
                    Text {
                        text: "Message:"
                        color: "white"
                        font.pointSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: messageBodyField
                        background: Rectangle {
                            color: "#585c63"
                            radius: 10
                        }
                        color: "white"
                        placeholderText: "Enter message"
                        width: parent.width * 0.6
                    }
                }

                // Send Button
                Button {
                    background: Rectangle {
                        radius: 8
                    }
                    text: "Send message"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        let subject = subjectField.text.trim();
                        let body = messageBodyField.text.trim();

                        if (subject === "" || body === "") {
                            messageBox.text += "Error: Subject and message body are required.\n";
                        } else {
                            backend.postMessage("public", subject, body);
                            subjectField.text = "";
                            messageBodyField.text = "";
                        }
                    }
                }
            }

            Column {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9

                // Message ID input
                Row {
                    spacing: 10
                    Text {
                        text: "Message ID:"
                        color: "white"
                        font.pointSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: messageBodyFieldRead
                        background: Rectangle {
                            color: "#585c63"
                            radius: 10
                        }
                        color: "white"
                        placeholderText: "Enter message ID"
                        width: parent.width * 0.6
                    }
                }

                // Send Button
                Button {
                    background: Rectangle {
                        radius: 8
                    }
                    text: "Read message"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        let messageId = messageBodyFieldRead.text.trim();
                        if (messageId === "") {
                            messageBox.text += "Error: Message ID cannot be empty.\n";
                        } else {
                            backend.getMessageById(messageId);
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: groupModel
        ListElement { name: "public"; joined: false }
    }

    Connections {
        target: backend
        function onNotification(message) {
            console.log("Notification received in QML:", message); // Detailed log
            try {
                if (message.startsWith("Message ID:")) {
                    messageBox.text += `${message}\n`;
                } else {
                    messageBox.text += `${message}\n`;  // Append notification
                }
            } catch (e) {
                console.error("Error handling notification in QML:", e);
            }
        }

        function onMessageRetrieved(message) {
            console.log("Message retrieved in QML:", message);  // Debug log
            try {
                // Split the message into lines
                let lines = message.split("\n");
                
                // Extract the ID and Content from the lines
                let idLine = lines.find(line => line.startsWith("Message ID:"));
                let contentLine = lines.find(line => line.startsWith("Content:"));

                // Extract the values
                let messageId = idLine ? idLine.split(":")[1].trim() : "Unknown ID";
                let content = contentLine ? contentLine.split(":")[1].trim() : "No content";

                // Append the formatted message to the message box
                messageBox.text += `Message ${messageId} content: ${content}\n`;
            } catch (e) {
                console.error("Error handling retrieved message in QML:", e);
            }
        }

        function onRecentMessageReceived(message) {
            console.log("Recent message received in QML:", message);
            messageBox.text += `[Recent] ${message}\n`;
        }
    }
}
