pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import qs.config

MouseArea {
    id: trayDelegate
    required property var item

    implicitWidth: Config.sizes.trayIcon
    implicitHeight: Config.sizes.trayIcon

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    onClicked: mouse => {
        if (mouse.button === Qt.LeftButton) {
            item.activate();
        } else if (mouse.button === Qt.RightButton) {
            if (item.hasMenu) {
                menuAnchor.open();
            }
        } else if (mouse.button === Qt.MiddleButton) {
            item.secondaryActivate();
        }
    }

    Image {
        id: trayIcon
        anchors.centerIn: parent
        source: trayDelegate.item.icon
        width: Config.sizes.trayIcon
        height: Config.sizes.trayIcon
        sourceSize: Qt.size(Config.sizes.trayIcon, Config.sizes.trayIcon)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    QsMenuAnchor {
        id: menuAnchor
        menu: trayDelegate.item.menu
        anchor.window: trayDelegate.QsWindow.window
        anchor.onAnchoring: {
            const widgetRect = trayDelegate.QsWindow.mapFromItem(trayDelegate, 0, trayDelegate.height, trayDelegate.width, trayDelegate.height);
            menuAnchor.anchor.rect = widgetRect;
        }
    }
}
