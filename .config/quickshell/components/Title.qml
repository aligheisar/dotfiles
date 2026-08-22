import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell
import QtQuick
import qs.config
import qs.colors

Column {
    id: root
    anchors.centerIn: parent
    spacing: Config.spacing.md

    readonly property var activeWorkspace: Hyprland.focusedWorkspace
    readonly property var activeToplevel: Hyprland.activeToplevel

    readonly property var activeWindow: {
        const workspace = activeWorkspace;
        const toplevel = activeToplevel;

        if (!workspace || !toplevel)
            return null;

        // The active toplevel is only valid for this widget
        // if it belongs to the currently focused workspace.
        if (toplevel.workspace !== workspace)
            return null;

        return toplevel;
    }

    IconImage {
        anchors.horizontalCenter: parent.horizontalCenter
        width: Config.sizes.titleIcon
        height: Config.sizes.titleIcon

        readonly property string iconSource: {
            const window = root.activeWindow;

            if (!window)
                return "";

            const appId = window.wayland?.appId;
            const wmClass = window.lastIpcObject?.class;
            const identifier = appId || wmClass;

            if (!identifier)
                return "";

            const entry = DesktopEntries.heuristicLookup(identifier);

            if (!entry || !entry.icon)
                return "";

            return Quickshell.iconPath(entry.icon, true);
        }

        visible: iconSource !== ""
        source: iconSource
    }

    Item {
        id: titleContainer
        anchors.horizontalCenter: parent.horizontalCenter
        width: title.height
        height: title.width

        Text {
            id: title

            width: Math.min(implicitWidth, 170)
            height: implicitHeight

            anchors.centerIn: parent

            color: Colors.foreground
            text: root.activeWindow?.title || "Desktop"
            font.pixelSize: Config.font.base

            elide: Text.ElideRight
            maximumLineCount: 1
            wrapMode: Text.NoWrap

            rotation: 90
        }
    }
}
