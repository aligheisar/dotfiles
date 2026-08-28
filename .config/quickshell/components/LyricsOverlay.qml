import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import qs.services
import qs.config
import qs.colors


ShellRoot {

    GlobalShortcut {
        name: "toggle-lyrics"

        onPressed: {
            Config.general.showLyrics = !Config.general.showLyrics
        }
    }

PanelWindow {// qmllint disable uncreatable-type
    id: root
    visible: Config.general.showLyrics

    exclusiveZone: 0
    mask: Region {}
    color: "transparent"

    readonly property int padV: 12
    readonly property int padH: 18

    implicitWidth: Config.sizes.maxLyricsOverlayWidth
    implicitHeight: hasLyric ? (lyricCol.implicitHeight + padV * 2) : 0

    anchors {
        bottom: true
        left: true
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

                Text {
                    id: currentLyric
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignLeft
                    width: parent.width
                    font.family: Config.font.family
                    font.pixelSize: root.lyricsPixelSize
                    color: Colors.foreground
                    wrapMode: Text.WordWrap
                    text: lineBox.displayed
                    transformOrigin: Item.Left
                    opacity: 1
                    scale: 1
                    transform: Translate {
                        id: lyricShift
                        y: 0
                    }

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Colors.background
                        shadowBlur: 0.5
                        shadowHorizontalOffset: 0
                        shadowVerticalOffset: 3
                    }

                    Behavior on font.pixelSize {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
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