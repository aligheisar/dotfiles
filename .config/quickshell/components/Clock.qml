import Quickshell
import QtQuick
import qs.config
import qs.colors

Column {
    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    anchors.horizontalCenter: parent.horizontalCenter

    Text {
        color: Colors.tertiary
        text: Qt.formatDateTime(sysClock.date, "hh")
        font {
            family: Config.font.familyMono
            pixelSize: Config.font.md
            weight: Font.Bold
        }
    }
    Text {
        color: Colors.mutedForeground
        text: Qt.formatDateTime(sysClock.date, "mm")
        font {
            family: Config.font.familyMono
            pixelSize: Config.font.md
            weight: Font.Light
        }
    }
}
