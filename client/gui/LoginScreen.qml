import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: stackView.width
    height: stackView.height
    
    signal loginPart1()
    signal loginPart2()

    property string partSelection: ""

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
                    } else {
                        errorMessage.text = ""
                        partSelection = "part1";
                        backend.handleLoginRequest1(usernameInput.text, "public")
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
                        partSelection = "part2";
                        backend.current_user = usernameInput.text
                        backend.handleLoginRequest2(usernameInput.text)
                    }
                }
            }
            Button {
                background: Rectangle {
                    radius: 8
                }
                text: "Exit"
                onClicked: {
                    Qt.quit();
                }
            }
        }
    }
    Connections {
        target: backend

        function onLoginError(message) {
            errorMessage.text = message;
        }

        function onLoginSuccess() {
            if (partSelection === "part1") {
                loginPart1()
            } else if (partSelection === "part2") {
                loginPart2()
            }
        }
    }
}
