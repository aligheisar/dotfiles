import Quickshell
import QtQuick
import qs.components
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
            Volume {}
            Lang {}
            Clock {}
        }
    }

    CornerCurves {}
}
