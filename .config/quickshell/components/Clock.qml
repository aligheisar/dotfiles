import Quickshell
import QtQuick
import qs.configs

Column {
    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    anchors.horizontalCenter: parent.horizontalCenter

    Text {
        color: Config.colors.foreground
        text: Qt.formatDateTime(sysClock.date, "hh")
        font {
            family: Config.font.familyMono
            pixelSize: Config.font.base
            weight: Font.Bold
        }
    }
    Text {
        color: Config.colors.mutedForeground
        text: Qt.formatDateTime(sysClock.date, "mm")
        font {
            family: Config.font.familyMono
            pixelSize: Config.font.base
            weight: Font.Light
        }
    }
}
