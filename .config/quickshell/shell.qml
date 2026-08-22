//@ pragma UseQApplication
import Quickshell
import QtQuick
import qs.configs
import "components/"
import "overlays/"

Scope {
    PanelWindow { // qmllint disable uncreatable-type
        id: bar

        anchors {
            left: true
            top: true
            bottom: true
        }
        implicitWidth: Config.sizes.barWidth
        color: Config.colors.background

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Config.spacing.lg
            topPadding: Config.spacing.md

            Workspaces {}
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
