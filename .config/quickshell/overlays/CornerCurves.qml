import Quickshell
import QtQuick
import qs.configs
import "../components"

Scope {
    PanelWindow { // qmllint disable uncreatable-type
        id: bottomRightCurve
        anchors {
            bottom: true
            right: true
        }

        implicitWidth: Config.sizes.windowRounding
        implicitHeight: Config.sizes.windowRounding

        exclusiveZone: 0
        mask: Region {}

        color: "transparent"

        ConcaveCurves {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            isTop: false
            mirrored: true
        }
    }

    PanelWindow { // qmllint disable uncreatable-type
        id: bottomLeftCurve
        anchors {
            bottom: true
            left: true
        }

        implicitWidth: Config.sizes.windowRounding
        implicitHeight: Config.sizes.windowRounding

        exclusiveZone: 0
        mask: Region {}

        color: "transparent"

        ConcaveCurves {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            isTop: false
            mirrored: false
        }
    }

    PanelWindow { // qmllint disable uncreatable-type
        id: topLeftCurve
        anchors {
            top: true
            left: true
        }

        implicitWidth: Config.sizes.windowRounding
        implicitHeight: Config.sizes.windowRounding

        exclusiveZone: 0
        mask: Region {}

        color: "transparent"

        ConcaveCurves {
            anchors.top: parent.top
            anchors.left: parent.left
            isTop: true
            mirrored: false
        }
    }

    PanelWindow { // qmllint disable uncreatable-type
        id: topRightCurve
        anchors {
            top: true
            right: true
        }

        implicitWidth: Config.sizes.windowRounding
        implicitHeight: Config.sizes.windowRounding

        exclusiveZone: 0
        mask: Region {}

        color: "transparent"

        ConcaveCurves {
            anchors.top: parent.top
            anchors.right: parent.right
            isTop: true
            mirrored: true
        }
    }
}
