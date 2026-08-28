pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "LrcParser.js" as LrcParser

/**
 * LrcLyrics – path-mapped LRC loader for MPRIS.
 *
 * musicDir  = /home/ali/Music
 * track     = /home/ali/Music/Other Language/AURORA/The Devil is Human.mp3
 * lyricsDir = /home/ali/Music/lrc
 * loads     = /home/ali/Music/lrc/Other Language/AURORA/The Devil is Human.lrc
 *
 *   LrcLyrics {
 *       musicDir:  "/home/ali/Music"
 *       lyricsDir: "/home/ali/Music/lrc"
 *   }
 */
Item {
    id: root

    // ── Config ─────────────────────────────────────────────────────────
    /** Music library root (absolute). Track paths must live under this. */
    property string musicDir: ""

    /** Lyrics root (absolute). Same relative tree as musicDir, .lrc files. */
    property string lyricsDir: ""

    /** Optional forced player; otherwise first playing / first available. */
    property var player: null

    property int updateInterval: 100

    // ── Public state ───────────────────────────────────────────────────
    readonly property string currentLyric: _currentMain
    readonly property string currentTranslation: _currentTrans
    readonly property real lyricProgress: _progress
    readonly property int currentIndex: _index
    readonly property var lines: _parsed
    readonly property string status: _status   // idle|loading|ready|notfound|error
    readonly property string error: _error
    readonly property string trackKey: _trackKey
    readonly property var activePlayer: _resolvedPlayer

    property string lastTrackUrl: ""
    property string lastTrackPath: ""
    property string lastLrcPath: ""

    // ── Internal ───────────────────────────────────────────────────────
    property string _currentMain: ""
    property string _currentTrans: ""
    property real _progress: 0
    property int _index: -1
    property var _parsed: []
    property string _status: "idle"
    property string _error: ""
    property string _trackKey: ""
    property var _resolvedPlayer: null
    property string _pendingUrlFetchKey: ""

    readonly property var playerList: {
        try {
            return Mpris.players.values || [];
        } catch (e) {
            return [];
        }
    }

    function _pickPlayer() {
        if (root.player)
            return root.player;
        const list = root.playerList;
        if (!list || list.length === 0)
            return null;
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].isPlaying)
                return list[i];
        }
        for (let j = 0; j < list.length; j++) {
            if (list[j] && (list[j].trackTitle || list[j].trackArtist))
                return list[j];
        }
        return list[0] || null;
    }

    // ── URL / path helpers ─────────────────────────────────────────────

    function _urlToPath(url) {
        if (!url)
            return "";
        let s = String(url).trim();
        if (s.startsWith("file://")) {
            s = s.slice(7);
            if (s.startsWith("localhost"))
                s = s.slice(9);
            if (s.length && s[0] !== "/")
                s = "/" + s;
        }
        try {
            s = decodeURIComponent(s);
        } catch (e) {
            s = s.replace(/%20/g, " ").replace(/%2F/gi, "/");
        }
        return s;
    }

    /** Read xesam:url from MPRIS metadata if present. */
    function _metaUrl(p) {
        if (!p)
            return "";
        const md = p.metadata;
        if (!md)
            return "";
        const keys = ["xesam:url", "xesam:Url", "url", "URL"];
        for (let i = 0; i < keys.length; i++) {
            try {
                const v = md[keys[i]];
                if (v !== undefined && v !== null && String(v).length > 0)
                    return String(v);
            } catch (e) {}
        }
        return "";
    }

    /**
     * music path → lrc path
     *
     * Absolute:
     *   /home/ali/Music/Other Language/AURORA/song.mp3
     *   → /home/ali/Music/lrc/Other Language/AURORA/song.lrc
     *
     * Relative (what your player is giving):
     *   Other Language/Eminem/Album/Habits.mp3
     *   → /home/ali/Music/lrc/Other Language/Eminem/Album/Habits.lrc
     */
    function _mapToLrc(trackPath) {
        const musicRoot = (root.musicDir || "").replace(/\/+$/, "");
        const lyricsRoot = (root.lyricsDir || "").replace(/\/+$/, "");
        if (!lyricsRoot || !trackPath)
            return "";

        let path = String(trackPath).trim();
        let rel = "";

        if (musicRoot && (path.startsWith(musicRoot + "/") || path === musicRoot)) {
            // Absolute under musicDir
            rel = path.slice(musicRoot.length).replace(/^\/+/, "");
        } else if (path.startsWith("/")) {
            // Absolute elsewhere — try after "/Music/"
            const markers = ["/Music/", "/music/"];
            for (let i = 0; i < markers.length; i++) {
                const idx = path.indexOf(markers[i]);
                if (idx >= 0) {
                    rel = path.slice(idx + markers[i].length);
                    break;
                }
            }
            if (!rel)
                return "";
        } else {
            // Already relative: "Other Language/Artist/song.mp3"
            rel = path.replace(/^\/+/, "");
        }

        if (!rel)
            return "";

        // Skip if already inside lyrics subfolder of music
        if (musicRoot && lyricsRoot.startsWith(musicRoot + "/")) {
            const lyricsRel = lyricsRoot.slice(musicRoot.length + 1);
            if (rel === lyricsRel || rel.startsWith(lyricsRel + "/"))
                return "";
        }

        // Strip audio extension → .lrc
        const slash = rel.lastIndexOf("/");
        const baseStart = slash >= 0 ? slash + 1 : 0;
        const base = rel.slice(baseStart);
        const dot = base.lastIndexOf(".");
        let withoutExt = rel;
        if (dot > 0)
            withoutExt = (slash >= 0 ? rel.slice(0, slash + 1) : "") + base.slice(0, dot);

        return lyricsRoot + "/" + withoutExt + ".lrc";
    }

    function _resetLyricState() {
        root._parsed = [];
        root._currentMain = "";
        root._currentTrans = "";
        root._progress = 0;
        root._index = -1;
        root._error = "";
    }

    function _applyLrcText(text, lrcPath) {
        root._parsed = LrcParser.parse(text || "");
        if (root._parsed.length > 0) {
            root._status = "ready";
            root._error = "";
            root.lastLrcPath = lrcPath;
            root._updateLine();
        } else {
            root._status = "notfound";
            root._error = "Empty or invalid LRC: " + lrcPath;
        }
    }

    function _loadFromPath(trackPath) {
        root.lastTrackPath = trackPath || "";
        const lrcPath = _mapToLrc(trackPath);
        root.lastLrcPath = lrcPath;

        if (!lrcPath) {
            root._status = "notfound";
            root._error = "Cannot map path (check musicDir/lyricsDir and track path)";
            return;
        }

        root._status = "loading";
        lrcFile.path = lrcPath;
    }

    // Load LRC file
    FileView {
        id: lrcFile
        watchChanges: false
        printErrors: false

        onLoaded: {
            root._applyLrcText(text(), root.lastLrcPath);
        }
        onLoadFailed: function (error) {
            root._status = "notfound";
            root._error = "LRC not found: " + root.lastLrcPath;
        }
    }

    // playerctl fallback for xesam:url when metadata is empty
    Process {
        id: urlProc
        property string fetchKey: ""
        property string captured: ""

        stdout: StdioCollector {
            onStreamFinished: {
                urlProc.captured = this.text || "";
            }
        }

        onExited: function (exitCode, exitStatus) {
            if (urlProc.fetchKey !== root._pendingUrlFetchKey)
                return; // stale
            const out = String(urlProc.captured || "").trim();
            if (exitCode === 0 && out.length > 0) {
                root.lastTrackUrl = out;
                root._loadFromPath(root._urlToPath(out));
            } else {
                root._status = "notfound";
                root._error = "No track file URL (xesam:url empty)";
            }
        }
    }

    function _requestUrlViaPlayerctl(p) {
        let name = "";
        if (p) {
            name = p.dbusName || p.identity || "";
            if (name.indexOf("org.mpris.MediaPlayer2.") === 0)
                name = name.slice("org.mpris.MediaPlayer2.".length);
        }
        const key = (p ? (p.trackTitle || "") : "") + "|" + Date.now();
        root._pendingUrlFetchKey = key;
        urlProc.fetchKey = key;
        urlProc.captured = "";

        // Restart process with new command
        urlProc.running = false;
        urlProc.command = name ? ["playerctl", "metadata", "-p", name, "xesam:url"] : ["playerctl", "metadata", "xesam:url"];
        urlProc.running = true;
    }

    function _loadForTrack(p) {
        if (!root.musicDir || !root.lyricsDir) {
            root._status = "idle";
            root._error = "Set musicDir and lyricsDir";
            return;
        }
        if (!p) {
            root._status = "idle";
            root._resetLyricState();
            root._trackKey = "";
            return;
        }

        const title = p.trackTitle || "";
        const artist = p.trackArtist || "";
        const metaUrl = _metaUrl(p);
        const key = metaUrl + "|" + artist + "|" + title;

        if (key === root._trackKey && root._status === "ready")
            return;

        root._trackKey = key;
        root._resetLyricState();
        root.lastTrackUrl = metaUrl;
        root.lastTrackPath = "";
        root.lastLrcPath = "";

        if (metaUrl) {
            root._loadFromPath(_urlToPath(metaUrl));
            return;
        }

        // Metadata empty → ask playerctl
        root._status = "loading";
        root._requestUrlViaPlayerctl(p);
    }

    function _updateLine() {
        if (!root._resolvedPlayer || root._parsed.length === 0) {
            root._currentMain = "";
            root._currentTrans = "";
            root._progress = 0;
            root._index = -1;
            return;
        }
        const posUs = Math.floor((root._resolvedPlayer.position || 0) * 1000000);
        const info = LrcParser.getInfo(root._parsed, posUs);
        root._index = info.index;
        root._progress = info.progress;
        if (info.current) {
            const split = LrcParser.splitTranslation(info.current.text);
            root._currentMain = split.main;
            root._currentTrans = split.translation;
        } else {
            root._currentMain = "";
            root._currentTrans = "";
        }
    }

    function _onTrackMaybeChanged() {
        const p = root._pickPlayer();
        if (p !== root._resolvedPlayer)
            root._resolvedPlayer = p;
        root._loadForTrack(p);
    }

    onPlayerListChanged: root._onTrackMaybeChanged()
    onPlayerChanged: root._onTrackMaybeChanged()
    onMusicDirChanged: {
        root._trackKey = "";
        root._onTrackMaybeChanged();
    }
    onLyricsDirChanged: {
        root._trackKey = "";
        root._onTrackMaybeChanged();
    }

    Connections {
        target: Mpris.players
        function onObjectInsertedPost() {
            root._onTrackMaybeChanged();
        }
        function onObjectRemovedPost() {
            root._onTrackMaybeChanged();
        }
    }

    Connections {
        target: root._resolvedPlayer
        enabled: root._resolvedPlayer !== null
        function onTrackTitleChanged() {
            root._onTrackMaybeChanged();
        }
        function onTrackArtistChanged() {
            root._onTrackMaybeChanged();
        }
        function onTrackAlbumChanged() {
            root._onTrackMaybeChanged();
        }
        function onIsPlayingChanged() {
            root._onTrackMaybeChanged();
        }
        function onPlaybackStateChanged() {
            root._onTrackMaybeChanged();
        }
        function onMetadataChanged() {
            root._onTrackMaybeChanged();
        }
    }

    Timer {
        interval: root.updateInterval
        running: true
        repeat: true
        onTriggered: {
            const preferred = root._pickPlayer();
            if (preferred !== root._resolvedPlayer) {
                root._onTrackMaybeChanged();
                return;
            }
            if (root._resolvedPlayer && root._resolvedPlayer.isPlaying)
                root._resolvedPlayer.positionChanged();
            root._updateLine();
        }
    }

    Component.onCompleted: Qt.callLater(root._onTrackMaybeChanged)

    function reload() {
        root._trackKey = "";
        root._onTrackMaybeChanged();
    }

    function seekToLine(index) {
        if (!root._resolvedPlayer || index < 0 || index >= root._parsed.length)
            return;
        const t = root._parsed[index].timeUs / 1000000;
        if (root._resolvedPlayer.canSeek)
            root._resolvedPlayer.position = t;
    }
}
