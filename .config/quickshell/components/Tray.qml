import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts
import qs.configs

Rectangle {
    id: root
    color: Config.colors.trayBackground
    implicitWidth: col.implicitWidth + Config.spacing.md * 2
    implicitHeight: col.implicitHeight + Config.spacing.md * 2

    radius: Config.rounding.full
    visible: SystemTray.items.values.length > 0

    ColumnLayout {
        id: col
        spacing: Config.spacing.lg
        visible: SystemTray.items.values.length > 0
        anchors.fill: parent
        anchors.margins: Config.spacing.md

        Repeater {
            model: SystemTray.items

            delegate: TrayItem {
                required property var modelData
                item: modelData
            }
        }
    }
}
