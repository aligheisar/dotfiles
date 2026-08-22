pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.config
import qs.colors

Item {
    id: root

    property MprisPlayer player: {
        const players = Mpris.players.values;

        for (const player of players) {
            if (player.playbackState === MprisPlaybackState.Playing)
                return player;
        }

        for (const player of players) {
            if (player.playbackState === MprisPlaybackState.Paused)
                return player;
        }

        return players.length > 0 ? players[0] : null;
    }

    visible: player !== null && player.playbackState !== MprisPlaybackState.Stopped

    width: parent.width
    implicitHeight: content.implicitHeight

    Column {
        id: content

        width: parent.width
        spacing: Config.spacing.md

        // Album art
        ClippingRectangle {
            width: parent.width
            height: width

            radius: Config.rounding.xs
            color: Colors.surface

            Image {
                anchors.fill: parent

                source: root.player && root.player.trackArtUrl ? root.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                smooth: true

                visible: source !== ""
            }

            Text {
                anchors.centerIn: parent

                text: String.fromCodePoint(0xF001)
                font.pixelSize: 14
                color: Colors.foreground

                visible: !root.player?.trackArtUrl
            }

            Rectangle {
                anchors.fill: parent

                color: "#80000000"

                opacity: root.player?.playbackState === MprisPlaybackState.Paused ? 1 : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

                Text {
                    anchors.centerIn: parent
                    topPadding: 2

                    text: String.fromCodePoint(0xf04c)
                    font.pixelSize: 18
                    color: Colors.foreground

                    scale: parent.opacity ? 1 : 0.7

                    Behavior on scale {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        // Rotated title + artist
        Item {
            width: parent.width
            height: 140
            clip: true

            Column {
                id: metadata

                anchors.centerIn: parent

                width: parent.height

                spacing: Config.spacing.xs

                rotation: 90

                Text {
                    width: metadata.width

                    text: root.player?.trackTitle ?? ""

                    color: Colors.foreground
                    font.family: Config.font.family
                    font.pixelSize: Config.font.sm
                    font.weight: Font.Medium

                    elide: Text.ElideRight
                }

                Text {
                    width: metadata.width

                    text: root.player?.trackArtist ?? ""

                    color: Colors.tertiary
                    font.family: Config.font.family
                    font.pixelSize: Config.font.xs

                    elide: Text.ElideRight
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

        onClicked: mouse => {
            if (!root.player)
                return;

            switch (mouse.button) {
            case Qt.LeftButton:
                root.player.togglePlaying();
                break;
            case Qt.MiddleButton:
                root.player.previous();
                break;
            case Qt.RightButton:
                root.player.next();
                break;
            }
        }
    }
}
