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

    CounterClient {
        id: client
        serverUrl: defaultServerUrl   // injected from main.cpp
        Component.onCompleted: connectToServer()
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24

        // Connection status
        Label {
            Layout.alignment: Qt.AlignHCenter
            text: client.connected ? "Connected" : "Connecting..."
            color: client.connected ? "#4caf50" : "#ff9800"
            font.pixelSize: 14
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
