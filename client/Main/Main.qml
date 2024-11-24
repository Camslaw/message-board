import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 1280
    height: 720
    color: "#424549"
    title: "Message Board"

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: LoginScreen { // Start with the login screen
            onLoginPart1: stackView.push(part1App)
            onLoginPart2: stackView.push(part2App)
        }

        Component {
            id: part1App
            MessageBoard1 {
                onSignOut: stackView.pop()
            }
        }

        Component {
            id: part2App
            MessageBoard2 {
                onSignOut: stackView.pop()
            }
        }
    }
}
