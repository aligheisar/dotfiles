import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.configs

Scope {
    id: root

    // Bind the pipewire node so its volume will be tracked
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null

        function onVolumeChanged() {
            if (!root.initialized)
                return;

            root.shouldShowOsd = true;
            hideTimer.restart();
        }

        function onMutedChanged() {
            if (!root.initialized)
                return;

            root.shouldShowOsd = true;
            hideTimer.restart();
        }
    }

    property bool shouldShowOsd: false
    property bool initialized: false

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property bool ready: sink?.ready ?? false
    readonly property real volume: ready ? (sink?.audio?.volume ?? 0) : 0
    readonly property int volumePercent: Math.round(volume * 100)

    readonly property string icon: {
        if (!ready || muted)
            return String.fromCodePoint(0xF075F);
        if (volumePercent < 34)
            return String.fromCodePoint(0xF057F);
        if (volumePercent < 67)
            return String.fromCodePoint(0xF0580);
        return String.fromCodePoint(0xF057E);
    }

    Timer {
        id: initTimer
        interval: 100
        running: true
        onTriggered: root.initialized = true
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow { // qmllint disable uncreatable-type
            anchors {
                bottom: true
            }
            // qmllint disable missing-property
            // qmllint disable unresolved-type
            // qmllint disable unqualified
            margins.bottom: Math.min(screen.height / 6, 70)
            exclusiveZone: 0

            implicitWidth: 220
            implicitHeight: 34
            color: "transparent"

            // An empty click mask prevents the window from blocking mouse events.
            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: Config.rounding.full
                color: Config.colors.osdBackground

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 12
                    }

                    spacing: Config.spacing.md

                    Item {
                        Layout.alignment: Qt.AlignVCenter
                        width: 22
                        height: parent.implicitHeight
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.icon
                            color: Config.colors.foreground
                            font {
                                pixelSize: 20
                            }
                        }
                    }

                    Rectangle {
                        // Stretches to fill all left-over space
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        implicitHeight: 8
                        radius: Config.rounding.full
                        color: Config.colors.osdProgressBackground

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }

                            implicitWidth: parent.width * root.volume
                            radius: Config.rounding.full
                        }
                    }

                    Item {
                        Layout.alignment: Qt.AlignVCenter
                        width: 30
                        height: parent.implicitHeight
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.volumePercent + "%"
                            color: Config.colors.foreground
                            font.pixelSize: Config.font.sm
                        }
                    }
                }
            }
        }
    }
}
