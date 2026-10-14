import QtQuick
import qs.colors
import qs.config

FocusScope {
    id: root

    required property var service
    required property var link

    signal closeRequested

    // ---- open/close animation ----
    property bool shown: false          // driven by the widget
    property real slide: 10            // px the card starts offset from (toward the bar)
    property int duration: 80
    property int easing: Easing.OutCubic

    focus: true
    implicitHeight: card.implicitHeight
    Keys.onEscapePressed: root.closeRequested()

    Rectangle {
        id: card
        width: parent.width

        opacity: root.shown ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: root.duration
                easing.type: root.easing
            }
        }
        transform: Translate {
            y: root.shown ? 0 : root.slide
            Behavior on y {
                NumberAnimation {
                    duration: root.duration
                    easing.type: root.easing
                }
            }
        }
        implicitHeight: col.implicitHeight + Config.spacing.xl * 2
        radius: Config.rounding.sm
        color: Qt.alpha(Colors.background, Config.appearance.popupOpacity)
        border.color: Colors.outlineVariant
        border.width: 1

        Column {
            id: col
            x: Config.spacing.xl
            y: Config.spacing.xl
            width: parent.width - Config.spacing.xl * 2
            spacing: Config.spacing.lg

            PanelHeader {
                width: parent.width
                service: root.service
            }

            DetailsGrid {
                visible: !!root.link.details.iface
                width: parent.width
                link: root.link
            }

            // Divider {
            //     width: parent.width
            //     visible: !!root.link.details.iface
            // }

            // DnsPicker {
            //     visible: !!root.link.details.iface
            //     width: parent.width
            //     link: root.link
            // }

            Divider {
                width: parent.width
                visible: !!root.link.details.iface && !!root.service.wifiDevice
            }

            WifiList {
                width: parent.width
                service: root.service
            }

            Text {
                visible: !root.service.nmAvailable
                width: parent.width
                wrapMode: Text.Wrap
                text: "NetworkManager isn't the active network backend, so Wi-Fi controls are unavailable."
                color: Colors.error
                font.family: Config.font.family
                font.pixelSize: Config.font.sm
            }
        }
    }
}
