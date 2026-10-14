pragma ComponentBehavior: Bound

import QtQuick
import QtQml
import Quickshell.Services.Mpris
import Quickshell.Widgets
import qs.config
import qs.colors

Item {
    id: root

    // Player the user scrolled to, or the last one that started playing
    property MprisPlayer selected: null

    // Effective player: selected if still alive, otherwise playing > paused > first
    property MprisPlayer player: {
        const players = Mpris.players.values;

        if (selected && players.indexOf(selected) !== -1)
            return selected;

        for (const p of players) {
            if (p.playbackState === MprisPlaybackState.Playing)
                return p;
        }

        for (const p of players) {
            if (p.playbackState === MprisPlaybackState.Paused)
                return p;
        }

        return players.length > 0 ? players[0] : null;
    }

    // Player whose info is actually drawn. It lags behind `player`
    // so the old content can animate out before the new one animates in.
    property MprisPlayer shown: null

    property real swapOffset: 0
    property real swapOpacity: 1
    property int slideDir: 1   // set by cycle(), consumed on the next player change
    property int animDir: 1    // direction used by the running animation

    readonly property int playerCount: Mpris.players.values.length
    readonly property int playerIndex: Mpris.players.values.indexOf(player)

    property real wheelAccum: 0

    function cycle(direction: int): void {
        const players = Mpris.players.values;
        if (players.length < 2)
            return;

        const current = players.indexOf(root.player);
        const next = (current + direction + players.length) % players.length;
        root.slideDir = direction;
        root.selected = players[next];
    }

    // Focus the first other player that is currently playing (if any)
    function focusPlaying(exclude: var): void {
        for (const p of Mpris.players.values) {
            if (p !== exclude && p.playbackState === MprisPlaybackState.Playing) {
                root.selected = p;
                return;
            }
        }
    }

    onPlayerChanged: {
        // First appearance or no player left: no animation, just sync
        if (player === null || shown === null) {
            switchAnim.stop();
            swapOffset = 0;
            swapOpacity = 1;
            shown = player;
            return;
        }

        if (player === shown && !switchAnim.running)
            return;

        animDir = slideDir;
        slideDir = 1;
        switchAnim.restart();
    }

    Component.onCompleted: shown = player

    // Switch animation: slide + fade out, swap content, slide + fade in
    SequentialAnimation {
        id: switchAnim

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "swapOpacity"
                to: 0
                duration: 120
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: root
                property: "swapOffset"
                to: -root.animDir * 14
                duration: 120
                easing.type: Easing.InCubic
            }
        }

        ScriptAction {
            script: {
                root.shown = root.player;
                root.swapOffset = root.animDir * 14;
            }
        }

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "swapOpacity"
                to: 1
                duration: 200
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: root
                property: "swapOffset"
                to: 0
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    Instantiator {
        model: Mpris.players

        delegate: Connections {
            id: conn

            required property MprisPlayer modelData

            target: conn.modelData

            function onPlaybackStateChanged() {
                // Only a player that starts playing takes focus.
                // Pausing or stopping never moves focus.
                if (conn.modelData.playbackState === MprisPlaybackState.Playing)
                    root.selected = conn.modelData;
            }

            // A player that shows up already playing should take focus too
            Component.onCompleted: {
                if (conn.modelData.playbackState === MprisPlaybackState.Playing)
                    root.selected = conn.modelData;
            }
        }
    }

    visible: player !== null && player.playbackState !== MprisPlaybackState.Stopped

    width: parent.width
    implicitHeight: content.implicitHeight

    Column {
        id: content

        width: parent.width
        spacing: Config.spacing.md

        // Player indicator dots (only with multiple players)
        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: Config.spacing.xs
            visible: root.playerCount > 1

            Repeater {
                model: root.playerCount

                Rectangle {
                    id: dot

                    required property int index

                    width: 5
                    height: 5
                    radius: 2.5

                    color: dot.index === root.playerIndex ? Colors.foreground : Colors.tertiary
                    opacity: dot.index === root.playerIndex ? 1 : 0.4

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }
            }
        }

        // Album art
        ClippingRectangle {
            width: parent.width
            height: width

            radius: Config.rounding.xs
            color: Colors.surface

            opacity: root.swapOpacity
            transform: Translate {
                x: root.swapOffset
            }

            Image {
                anchors.fill: parent

                source: root.shown && root.shown.trackArtUrl ? root.shown.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                smooth: true

                visible: source !== ""
            }

            Text {
                anchors.centerIn: parent

                text: String.fromCodePoint(0xF001)
                font.pixelSize: 14
                color: Colors.foreground

                visible: !root.shown?.trackArtUrl
            }

            Rectangle {
                anchors.fill: parent

                color: "#80000000"

                opacity: root.shown?.playbackState === MprisPlaybackState.Paused ? 1 : 0

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

            opacity: root.swapOpacity
            transform: Translate {
                x: root.swapOffset
            }

            Column {
                id: metadata

                anchors.centerIn: parent

                width: parent.height

                spacing: Config.spacing.xs

                rotation: 90

                Text {
                    width: metadata.width

                    text: root.shown?.trackTitle ?? ""

                    color: Colors.foreground
                    font.family: Config.font.family
                    font.pixelSize: Config.font.sm
                    font.weight: Font.Medium

                    elide: Text.ElideRight
                }

                Text {
                    width: metadata.width

                    text: root.shown?.trackArtist ?? ""

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

        onWheel: wheel => {
            root.wheelAccum += wheel.angleDelta.y;

            // 120 = one standard wheel notch; touchpads accumulate until they reach it
            if (Math.abs(root.wheelAccum) >= 120) {
                // scroll up -> previous player, scroll down -> next player
                root.cycle(root.wheelAccum > 0 ? -1 : 1);
                root.wheelAccum = 0;
            }
        }
    }
}
