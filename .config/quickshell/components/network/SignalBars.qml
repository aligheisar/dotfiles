import QtQuick
import qs.colors
import qs.config

Item {
    id: root

    property int level: 0
    property color activeColor: Colors.foreground
    property color inactiveColor: Colors.outlineVariant

    implicitWidth: Config.sizes.barIcon
    implicitHeight: Config.sizes.barIcon

    Row {
        spacing: 2
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            id: repeater
            model: 4
            Rectangle {
                required property int index
                width: 2
                height: (3 + index * 2)
                x: index * 1
                y: root.height - height
                radius: 1
                color: index < root.level ? root.activeColor : root.inactiveColor
            }
        }
    }
}
