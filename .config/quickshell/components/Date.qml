import Quickshell
import QtQuick
import qs.config
import qs.colors
import "../utils/jalali.js" as Jalali

Column {
    id: root
    SystemClock {
        id: sysClock
        precision: SystemClock.Hours
    }

    readonly property var month: Jalali.format(sysClock.date, "M")
    readonly property var day: Jalali.format(sysClock.date, "dd")

    anchors.horizontalCenter: parent.horizontalCenter

    Text {
        color: Colors.mutedForeground
        text: root.month
        font {
            family: Config.font.familyMono
            pixelSize: Config.font.base
            weight: Font.Light
        }
    }

    Text {
        color: Colors.mutedForeground
        text: root.day
        font {
            family: Config.font.familyMono
            pixelSize: Config.font.base
            weight: Font.Black
        }
    }
}
