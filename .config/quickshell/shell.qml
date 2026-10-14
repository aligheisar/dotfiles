import Quickshell
import QtQuick
import qs.components
import qs.components.network
import qs.overlays
import qs.config
import qs.colors

Scope {
    PanelWindow { // qmllint disable uncreatable-type
        id: bar

        anchors {
            left: true
            top: true
            bottom: true
        }
        implicitWidth: Config.sizes.barWidth
        color: Qt.alpha(Colors.background, Config.appearance.barOpacity)

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Config.spacing.lg
            topPadding: Config.spacing.md

            Workspaces {}
            Player {}
        }

        Title {}

        VolumeOsd {}

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            bottomPadding: Config.spacing.md

            spacing: Config.spacing.lg

            Tray {}

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: controls_col.implicitWidth
                height: controls_col.implicitHeight
                color: Colors.secondaryContainer
                radius: Config.rounding.full

                Column {
                    id: controls_col
                    spacing: Config.spacing.md
                    width: 30
                    bottomPadding: Config.spacing.md

                    NetworkWidget {}
                    Volume {}
                    Lang {}
                    Date {}
                }
            }

            Clock {}
        }
    }

    CornerCurves {}

    LyricsOverlay {}
}
