import QtQuick
import qs.colors
import qs.config
import QtQuick.Controls

Column {
    id: root

    required property var service

    readonly property bool listing: !!service.wifiDevice && service.wifiEnabled

    Text {
        visible: root.listing && root.service.wifiNetworks.length === 0
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
        topPadding: 8
        bottomPadding: 8
        text: "Scanning for networks…"
        color: Colors.mutedForeground
        font.family: Config.font.family
        font.pixelSize: Config.font.sm
    }

    ListView {
        visible: root.listing && root.service.wifiNetworks.length > 0
        width: parent.width
        height: Math.min(contentHeight, 250)
        spacing: 3
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height
        model: root.service.wifiNetworks
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        delegate: WifiRow {
            width: ListView.view.width
            service: root.service
        }
    }
}
