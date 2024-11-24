import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    anchors.fill: parent

    signal signOut()  // Signal to notify when the user wants to sign out

    function addTab(tabName) {
        // Check if the tab already exists
        for (var i = 0; i < tabBar.contentItem.children.length; i++) {
            if (tabBar.contentItem.children[i].text === tabName) {
                return; // Tab already exists
            }
        }

        // Add a new tab dynamically
        tabBar.contentItem.children.push(Qt.createQmlObject(`
            import QtQuick.Controls 2.15;
            TabButton {
                text: "` + tabName + `";
                checkable: true;
                onClicked: {
                    buttonGroup.checkedButton = this;
                    stackView.clear()
                    stackView.push(Qt.createQmlObject(\`
                        import QtQuick 2.15;
                        import QtQuick.Controls 2.15;
                        Column {
                            spacing: 10
                            anchors.fill: parent
                            anchors.margins: 10

                            // Message Display Area
                            TextArea {
                                wrapMode: Text.Wrap;
                                readOnly: true;
                                font.pointSize: 14;
                                color: "white";
                                width: parent.width * 0.9;
                                height: parent.height * 0.6;
                                background: Rectangle { color: "#585c63"; radius: 8 }
                                text: "Welcome to the ` + tabName + ` group!";
                            }

                            // Message Input and Send Button
                            Row {
                                spacing: 10
                                width: parent.width * 0.9

                                TextField {
                                    id: messageInput
                                    background: Rectangle {
                                        color: "#585c63"
                                        radius: 10
                                    }
                                    color: "white"
                                    placeholderText: "Type your message here..."
                                    width: parent.width * 0.8
                                }

                                Button {
                                    text: "Send"
                                    background: Rectangle {
                                        radius: 8
                                    }
                                    onClicked: {
                                        if (messageInput.text.trim() !== "") {
                                            console.log("You: " + messageInput.text.trim());
                                            messageInput.text = ""; // Clear the input field
                                        }
                                    }
                                }
                            }
                        }
                    \`, stackView));
                }
            }
        `, tabBar.contentItem));
    }

    function removeTab(tabName) {
        for (var i = 0; i < tabBar.contentItem.children.length; i++) {
            if (tabBar.contentItem.children[i].text === tabName) {
                const wasActive = buttonGroup.checkedButton && buttonGroup.checkedButton.text === tabName;

                // Remove the tab from the TabBar
                tabBar.contentItem.children[i].destroy();

                // Handle if the removed tab was active
                if (wasActive) {
                    stackView.clear();

                    // Automatically activate the lowest-indexed tab if any remain
                    if (tabBar.contentItem.children.length > 0) {
                        buttonGroup.checkedButton = null; // Clear the current checked button
                        tabBar.contentItem.children[0].checked = true; // Activate the first tab
                        tabBar.contentItem.children[0].onClicked();
                    }
                }

                return; // Exit after removing the tab
            }
        }
    }

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
                                if (joined) {
                                    addTab(name); // Add a new tab for the group
                                } else {
                                    removeTab(name); // Remove the tab when leaving
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

            // TabBar and StackView for Tabs
            TabBar {
                id: tabBar
                width: parent.width

                ButtonGroup {
                    id: buttonGroup
                }
            }

            StackView {
                id: stackView
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9
                height: parent.height * 0.7
                initialItem: Rectangle { 
                    color: "transparent" 
                }
            }

            Component.onCompleted: {
                addTab("public"); // Initialize the public tab on load

                // Automatically select the public tab
                // if (tabBar.contentItem.children.length > 0) {
                //     tabBar.contentItem.children[0].checked = true;
                //     tabBar.contentItem.children[0].onClicked();
                // }

                // Automatically activate the "public" tab after adding it
                stackView.push(Qt.createQmlObject(`
                    import QtQuick 2.15;
                    import QtQuick.Controls 2.15;
                    Column {
                        spacing: 10
                        anchors.fill: parent
                        anchors.margins: 10

                        // Message Display Area
                        TextArea {
                            wrapMode: Text.Wrap;
                            readOnly: true;
                            font.pointSize: 14;
                            color: "white";
                            width: parent.width * 0.9;
                            height: parent.height * 0.6;
                            background: Rectangle { color: "#585c63"; radius: 8 }
                            text: "Welcome to the public group!";
                        }

                        // Message Input and Send Button
                        Row {
                            spacing: 10
                            width: parent.width * 0.9

                            TextField {
                                id: messageInput
                                background: Rectangle {
                                    color: "#585c63"
                                    radius: 10
                                }
                                color: "white"
                                placeholderText: "Type your message here..."
                                width: parent.width * 0.8
                            }

                            Button {
                                text: "Send"
                                background: Rectangle {
                                    radius: 8
                                }
                                onClicked: {
                                    if (messageInput.text.trim() !== "") {
                                        console.log("You: " + messageInput.text.trim());
                                        messageInput.text = ""; // Clear the input field
                                    }
                                }
                            }
                        }
                    }
                `, stackView));
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
