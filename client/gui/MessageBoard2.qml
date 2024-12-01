import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: stackView.width
    height: stackView.height

    signal signOut2()
    signal uiReady()

    Component.onCompleted: {
        if (!uiInitialized) {
            console.log("DEBUG: Connecting to backend");
            uiInitialized = true;
            backend.uiReady(group);
        }
    }

    Row {
        anchors.fill: parent
        spacing: 10

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
                                    backend.handleJoinGroup(name);
                                    groupModel.setProperty(index, "joined", true);
                                    messageBox.text += `Welcome to ${name}!\n`;
                                    backend.requestUserList(name)
                                } else {
                                    backend.handleLeaveGroup(name);
                                    groupModel.setProperty(index, "joined", false);
                                    messageBox.text += `You have left ${name}.\n`;
                                }
                            }
                        }
                        
                        Text {
                            text: name
                            color: joined ? "lightgreen" : "white"  // Change color on joining/leaving
                            font.pointSize: 14
                        }
                    }
                }
            }

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

                TextField {
                    id: groupNameInput
                    background: Rectangle {
                        color: "#585c63"
                        radius: 10
                    }
                    color: "white"
                    placeholderText: "Enter group name"
                }

                Button {
                    background: Rectangle {
                        radius: 8
                    }
                    text: "Check users in group"
                    onClicked: {
                        let validGroups = ["tutoring", "announcements", "homework", "networking", "wellness"];
                        let inputGroup = groupNameInput.text.trim();

                        if (inputGroup === "") {
                            errorMessage.text = "Please enter a group name.";
                        } else if (validGroups.includes(inputGroup)) {
                            // Iterate through groupModel to find the group
                            let groupIndex = -1;
                            for (let i = 0; i < groupModel.count; i++) {
                                if (groupModel.get(i).name === inputGroup) {
                                    groupIndex = i;
                                    break;
                                }
                            }
                            if (groupIndex >= 0 && groupModel.get(groupIndex).joined) {
                                backend.requestUserList(inputGroup);
                                errorMessage.text = ""; // Clear previous error
                            } else {
                                errorMessage.text = "You must be a part of the group to check its members.";
                            }
                        } else {
                            errorMessage.text = `"${inputGroup}" is not a valid group.`;
                        }
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
                    if (backend.isInGroup()) {
                        backend.handleLogoutRequestGroup(backend.current_group);
                        messageBox.text = "";
                    } else {
                        backend.handleLogoutRequestSolo(backend.current_user);
                        messageBox.text = "";
                    }
                    signOut2();
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
                    text: "Welcome to the Message Board!\n"
                }
            }

            Column {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9

                // Group Name Input
                Row {
                    spacing: 10
                    Text {
                        text: "Group Name:"
                        color: "white"
                        font.pointSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: groupNameField
                        background: Rectangle {
                            color: "#585c63"
                            radius: 10
                        }
                        color: "white"
                        placeholderText: "Enter group name"
                        width: parent.width * 0.6
                    }
                }

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

                Text {
                    id: errorSendMessage
                    text: ""
                    color: "red"
                    font.pointSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    visible: text.length > 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    background: Rectangle {
                        radius: 8
                    }
                    text: "Send message"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        let validGroups = ["tutoring", "announcements", "homework", "networking", "wellness"];
                        let groupName = groupNameField.text.trim();
                        let subject = subjectField.text.trim();
                        let body = messageBodyField.text.trim();

                        if (groupName === "" || subject === "" || body === "") {
                            errorSendMessage.text = "Error: All fields are required.";
                        } else if (!validGroups.includes(groupName)) {
                            errorSendMessage.text = `Error: "${groupName}" is not a valid group.`;
                        } else {
                            let isUserinGroup = false;
                            for (let i = 0; i < groupModel.count; i++) {
                                if (groupModel.get(i).name === groupName && groupModel.get(i).joined) {
                                    isUserinGroup = true;
                                    break;
                                }
                            }

                            if (isUserinGroup) {
                                backend.postMessage(groupName, subject, body);
                                
                                // Clear any previous error
                                errorSendMessage.text = "";
                                
                                // Clear fields after sending
                                groupNameField.text = "";
                                subjectField.text = "";
                                messageBodyField.text = "";
                            } else {
                                errorSendMessage.text = `Error: You must be a member of "${groupName}" to post a message.`;
                            }
                        }
                    }
                }
            }

            Column {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 0.9

                Row {
                    spacing: 10
                    Text {
                        text: "Group Name:"
                        color: "white"
                        font.pointSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextField {
                        id: groupNameFieldRead
                        background: Rectangle {
                            color: "#585c63"
                            radius: 10
                        }
                        color: "white"
                        placeholderText: "Enter group name"
                        width: parent.width * 0.6
                    }
                }

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

                Text {
                    id: errorReadMessage
                    text: ""
                    color: "red"
                    font.pointSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    visible: text.length > 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Button {
                    background: Rectangle {
                        radius: 8
                    }
                    text: "Read message"
                    anchors.horizontalCenter: parent.horizontalCenter
                    onClicked: {
                        let validGroups = ["tutoring", "announcements", "homework", "networking", "wellness"];
                        let groupName = groupNameFieldRead.text.trim();
                        let messageId = messageBodyFieldRead.text.trim();

                        if (groupName === "" || messageId === "") {
                            errorReadMessage.text = "Error: All fields are required.";
                        } else if (!validGroups.includes(groupName)) {
                            errorReadMessage.text = `Error: "${groupName}" is not a valid group.`;
                        } else {
                            let isUserinGroup = false;
                            for (let i = 0; i < groupModel.count; i++) {
                                if (groupModel.get(i).name === groupName && groupModel.get(i).joined) {
                                    isUserinGroup = true;
                                    break;
                                }
                            }

                            if (isUserinGroup) {
                                backend.getMessageById(messageId);
                                
                                // Clear any previous error
                                errorReadMessage.text = "";

                                // Clear fields after sending
                                groupNameFieldRead.text = "";
                                messageBodyFieldRead.text = "";
                            } else {
                                errorReadMessage.text = `Error: You must be a member of "${groupName}" to this message.`;
                            }
                        }
                    }
                }
            }
        }
    }

    ListModel {
        id: groupModel
        ListElement { name: "tutoring"; joined: false }
        ListElement { name: "announcements"; joined: false }
        ListElement { name: "homework"; joined: false }
        ListElement { name: "networking"; joined: false }
        ListElement { name: "wellness"; joined: false }
    }

    Connections {
        target: backend
        function onNotification(message) {
            try {
                if (message.startsWith("Message ID:")) {
                    messageBox.text += `${message}\n`;
                } else {
                    messageBox.text += `${message}\n`;
                }
            } catch (e) {
                console.error("Error handling notification in QML:", e);
            }
        }

        function onMessageRetrieved(message) {
        try {
            // Split the message into lines
            let lines = message.split("\n");
            
            // Validate if the message has both "Message ID" and "Content"
            let idLine = lines.find(line => line.startsWith("Message ID:"));
            let contentLine = lines.find(line => line.startsWith("Content:"));

            if (idLine && contentLine) {
                // Extract the values
                let messageId = idLine.split(":")[1].trim();
                let content = contentLine.split(":")[1].trim();

                // Append the formatted message to the message box
                messageBox.text += `Message ${messageId} content: ${content}\n`;
            } else {
                console.log("Invalid message format, ignoring.");
            }
        } catch (e) {
            console.error("Error handling retrieved message in QML:", e);
        }
    }

        function onRecentMessageReceived2(message) {
            console.log("Recent message received in QML:", message);
            messageBox.text += `[Recent] ${message}\n`;
        }
    }
}
