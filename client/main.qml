import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtMultiplayerClient

ApplicationWindow {
    id: root
    visible: true
    width: 420
    height: 480
    minimumHeight: 480
    title: "Qt Multiplayer Demo"
    color: "#1a1a2e"

    property string playerInitials: ""

    CounterClient {
        id: client
        serverUrl: defaultServerUrl
    }

    // Components for the Loader (non-visual, defined outside the layout)
    Component {
        id: initialsComponent
        RowLayout {
            spacing: 8

            TextField {
                id: initialsField
                Layout.preferredWidth: 80
                maximumLength: 3
                validator: RegularExpressionValidator { regularExpression: /[A-Za-z]{0,3}/ }
                font.pixelSize: 18
                horizontalAlignment: Text.AlignHCenter
                placeholderText: "AAA"
                placeholderTextColor: "#666680"
                color: "#e0e0e0"
                onTextChanged: text = text.toUpperCase()

                background: Rectangle {
                    color: "#2a2a3e"
                    border.color: initialsField.activeFocus ? "#5c8dd6" : "#3a3a5e"
                    border.width: 1
                    radius: 4
                }

                contentItem: TextInput {
                    text: initialsField.text
                    font: initialsField.font
                    color: initialsField.color
                    horizontalAlignment: initialsField.horizontalAlignment
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 8
                    rightPadding: 8
                    topPadding: 4
                    bottomPadding: 4
                }
            }

            Button {
                text: "Play"
                font.pixelSize: 15
                enabled: initialsField.text.length >= 1
                onClicked: {
                    root.playerInitials = initialsField.text.toUpperCase()
                    client.initials = root.playerInitials
                    client.connectToServer()
                    initialsLoader.sourceComponent = playingComponent
                }

                contentItem: Text {
                    text: parent.text
                    font: parent.font
                    color: parent.enabled ? "#e0e0e0" : "#555566"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: parent.enabled ? (parent.pressed ? "#4a7bc4" : "#5c8dd6") : "#2a2a3e"
                    radius: 4
                }
            }
        }
    }

    Component {
        id: playingComponent
        Text {
            text: "playing as: " + root.playerInitials
            color: "#888899"
            font.pixelSize: 14
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        width: 340

        // Status label
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.playerInitials === ""
                  ? "Enter initials to play"
                  : (client.connected ? root.playerInitials + " connected" : "Connecting...")
            color: root.playerInitials === ""
                   ? "#888899"
                   : (client.connected ? "#4caf50" : "#ff9800")
            font.pixelSize: 14
        }

        // Leader
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "all glory to: " + (client.leader !== "" ? client.leader : "—")
            color: client.leader !== "" ? "#e0e0e0" : "#888899"
            font.pixelSize: 16
        }

        // Counter
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: client.counter
            color: "#e0e0e0"
            font.pixelSize: 72
            font.bold: true
        }

        // Increment button
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: "+"
            font.pixelSize: 32
            enabled: root.playerInitials !== "" && client.connected
            onClicked: client.increment()

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: parent.enabled ? "#e0e0e0" : "#555566"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                implicitWidth: 64
                implicitHeight: 64
                color: parent.enabled ? (parent.pressed ? "#4a7bc4" : "#5c8dd6") : "#2a2a3e"
                radius: 8
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#3a3a5e"
        }

        // Initials row / playing label
        Loader {
            id: initialsLoader
            Layout.alignment: Qt.AlignHCenter
            sourceComponent: initialsComponent
        }

        // Privacy disclaimer
        Text {
            Layout.fillWidth: true
            text: "Your initials are shown temporarily during this session. No personal data, IP addresses, or identifying information is stored."
            color: "#666680"
            font.pixelSize: 11
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
