pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property alias background: jsonAdapter.background
    property alias foreground: jsonAdapter.foreground
    property alias surface: jsonAdapter.surface
    property alias surfaceVariant: jsonAdapter.surfaceVariant
    property alias surfaceLow: jsonAdapter.surfaceLow
    property alias surfaceHighest: jsonAdapter.surfaceHighest
    property alias mutedForeground: jsonAdapter.mutedForeground

    property alias primary: jsonAdapter.primary
    property alias primaryText: jsonAdapter.primaryText
    property alias primaryContainer: jsonAdapter.primaryContainer
    property alias primaryContainerText: jsonAdapter.primaryContainerText

    property alias secondary: jsonAdapter.secondary
    property alias secondaryText: jsonAdapter.secondaryText
    property alias secondaryContainer: jsonAdapter.secondaryContainer
    property alias secondaryContainerText: jsonAdapter.secondaryContainerText

    property alias tertiary: jsonAdapter.tertiary
    property alias tertiaryText: jsonAdapter.tertiaryText
    property alias tertiaryContainer: jsonAdapter.tertiaryContainer
    property alias tertiaryContainerText: jsonAdapter.tertiaryContainerText

    property alias error: jsonAdapter.error
    property alias errorText: jsonAdapter.errorText
    property alias errorContainer: jsonAdapter.errorContainer
    property alias errorContainerText: jsonAdapter.errorContainerText

    property alias outline: jsonAdapter.outline
    property alias outlineVariant: jsonAdapter.outlineVariant
    property alias shadow: jsonAdapter.shadow
    property alias scrim: jsonAdapter.scrim

    property alias inverseSurface: jsonAdapter.inverseSurface
    property alias inverseSurfaceText: jsonAdapter.inverseSurfaceText
    property alias inversePrimary: jsonAdapter.inversePrimary

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/quickshell/generated/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter { // qmllint disable unresolved-type
            id: jsonAdapter

            property string background: "transparent"
            property string foreground: "transparent"
            property string surface: "transparent"
            property string surfaceVariant: "transparent"
            property string surfaceLow: "transparent"
            property string surfaceHighest: "transparent"
            property string mutedForeground: "transparent"

            property string primary: "transparent"
            property string primaryText: "transparent"
            property string primaryContainer: "transparent"
            property string primaryContainerText: "transparent"

            property string secondary: "transparent"
            property string secondaryText: "transparent"
            property string secondaryContainer: "transparent"
            property string secondaryContainerText: "transparent"

            property string tertiary: "transparent"
            property string tertiaryText: "transparent"
            property string tertiaryContainer: "transparent"
            property string tertiaryContainerText: "transparent"

            property string error: "transparent"
            property string errorText: "transparent"
            property string errorContainer: "transparent"
            property string errorContainerText: "transparent"

            property string outline: "transparent"
            property string outlineVariant: "transparent"
            property string shadow: "transparent"
            property string scrim: "transparent"

            property string inverseSurface: "transparent"
            property string inverseSurfaceText: "transparent"
            property string inversePrimary: "transparent"
        }
    }
}
