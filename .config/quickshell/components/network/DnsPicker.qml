import QtQuick
import qs.colors
import qs.config

Column {
    id: root

    required property var link

    spacing: Config.spacing.md

    Text {
        text: "DNS provider"
        color: Colors.mutedForeground
        font.family: Config.font.family
        font.pixelSize: Config.font.sm
        font.bold: true
    }

    Row {
        id: chips
        width: parent.width
        spacing: 6

        Repeater {
            model: root.link.dnsProviders
            delegate: Rectangle {
                id: chip
                required property string modelData
                readonly property bool current: root.link.dnsProvider === modelData

                width: (chips.width - chips.spacing * 2) / 3
                height: 30
                radius: Config.rounding.sm
                color: current ? Colors.primaryContainer : (area.containsMouse ? Qt.alpha(Colors.surfaceHighest, 0.6) : "transparent")
                border.color: current ? Colors.primary : Colors.outlineVariant
                opacity: root.link.pendingDns !== "" && root.link.pendingDns !== modelData ? 0.5 : 1

                Text {
                    anchors.centerIn: parent
                    text: chip.modelData
                    color: chip.current ? Colors.primaryContainerText : Colors.foreground
                    font.family: Config.font.family
                    font.pixelSize: Config.font.sm
                }
                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.link.setDns(chip.modelData)
                }
            }
        }
    }

    Text {
        visible: root.link.dnsProvider === "Custom"
        text: "This connection uses custom DNS servers."
        color: Colors.mutedForeground
        font.family: Config.font.family
        font.pixelSize: Config.font.sm
    }
}
