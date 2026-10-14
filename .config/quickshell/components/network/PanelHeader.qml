import QtQuick
import qs.colors
import qs.config

Item {
    id: root

    required property var service

    height: 44

    SignalBars {
        scale: 1.6
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: root.service.kind !== "ethernet"
        level: root.service.connectedLevel
        activeColor: root.service.restricted ? Colors.error : Colors.foreground
        inactiveColor: Colors.outlineVariant
    }
    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: root.service.kind === "ethernet"
        text: "LAN"
        color: Colors.foreground
        font.family: Config.font.family
        font.pixelSize: Config.font.md
        font.bold: true
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 44
        anchors.right: wifiSwitch.visible ? wifiSwitch.left : parent.right
        anchors.rightMargin: Config.spacing.lg
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            width: parent.width
            elide: Text.ElideRight
            text: {
                if (root.service.kind === "wifi" && root.service.connectedWifi)
                    return root.service.connectedWifi.name || "Wi-Fi";
                if (root.service.kind === "wifi")
                    return "Wi-Fi";
                if (root.service.kind === "ethernet")
                    return "Ethernet";
                return "Disconnected";
            }
            color: Colors.foreground
            font.family: Config.font.family
            font.pixelSize: Config.font.md
            font.bold: true
        }
        Text {
            width: parent.width
            elide: Text.ElideRight
            text: {
                if (root.service.connectivity === "portal")
                    return "Sign-in required";
                if (root.service.connectivity === "limited")
                    return "Limited internet access";
                if (root.service.kind === "disconnected")
                    return root.service.wifiEnabled ? "Not connected" : "Wi-Fi is off";
                return "Connected";
            }
            color: root.service.restricted ? Colors.error : Colors.mutedForeground
            font.family: Config.font.family
            font.pixelSize: Config.font.sm
        }
    }

    // Wi-Fi on/off switch
    Rectangle {
        id: wifiSwitch
        visible: root.service.canToggleWifi
        width: 44
        height: 24
        radius: 12
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        color: root.service.wifiEnabled ? Colors.primary : Colors.surfaceHighest
        border.color: root.service.wifiEnabled ? Colors.primary : Colors.outline

        Rectangle {
            width: 18
            height: 18
            radius: 9
            y: 3
            x: root.service.wifiEnabled ? parent.width - width - 3 : 3
            color: root.service.wifiEnabled ? Colors.primaryText : Colors.outline
            Behavior on x {
                NumberAnimation {
                    duration: 120
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.service.toggleWifi()
        }
    }
}
