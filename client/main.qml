import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultiplayerClient

ApplicationWindow {
    id: root
    visible: true
    width: 400
    height: 300
    title: "Qt Multiplayer Demo"

    property string playerInitials: ""

    CounterClient {
        id: client
        serverUrl: defaultServerUrl   // injected from main.cpp
    }

    // Screen 1 — Initials entry
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24
        visible: root.playerInitials === ""

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: "Enter your initials"
            font.pixelSize: 20
        }

        TextField {
            id: initialsField
            Layout.alignment: Qt.AlignHCenter
            maximumLength: 3
            validator: RegularExpressionValidator { regularExpression: /[A-Za-z]{0,3}/ }
            font.pixelSize: 24
            horizontalAlignment: Text.AlignHCenter
            onTextChanged: text = text.toUpperCase()
        }

        Button {
            Layout.alignment: Qt.AlignHCenter
            text: "Play"
            font.pixelSize: 18
            enabled: initialsField.text.length === 3
            onClicked: {
                root.playerInitials = initialsField.text.toUpperCase()
                client.initials = root.playerInitials
                client.connectToServer()
            }
        }
    }

    // Screen 2 — Counter
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24
        visible: root.playerInitials !== ""

        // Connection status
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: client.connected ? root.playerInitials + " connected" : "Connecting..."
            color: client.connected ? "#4caf50" : "#ff9800"
            font.pixelSize: 14
        }

        // Leader display
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: client.leader !== "" ? "all glory to: " + client.leader : ""
            font.pixelSize: 16
        }

        // Counter display
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: client.counter
            font.pixelSize: 72
            font.bold: true
        }

        // Increment button
        Button {
            Layout.alignment: Qt.AlignHCenter
            text: "+"
            font.pixelSize: 32
            enabled: client.connected
            onClicked: client.increment()
        }
    }
}
