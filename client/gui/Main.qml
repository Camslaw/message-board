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
        width: parent.width
        height: parent.height

        Component.onCompleted: stackView.push(loginScreen);

        Component {
            id: loginScreen
            LoginScreen {
                onLoginPart1: stackView.push(part1App);
                onLoginPart2: stackView.push(part2App);
            }
        }

        Component {
            id: part1App
            MessageBoard1 {
                onSignOut1: {
                    stackView.clear();
                    stackView.push(loginScreen);
                }
            }
        }

        Component {
            id: part2App
            MessageBoard2 {
                onSignOut2: {
                    stackView.clear();
                    stackView.push(loginScreen);
                }
            }
        }
    }
}
