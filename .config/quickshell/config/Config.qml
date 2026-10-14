pragma Singleton

import QtQuick

QtObject {
    component General: QtObject {
        readonly property string musicDir: "/home/ali/Music"
        readonly property string lyricsDir: "/home/ali/Music/lrc"
        property bool showLyrics: true
    }
    component Spacing: QtObject {
        readonly property int xs: 2
        readonly property int sm: 4
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 16
    }

    component Rounding: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 24
        readonly property int full: 999
    }

    component Sizes: QtObject {
        readonly property int barWidth: 44
        readonly property int maxLyricsOverlayWidth: 500
        readonly property int trayIcon: 14
        readonly property int titleIcon: 22
        readonly property int barIcon: 20
        readonly property int button: 28
        readonly property int wsButton: 28
        readonly property int wsIcon: 14
        readonly property int windowRounding: 9
    }

    component Font: QtObject {
        readonly property string family: "Roboto"
        readonly property string familyMono: "Roboto Mono"
        readonly property int xs: 9
        readonly property int sm: 12
        readonly property int base: 14
        readonly property int md: 16
        readonly property int lg: 24
        readonly property int xl: 28
        readonly property int doubleXl: 32
    }

    component Appearance: QtObject {
        readonly property double barOpacity: 0.9
        readonly property double osdOpacity: 0.9
        readonly property double popupOpacity: 1
    }

    readonly property General general: General {}
    readonly property Spacing spacing: Spacing {}
    readonly property Rounding rounding: Rounding {}
    readonly property Sizes sizes: Sizes {}
    readonly property Font font: Font {}
    readonly property Appearance appearance: Appearance {}
}
