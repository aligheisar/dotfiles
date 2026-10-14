import QtQuick
import qs.colors
import qs.config

Column {
    id: root

    required property var link

    spacing: 5

    readonly property var rows: {
        var d = link.details;
        var hasRx = d.rx_bytes !== undefined, hasTx = d.tx_bytes !== undefined;
        return [
            {
                l1: "IP address",
                v1: d.ip || "--",
                l2: "Gateway",
                v2: d.gateway || "--"
            },
            {
                l1: "Receiving",
                v1: hasRx ? link.formatRate(link.downRate) : "--",
                l2: "Sending",
                v2: hasTx ? link.formatRate(link.upRate) : "--"
            },
            {
                l1: "Downloaded",
                v1: hasRx ? link.formatBytes(parseFloat(d.rx_bytes)) : "--",
                l2: "Uploaded",
                v2: hasTx ? link.formatBytes(parseFloat(d.tx_bytes)) : "--"
            }
        ];
    }

    Repeater {
        model: root.rows
        delegate: Item {
            id: cell
            required property var modelData
            width: root.width
            height: 18

            Label {
                x: 0
                width: 76
                text: cell.modelData.l1
            }
            Value {
                x: 76
                width: cell.width / 2 - 82
                text: cell.modelData.v1
            }
            Label {
                x: cell.width / 2
                width: 64
                text: cell.modelData.l2
            }
            Value {
                x: cell.width / 2 + 64
                width: cell.width / 2 - 64
                text: cell.modelData.v2
            }
        }
    }

    component Label: Text {
        color: Colors.mutedForeground
        font.family: Config.font.family
        font.pixelSize: Config.font.sm
    }
    component Value: Text {
        elide: Text.ElideRight
        color: Colors.foreground
        font.family: Config.font.family
        font.pixelSize: Config.font.sm
    }
}
