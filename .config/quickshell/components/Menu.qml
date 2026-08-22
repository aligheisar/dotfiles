pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.config
import qs.colors

PopupWindow {
    id: root
    required property var menuHandle
    property var rootMenu: null
    readonly property var effectiveRoot: rootMenu || root

    // true while the pointer is anywhere over this menu's content
    readonly property bool hovered: hoverHandler.hovered

    implicitWidth: bg.implicitWidth
    implicitHeight: bg.implicitHeight
    color: "transparent"
    grabFocus: true

    onVisibleChanged: {
        if (!visible) {
            closeAllSubmenus();
        } else {
            focusGrabber.forceActiveFocus();
        }
    }

    function closeAllSubmenus() {
        for (let i = 0; i < col.children.length; i++) {
            const loader = col.children[i];
            if (loader.item && loader.item.closeSubmenu)
                loader.item.closeSubmenu();
        }
    }

    QsMenuOpener {
        id: opener
        menu: root.menuHandle
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        implicitWidth: col.implicitWidth + Config.spacing.sm * 2
        implicitHeight: col.implicitHeight + Config.spacing.sm * 2
        color: Colors.surfaceHighest
        radius: Config.rounding.md

        HoverHandler {
            id: hoverHandler
        }

        Item {
            id: focusGrabber
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.effectiveRoot.visible = false
        }

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: Config.spacing.sm
            spacing: 1

            Repeater {
                model: opener.children
                delegate: Loader {
                    id: entryLoader
                    required property var modelData
                    property var entry: modelData
                    Layout.fillWidth: true
                    sourceComponent: modelData.isSeparator ? sepComp : itemComp
                }
            }
        }
    }

    Component {
        id: itemComp
        Rectangle {
            id: menuItem
            property var entry: parent.entry // qmllint disable missing-property
            property var submenuInstance: null
            implicitWidth: rowLayout.implicitWidth + 16
            implicitHeight: 28
            radius: Config.rounding.sm
            color: mouse.containsMouse && entry.enabled ? Colors.surface : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            function openSubmenu() {
                if (submenuInstance || !entry.hasChildren)
                    return;
                const comp = Qt.createComponent(Qt.resolvedUrl("Menu.qml"));
                if (comp.status === Component.Error) {
                    console.warn("Menu.qml: failed to load submenu:", comp.errorString());
                    return;
                }
                const pos = menuItem.mapToItem(null, menuItem.width, 0);
                submenuInstance = comp.createObject(menuItem, {
                    menuHandle: entry,
                    rootMenu: root.effectiveRoot,
                    visible: true
                });
                submenuInstance.anchor.window = root;
                submenuInstance.anchor.rect.x = pos.x;
                submenuInstance.anchor.rect.y = pos.y;
            }

            function closeSubmenu() {
                if (submenuInstance) {
                    submenuInstance.destroy();
                    submenuInstance = null;
                }
            }

            RowLayout {
                id: rowLayout
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                spacing: 6

                Rectangle {
                    visible: menuItem.entry.buttonType !== QsMenuButtonType.None
                    Layout.preferredWidth: 12
                    Layout.preferredHeight: 12
                    radius: menuItem.entry.buttonType === QsMenuButtonType.RadioButton ? 6 : 3
                    border.width: 2
                    border.color: Colors.outline
                    color: menuItem.entry.checkState === Qt.Checked ? Colors.secondary : "transparent"
                }

                IconImage {
                    visible: menuItem.entry.icon !== ""
                    source: menuItem.entry.icon
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                }

                Text {
                    Layout.fillWidth: true
                    text: menuItem.entry.text
                    color: menuItem.entry.enabled ? Colors.foreground : Colors.outline
                    elide: Text.ElideRight
                }

                Text {
                    visible: menuItem.entry.hasChildren
                    text: "\u203a"
                    color: Colors.foreground
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: menuItem.entry.enabled
                cursorShape: menuItem.entry.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: {
                    if (!menuItem.entry.hasChildren) {
                        menuItem.entry.triggered();
                        root.effectiveRoot.visible = false;
                    }
                }
                onContainsMouseChanged: {
                    if (!menuItem.entry.hasChildren)
                        return;
                    if (containsMouse) {
                        closeTimer.stop();
                        submenuTimer.restart();
                    } else {
                        submenuTimer.stop();
                        closeTimer.restart();
                    }
                }
            }

            Timer {
                id: submenuTimer
                interval: 150
                onTriggered: menuItem.openSubmenu()
            }

            Timer {
                id: closeTimer
                interval: 300
                onTriggered: {
                    const submenuHovered = menuItem.submenuInstance && menuItem.submenuInstance.hovered;
                    if (!mouse.containsMouse && !submenuHovered)
                        menuItem.closeSubmenu();
                }
            }
        }
    }

    Component {
        id: sepComp
        Rectangle {
            implicitWidth: 1
            implicitHeight: 1
            color: Colors.outline
        }
    }
}
