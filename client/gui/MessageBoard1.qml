import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: stackView.width
    height: stackView.height

    signal signOut1()  // Signal to notify when the user wants to sign out

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
                        let publicGroup = groupModel.get(0)
                        messageBox.text += `Users in public: Alice, Bob, Charlie\n`;
                    }
                }
            }

            Button {
                background: Rectangle {
                    radius: 8
                }
                text: "Sign Out (go back to login screen)"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    backend.handleLogoutRequest();
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
                    text: "Send"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        let validGroups = ["public"];
                        let groupName = groupNameField.text.trim();
                        let subject = subjectField.text.trim();
                        let body = messageBodyField.text.trim();

                        if (groupName === "" || subject === "" || body === "") {
                            messageBox.text += "Error: All fields are required.\n";
                        } else if (!validGroups.includes(groupName)) {
                            messageBox.text += `Error: "${groupName}" is not a valid group.\n`;
                        } else {
                            // Simulate posting the message
                            messageBox.text += `Message posted to "${groupName}":\nSubject: ${subject}\n${body}\n\n`;
                            // Clear fields after sending
                            groupNameField.text = "";
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
                    text: "Send"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        
                    }
                }
            }
        }
    }

    ListModel {
        id: groupModel
        ListElement { name: "public"; joined: false }
    }
}
