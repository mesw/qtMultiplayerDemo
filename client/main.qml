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

    background: Rectangle { color: "#1a1a1a" }

    palette {
        window:           "#1a1a1a"
        windowText:       "#e8e8e8"
        button:           "#2d2d2d"
        buttonText:       "#e8e8e8"
        base:             "#2d2d2d"
        text:             "#e8e8e8"
        highlight:        "#41cd52"
        highlightedText:  "#ffffff"
        mid:              "#444444"
        dark:             "#111111"
        light:            "#3a3a3a"
    }

    property string playerInitials: ""

    CounterClient {
        id: client
        serverUrl: defaultServerUrl   // injected from main.cpp
    }

    Component.onCompleted: client.connectToServer()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24

        // Connection status — shows initials once entered, generic otherwise
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: {
                if (!client.connected) return "Connecting..."
                return root.playerInitials !== "" ? root.playerInitials + " connected" : "Connected"
            }
            color: client.connected ? "#4caf50" : "#ff9800"
            font.pixelSize: 14
        }

        // Leader display
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: client.leader !== "" ? "all glory to: " + client.leader : ""
            font.pixelSize: 16
        }

        // Counter display — always visible
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: client.counter
            font.pixelSize: 72
            font.bold: true
        }

        // Increment button — only after initials entered
        Button {
            Layout.alignment: Qt.AlignHCenter
            visible: root.playerInitials !== ""
            text: "+"
            font.pixelSize: 32
            enabled: client.connected
            onClicked: client.increment()
        }

        // Initials entry — shown until initials are set
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 12
            visible: root.playerInitials === ""

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: "Enter your initials to play"
                font.pixelSize: 14
                color: "#aaaaaa"
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                TextField {
                    id: initialsField
                    maximumLength: 3
                    validator: RegularExpressionValidator { regularExpression: /[A-Za-z]{0,3}/ }
                    font.pixelSize: 20
                    horizontalAlignment: Text.AlignHCenter
                    implicitWidth: 80
                    onTextChanged: text = text.toUpperCase()
                    Keys.onReturnPressed: if (initialsField.text.length === 3) playButton.clicked()
                }

                Button {
                    id: playButton
                    text: "Play"
                    font.pixelSize: 16
                    enabled: initialsField.text.length === 3
                    onClicked: {
                        root.playerInitials = initialsField.text.toUpperCase()
                        client.initials = root.playerInitials
                    }
                }
            }
        }
    }
}
