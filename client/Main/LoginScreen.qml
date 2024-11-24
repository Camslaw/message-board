import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    signal loginSuccess()  // Signal to notify successful login

    anchors.fill: parent

    // Mock username list
    property var takenUsernames: ["admin", "user1", "guest"]

    Column {
        anchors.centerIn: parent
        spacing: 20

        Text {
            text: "Welcome to the Message Board!\n"
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

        Button {
            background: Rectangle {
                radius: 8
            }
            text: "Login"
            onClicked: {
                if (usernameInput.text === "") {
                    errorMessage.text = "Username cannot be empty."
                } else if (takenUsernames.includes(usernameInput.text)) {
                    errorMessage.text = "Username already taken."
                } else {
                    errorMessage.text = ""
                    loginSuccess()  // Emit the signal to proceed to the main app
                }
            }
        }

        Text {
            id: errorMessage
            color: "red"
            font.pointSize: 14
        }
    }
}
