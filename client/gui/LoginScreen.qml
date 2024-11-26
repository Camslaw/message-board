import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal loginPart1()
    signal loginPart2()

    anchors.fill: parent

    // Mock username list
    property var takenUsernames: ["admin", "user1", "guest"]

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Welcome to the Message Board!\nEnter a username and select the part"
            font.pointSize: 24
            color: "white"
            horizontalAlignment: Text.AlignHCenter
        }

        TextField {
            id: usernameInput
            color: "white"
            background: Rectangle {
                color: "#585c63"
                radius: 10
            } 
            placeholderText: "Enter a username"
            width: 300
        }

        Text {
            id: errorMessage
            color: "red"
            font.pointSize: 14
        }

        Row {
            spacing: 20
            Button {
                background: Rectangle {
                    radius: 8
                }
                text: "Part 1"
                onClicked: {
                    if (usernameInput.text === "") {
                        errorMessage.text = "Username cannot be empty."
                    } else if (takenUsernames.includes(usernameInput.text)) {
                        errorMessage.text = "Username already taken."
                    } else {
                        errorMessage.text = ""
                        backend.handleLoginRequest(usernameInput.text) // Call backend directly
                    }
                }
            }
            Button {
                background: Rectangle {
                    radius: 8
                }
                text: "Part 2"
                onClicked: {
                    if (usernameInput.text === "") {
                        errorMessage.text = "Username cannot be empty."
                    } else if (takenUsernames.includes(usernameInput.text)) {
                        errorMessage.text = "Username already taken."
                    } else {
                        errorMessage.text = ""
                        backend.handleLoginRequest(usernameInput.text) // Call backend directly
                    }
                }
            }
            Button {
                background: Rectangle {
                    radius: 8
                }
                text: "Exit"
                onClicked: {
                    Qt.quit(); // Closes the application
                }
            }
        }
    }
    Connections {
        target: backend

        // Display error message from backend
        function onLoginError(message) {
            errorMessage.text = message;
        }

        // Transition to Part 1 on successful login
        function onLoginSuccess() {
            loginPart1();
        }
    }
}
