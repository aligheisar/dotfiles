import Quickshell.Hyprland
import QtQuick
import qs.config
import qs.colors

Text {
    id: root
    color: Colors.foreground
    property string layout: "EN"

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === "activelayout") {
                root.updateLayoutFromEvent(event.data);
            }
        }
    }

    function transformLayout(layoutName) {
        //define custom shorteners for languages
        if (layoutName.includes("Persian"))
            return "FA";
        if (layoutName.includes("English"))
            return "EN";
        //if no shorteners defined default to first two letter
        return layoutName.substring(0, 2).toUpperCase();
    }

    function updateLayout(layoutName) {
        const newLayout = transformLayout(layoutName);
        if (newLayout !== root.layout) {
            root.layout = newLayout;
        }
    }

    function updateLayoutFromEvent(eventData) {
        const parts = eventData.split(',');
        if (parts.length > 1) {
            updateLayout(parts[1]);
        }
    }

    anchors.horizontalCenter: parent.horizontalCenter
    text: layout
    font.family: Config.font.family
    font.pixelSize: Config.font.base
    font.weight: Font.ExtraLight
}
