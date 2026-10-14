import QtQuick
import qs.colors
import qs.config
import Quickshell

Item {
    id: root

    property bool barOnRight: false
    property int gap: Config.spacing.sm

    implicitWidth: Config.sizes.button
    implicitHeight: Config.sizes.button

    // ---------------- open / close ----------------
    property bool opened: false
    property double lastClosed: 0

    function toggle() {
        if (opened) {
            close();
            return;
        }
        // The focus grab dismisses the popup on the press that lands on this button;
        // without this guard the same click would immediately reopen it.
        if (Date.now() - lastClosed < 300)
            return;
        opened = true;
    }
    function close() {
        opened = false;
    }

    onOpenedChanged: {
        if (opened) {
            hideTimer.stop();
            place();
            popup.visible = true;
        } else {
            lastClosed = Date.now();
            hideTimer.restart();   // keep the window alive until the close animation ends
        }
    }

    Timer {
        id: hideTimer
        interval: panel.duration + 20
        onTriggered: popup.visible = false
    }

    // ---------------- logic ----------------
    NetworkService {
        id: net
        active: root.opened
    }
    LinkInfo {
        id: link
        active: root.opened
    }
    Connections {
        target: net
        function onActionFinished() {
            link.refresh();
        }
    }

    // ---------------- bar button ----------------
    Rectangle {
        anchors.fill: parent
        radius: Config.rounding.sm
        color: "transparent"

        SignalBars {
            anchors.centerIn: parent
            visible: net.kind !== "ethernet"
            level: net.connectedLevel
            activeColor: net.restricted ? Colors.error : Colors.foreground
            inactiveColor: Qt.alpha(Colors.foreground, net.kind === "disconnected" ? 0.45 : 0.25)
        }
        Text {
            anchors.centerIn: parent
            visible: net.kind === "ethernet"
            text: "LAN"
            color: net.restricted ? Colors.error : Colors.foreground
            font.family: Config.font.family
            font.pixelSize: Config.font.sm
            font.bold: true
        }
        MouseArea {
            id: btnArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggle()
        }
    }

    // ---------------- popup ----------------
    // Anchored to the bar's edge next to this button, so it sits beside the bar
    // (not over it), is clamped inside the screen, and closes on any click outside.
    property real anchorX: 0
    // Decided once per open so the anchored edge never changes while the popup resizes:
    // lower half of the bar -> popup bottom stays fixed and grows upward;
    // upper half -> popup top stays fixed and grows downward.
    property bool anchorBottom: false
    function place() {
        var w = root.QsWindow.window;
        var p = root.mapToItem(null, 0, 0);
        var winW = w ? w.width : p.x + root.width;
        var winH = w ? w.height : 0;
        anchorBottom = winH > 0 && (p.y + root.height / 2) > winH / 2;
        // rect is relative to this item and 1px wide; its near edge is the anchor point
        anchorX = barOnRight ? (-p.x - gap) : (winW - p.x + gap - 1);
    }

    PopupWindow {
        id: popup

        anchor.item: root
        anchor.rect.x: root.anchorX
        anchor.rect.y: 0
        anchor.rect.width: 1
        anchor.rect.height: root.height
        anchor.edges: (root.barOnRight ? Edges.Left : Edges.Right) | (root.anchorBottom ? Edges.Bottom : Edges.Top)
        anchor.gravity: (root.barOnRight ? Edges.Left : Edges.Right) | (root.anchorBottom ? Edges.Top : Edges.Bottom)
        // Slide only: Flip would jump the popup to the other side of the button when it grows.
        anchor.adjustment: PopupAdjustment.Slide

        implicitWidth: 380
        implicitHeight: panel.implicitHeight
        color: "transparent"
        visible: false

        // Light dismiss: click outside closes the popup (and keyboard focus goes to it).
        grabFocus: true

        // The grab can hide the popup on its own; keep `opened` in sync.
        onVisibleChanged: if (!visible && root.opened)
            root.opened = false

        NetworkPanel {
            id: panel
            anchors.fill: parent
            shown: root.opened
            slide: 10
            service: net
            link: link
            onCloseRequested: root.close()
        }
    }
}
