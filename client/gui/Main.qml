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

        delegate: Item {}

        initialItem: loginScreen

        Component {
            id: loginScreen
            LoginScreen {
                onLoginPart1: stackView.push(part1App)
                onLoginPart2: stackView.push(part2App)
            }
        }

        Component {
            id: part1App
            MessageBoard1 {
                onSignOut1: {
                    console.debug("Before pop: " + stackView.depth)  // Check the stack depth
                    stackView.pop()
                    console.debug("After pop: " + stackView.depth)  // Confirm if stackView returned to LoginScreen
                }
            }
        }

        Component {
            id: part2App
            MessageBoard2 {
                onSignOut2: {
                    console.debug("Before pop: " + stackView.depth)  // Check the stack depth
                    stackView.pop()
                    console.debug("After pop: " + stackView.depth)  // Confirm if stackView returned to LoginScreen
                }
            }
        }
    }
}
