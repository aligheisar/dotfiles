import QtQuick
import qs.colors
import qs.config

// Inline passphrase field. The text is owned by the caller so it survives row rebuilds.
Rectangle {
    id: root

    property bool busy: false
    property string value: ""

    signal edited(string value)
    signal submitted(string value)
    signal cancelled()

    height: 32
    radius: Config.rounding.sm
    color: Colors.surfaceLow
    border.color: input.activeFocus ? Colors.primary : Colors.outlineVariant

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 74
        verticalAlignment: TextInput.AlignVCenter
        echoMode: TextInput.Password
        color: Colors.foreground
        font.family: Config.font.family
        font.pixelSize: Config.font.base
        clip: true
        enabled: !root.busy
        text: root.value

        onTextChanged: if (text !== root.value)
            root.edited(text)
        onAccepted: if (text.length > 0)
            root.submitted(text)
        Keys.onEscapePressed: root.cancelled()
        onVisibleChanged: if (visible)
            Qt.callLater(forceActiveFocus)
        Component.onCompleted: if (visible)
            Qt.callLater(forceActiveFocus)

        Text {
            visible: input.text === ""
            anchors.verticalCenter: parent.verticalCenter
            text: "Password"
            color: Colors.mutedForeground
            font: input.font
        }
    }

    Rectangle {
        readonly property bool ready: input.text.length > 0 && !root.busy
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 62
        height: 24
        radius: Config.rounding.xs
        color: ready ? Colors.primary : Colors.surfaceHighest

        Text {
            anchors.centerIn: parent
            text: root.busy ? "…" : "Connect"
            color: parent.ready ? Colors.primaryText : Colors.mutedForeground
            font.family: Config.font.family
            font.pixelSize: Config.font.sm
            font.bold: true
        }
        MouseArea {
            anchors.fill: parent
            enabled: parent.ready
            cursorShape: Qt.PointingHandCursor
            onClicked: root.submitted(input.text)
        }
    }
}
