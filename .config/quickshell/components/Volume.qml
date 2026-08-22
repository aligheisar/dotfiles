import Quickshell.Services.Pipewire
import QtQuick
import qs.configs

Item {
    id: root

    width: parent.width
    height: iconText.implicitHeight

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

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

    Text {
        id: iconText
        text: root.icon
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: Config.sizes.barIcon
        color: Config.colors.foreground
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.sink?.audio)
                root.sink.audio.muted = !root.sink.audio.muted;
        }

        onWheel: wheel => {
            if (!root.sink?.audio)
                return;
            const step = 0.05;
            const delta = wheel.angleDelta.y > 0 ? step : -step;
            root.sink.audio.volume = Math.max(0, Math.min(1, root.volume + delta));
        }
    }
}
