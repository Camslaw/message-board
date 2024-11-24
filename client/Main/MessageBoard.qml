import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    anchors.fill: parent

    signal signOut()  // Signal to notify when the user wants to sign out

    Row {
        anchors.fill: parent
        spacing: 10

        // Group List and Controls
        Column {
            id: groupColumn
            width: parent.width * 0.25
            spacing: 10

            Text {
                text: "Groups"
                font.pointSize: 18
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            ListView {
                id: groupList
                width: parent.width * 0.25
                height: parent.height * 0.7
                model: groupModel
                delegate: Item {
                    width: parent.width
                    height: 40
                    Row {
                        spacing: 10
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 20

                        Button {
                            background: Rectangle {
                                radius: 8
                            }
                            text: joined ? "Leave" : "Join"
                            font.pixelSize: 12
                            onClicked: {
                                groupModel.setProperty(index, "joined", !joined)

                                if (groupModel.get(index).joined) {
                                    messageBox.text += `Welcome to ${name}!\n`;
                                } else {
                                    messageBox.text += `You have left ${name}.\n`;
                                }
                            }
                        }
                        
                        Text {
                            text: name
                            color: joined ? "lightgreen" : "white"  // Change color if joined
                            font.pointSize: 14
                        }
                    }
                }
            }

            // Placeholder Buttons for Additional Controls
            Button {
                background: Rectangle {
                    radius: 8
                }
                text: "Sign Out"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: {
                    signOut()
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
                height: parent.height * 0.7
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

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9

                TextField {
                    id: messageInput
                    background: Rectangle {
                        color: "#585c63"
                        radius: 10
                    }
                    color: "white"
                    placeholderText: "Type your message here..."
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width * 0.8
                }

                Button {
                    background: Rectangle {
                        radius: 8
                    }
                    text: "Send"
                    onClicked: {
                        if (messageInput.text.trim() !== "") {
                            // Append the new message to the message display
                            messageBox.text += "You: " + messageInput.text.trim() + "\n"
                            messageInput.text = ""  // Clear the input field
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: groupModel
        ListElement { name: "general"; joined: false }
        ListElement { name: "announcements"; joined: false }
        ListElement { name: "homework"; joined: false }
        ListElement { name: "networking"; joined: false }
        ListElement { name: "wellness"; joined: false }
    }
}
