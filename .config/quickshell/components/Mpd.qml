import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

Item {
    id: root

    property MprisPlayer player: {
        for (const p of Mpris.players.values) {
            if (p.dbusName === "org.mpris.MediaPlayer2.mpd")
                return p;
        }

        return null;
    }

    readonly property bool available: player !== null
    readonly property bool playing: player?.isPlaying ?? false

    implicitWidth: 280
    implicitHeight: 72

    visible: available

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: "#202020"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            // Album art
            Rectangle {
                Layout.preferredWidth: 52
                Layout.preferredHeight: 52
                Layout.alignment: Qt.AlignVCenter

                radius: 8
                clip: true
                color: "#303030"

                Image {
                    anchors.fill: parent

                    source: root.player?.trackArtUrl ?? ""

                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent

                    text: "󰝚"
                    font.pixelSize: 24
                    color: "#888888"

                    visible: !parent.children[0].visible
                }
            }

            // Song information
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    Layout.fillWidth: true

                    text: root.player?.trackTitle ?? "Nothing playing"

                    color: "#ffffff"
                    font.pixelSize: 14
                    font.bold: true

                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true

                    text: root.player?.trackArtist ?? ""

                    color: "#999999"
                    font.pixelSize: 12

                    elide: Text.ElideRight
                }

                // Progress
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 3

                    radius: 2
                    color: "#404040"

                    Rectangle {
                        width: {
                            if (!root.player)
                                return 0;

                            if (root.player.length <= 0)
                                return 0;

                            return parent.width * (root.player.position / root.player.length);
                        }

                        height: parent.height
                        radius: 2
                        color: "#ffffff"
                    }
                }
            }

            // Controls
            RowLayout {
                spacing: 2

                Text {
                    text: "󰒮"
                    color: "#ffffff"
                    font.pixelSize: 18

                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 32

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (root.player?.canGoPrevious)
                                root.player.previous();
                        }
                    }
                }

                Text {
                    text: root.playing ? "󰏤" : "󰐊"

                    color: "#ffffff"
                    font.pixelSize: 20

                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 32

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (root.player?.canTogglePlaying)
                                root.player.togglePlaying();
                        }
                    }
                }

                Text {
                    text: "󰒭"
                    color: "#ffffff"
                    font.pixelSize: 18

                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 32

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (root.player?.canGoNext)
                                root.player.next();
                        }
                    }
                }
            }
        }
    }
}
