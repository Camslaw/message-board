import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    color: "#424549"
    title: "Message Board"

    StackView {
        id: stackView
        anchors.fill: parent

        initialItem: LoginScreen { // Start with the login screen
            onLoginSuccess: stackView.push(mainApp)
        }

        Component {
            id: mainApp
            MessageBoard {
                onSignOut: {
                    stackView.pop()
                }
            }
        }
    }
}
