pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    property MprisPlayer player: {
        for (const player of Mpris.players.values) {
            if (player.dbusName === "org.mpris.MediaPlayer2.mpd")
                return player;
        }

        return null;
    }

    readonly property bool available: player !== null
    readonly property bool playing: player?.isPlaying ?? false

    readonly property string title: player?.trackTitle ?? ""

    readonly property string artist: player?.trackArtist ?? ""

    readonly property string album: player?.trackAlbum ?? ""

    readonly property string art: player?.trackArtUrl ?? ""

    function toggle() {
        if (player?.canTogglePlaying)
            player.togglePlaying();
    }

    function next() {
        if (player?.canGoNext)
            player.next();
    }

    function previous() {
        if (player?.canGoPrevious)
            player.previous();
    }
}
