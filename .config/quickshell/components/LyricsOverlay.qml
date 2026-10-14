import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.services
import qs.config
import qs.colors

ShellRoot {

    GlobalShortcut {
        name: "toggle-lyrics"

        onPressed: {
            Config.general.showLyrics = !Config.general.showLyrics;
        }
    }

    PanelWindow {// qmllint disable uncreatable-type
        id: root
        visible: Config.general.showLyrics

        exclusiveZone: 0
        mask: Region {}
        color: "transparent"

        readonly property int padV: 10
        readonly property int padH: 10

        implicitWidth: Config.sizes.maxLyricsOverlayWidth
        implicitHeight: hasLyric ? (lyricCol.implicitHeight + padV * 2) : 0

        anchors {
            bottom: true
            left: true
            right: true
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "lyrics-panel"

        readonly property bool hasLyric: lrc.currentLyric.length > 0
        readonly property int lyricsPixelSize: Config.font.lg

        Behavior on height {
            NumberAnimation {
                duration: 280
                easing.type: Easing.OutCubic
            }
        }

        Lyrics {
            id: lrc
            musicDir: Config.general.musicDir
            lyricsDir: Config.general.lyricsDir
        }

        Item {
            id: content
            anchors.fill: parent
            anchors.leftMargin: root.padH
            anchors.rightMargin: root.padH
            anchors.topMargin: root.padV
            anchors.bottomMargin: root.padV

            opacity: root.hasLyric ? 1 : 0
            visible: root.height > 1

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            Column {
                id: lyricCol
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width
                spacing: 6

                Item {
                    id: lineBox
                    width: parent.width
                    height: Math.max(currentLyric.implicitHeight, root.lyricsPixelSize * 1.4)

                    property string displayed: ""
                    property string pending: lrc.currentLyric

                    onPendingChanged: {
                        if (pending === displayed)
                            return;
                        if (swapAnim.running)
                            swapAnim.stop();
                        swapAnim.restart();
                    }

                    Rectangle {
                        id: textContainer
                        width: currentLyric.width + 12
                        height: parent.height
                        color: Qt.alpha(Colors.tertiaryContainer, 0.9)
                        anchors.left: parent.left
                        radius: Config.rounding.xs

                        Behavior on width {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }

                        Text {
                            id: currentLyric
                            font.family: Config.font.family
                            font.pixelSize: root.lyricsPixelSize
                            color: Colors.tertiaryContainerText
                            wrapMode: Text.WordWrap
                            text: lineBox.displayed
                            transformOrigin: Item.Left
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: 1
                            scale: 1
                            transform: Translate {
                                id: lyricShift
                                y: 0
                                x: 6
                            }

                            layer.enabled: true

                            Behavior on font.pixelSize {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                    SequentialAnimation {
                        id: swapAnim

                        ParallelAnimation {
                            NumberAnimation {
                                target: currentLyric
                                property: "opacity"
                                to: 0
                                duration: 140
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: lyricShift
                                property: "y"
                                to: -12
                                duration: 140
                                easing.type: Easing.InCubic
                            }
                            NumberAnimation {
                                target: currentLyric
                                property: "scale"
                                to: 0.94
                                duration: 140
                                easing.type: Easing.InCubic
                            }
                        }

                        ScriptAction {
                            script: {
                                lineBox.displayed = lineBox.pending;
                                lyricShift.y = 14;
                                currentLyric.scale = 0.94;
                            }
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                target: currentLyric
                                property: "opacity"
                                to: 1
                                duration: 220
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: lyricShift
                                property: "y"
                                to: 0
                                duration: 240
                                easing.type: Easing.OutCubic
                            }
                            NumberAnimation {
                                target: currentLyric
                                property: "scale"
                                to: 1
                                duration: 240
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Component.onCompleted: lineBox.displayed = lrc.currentLyric
                }
            }
        }
    }
}
