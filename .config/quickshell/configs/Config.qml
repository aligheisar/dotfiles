pragma Singleton
import QtQuick

QtObject {
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
        readonly property int trayIcon: 14
        readonly property int titleIcon: 22
        readonly property int barIcon: 20
        readonly property int button: 32
        readonly property int wsButton: 28
        readonly property int wsIcon: 14
        readonly property int windowRounding: 10
    }

    component Colors: QtObject {
        readonly property color background: '#DE090909'
        readonly property color trayBackground: '#181818'
        readonly property color osdBackground: '#90020202'
        readonly property color osdProgressBackground: '#606060'
        readonly property color foreground: "#EAEAEA"
        readonly property color mutedForeground: '#c7c7c7'
        readonly property color ws: '#222222'
        readonly property color wsFocused: '#EAEAEA'
        readonly property color wsActive: '#393939'
        readonly property color wsUrgent: '#702f2f'
        readonly property color wsForeground: '#7a7a7a'
        readonly property color wsActiveForeground: '#EAEAEA'
        readonly property color wsFocusedForeground: '#121212'
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

    readonly property Spacing spacing: Spacing {}
    readonly property Rounding rounding: Rounding {}
    readonly property Sizes sizes: Sizes {}
    readonly property Colors colors: Colors {}
    readonly property Font font: Font {}
}
