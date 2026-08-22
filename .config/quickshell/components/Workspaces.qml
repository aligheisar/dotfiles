pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import qs.configs

Column {
    spacing: Config.spacing.xs

    readonly property var fixedWorkspaces: [1, 2, 3, 4]

    property var visibleWorkspaces: {
        const result = [...fixedWorkspaces];

        for (const ws of Hyprland.workspaces.values) {
            if (ws.id > 4 && (ws.focused || ws.toplevels.values.length > 0))
                result.push(ws.id);
        }

        return result.sort((a, b) => a - b);
    }

    Repeater {
        id: wsRepeater
        model: parent.visibleWorkspaces

        Rectangle {
            id: wsPill

            required property var modelData
            required property int index

            property var workspace: Hyprland.workspaces.values.find(ws => ws.id === modelData)

            property bool focused: workspace?.focused ?? false
            property bool hasWindows: (workspace?.toplevels.values.length ?? 0) > 0
            property bool urgent: workspace?.urgent ?? false
            property bool urgentBlink: false

            Accessible.role: Accessible.Button
            Accessible.name: {
                const names = {
                    1: "Research",
                    2: "Development",
                    3: "Preview",
                    4: "Music"
                };

                return "Workspace " + (names[modelData] ?? modelData) + (focused ? ", active" : "") + (urgent ? ", urgent" : "");
            }

            width: Config.sizes.wsButton
            height: Config.sizes.wsButton

            radius: Config.rounding.sm
            topLeftRadius: index === 0 ? Config.rounding.full : Config.rounding.xs
            topRightRadius: index === 0 ? Config.rounding.full : Config.rounding.xs

            bottomLeftRadius: index === wsRepeater.count - 1 ? Config.rounding.full : Config.rounding.xs
            bottomRightRadius: index === wsRepeater.count - 1 ? Config.rounding.full : Config.rounding.xs

            color: {
                if (urgent)
                    return Config.colors.wsUrgent;

                if (focused)
                    return Config.colors.wsFocused;

                if (hasWindows)
                    return Config.colors.wsActive;

                return Config.colors.ws;
            }

            Behavior on color {
                ColorAnimation {
                    duration: 100
                }
            }

            SequentialAnimation {
                loops: Animation.Infinite
                running: wsPill.urgent && !wsPill.focused

                PropertyAction {
                    target: wsPill
                    property: "urgentBlink"
                    value: true
                }

                PauseAnimation {
                    duration: 500
                }

                PropertyAction {
                    target: wsPill
                    property: "urgentBlink"
                    value: false
                }

                PauseAnimation {
                    duration: 500
                }

                onStopped: wsPill.urgentBlink = false
            }

            Text {
                anchors.centerIn: parent

                text: {
                    switch (wsPill.modelData) {
                    case 1:
                        return String.fromCodePoint(0xf002);
                    case 2:
                        return String.fromCodePoint(0xf44f);
                    case 3:
                        return String.fromCodePoint(0xF01E7);
                    case 4:
                        return String.fromCodePoint(0xf0387);
                    default:
                        return wsPill.modelData;
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }
                }

                color: {
                    if (!wsPill.focused && wsPill.hasWindows)
                        return Config.colors.wsActiveForeground;
                    if (wsPill.focused)
                        return Config.colors.wsFocusedForeground;
                    return Config.colors.wsForeground;
                }

                font.pixelSize: Config.sizes.wsIcon
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    Hyprland.dispatch(`hl.dsp.focus({ workspace = ${wsPill.modelData} })`);
                }
            }
        }
    }
}
