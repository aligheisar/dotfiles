import QtQuick
import qs.colors
import qs.config

Item {
    id: row

    required property var modelData
    required property var service

    readonly property bool needsCreds: service.requiresCredentials(modelData.security)
    readonly property bool enterprise: service.isEnterprise(modelData.security)
    readonly property bool isBusy: service.actionKind !== "" && service.actionSsid === modelData.ssid
    readonly property bool isFailed: service.failureReason !== "" && service.failureSsid === modelData.ssid
    readonly property bool promptOpen: service.passwordSsid !== "" && service.passwordSsid === modelData.ssid
    readonly property bool secureNew: needsCreds && !modelData.known

    height: 46 + (promptOpen ? 42 : 0)

    readonly property string statusText: {
        if (promptOpen)
            return "";
        if (isBusy && service.actionKind === "connect")
            return "Connecting…";
        if (isBusy && service.actionKind === "disconnect")
            return "Disconnecting…";
        if (isBusy && service.actionKind === "forget")
            return "Forgetting…";
        if (isFailed)
            return service.failureReason;
        if (modelData.connected && service.connectivity === "portal")
            return "Sign-in required";
        if (modelData.connected)
            return "Connected · click to disconnect";
        if (modelData.known)
            return "Saved";
        return needsCreds ? "Secured" : "Open";
    }

    // Reprompt only for connects started from this panel.
    Connections {
        target: row.service.networkForSsid(row.modelData.ssid)
        function onConnectionFailed(reason) {
            var ours = row.service.actionKind === "connect" && row.service.actionSsid === row.modelData.ssid;
            row.service.failNetworkAction(row.service.networkForSsid(row.modelData.ssid), reason);
            if (ours && row.needsCreds && row.service.authFailure(reason))
                row.service.openPasswordPrompt(row.modelData.ssid);
        }
        function onConnectedChanged() {
            row.service.checkActionCompletion(row.service.networkForSsid(row.modelData.ssid));
        }
        function onKnownChanged() {
            row.service.checkActionCompletion(row.service.networkForSsid(row.modelData.ssid));
        }
        function onStateChangingChanged() {
            row.service.checkActionCompletion(row.service.networkForSsid(row.modelData.ssid));
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Config.rounding.sm
        color: rowArea.containsMouse || row.promptOpen || forgetArea.containsMouse ? Qt.alpha(Colors.surfaceHighest, 0.6) : "transparent"
    }

    MouseArea {
        id: rowArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: 46
        hoverEnabled: true
        enabled: !row.service.busy
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            var n = row.modelData;
            if (n.connected)
                row.service.disconnectSsid(n.ssid);
            else if (row.enterprise && !n.known)
                row.service.reportEnterpriseUnsupported(n.ssid);
            else if (row.secureNew)
                row.service.openPasswordPrompt(n.ssid);
            else
                row.service.connectDirectly(n.ssid);
        }
    }

    SignalBars {
        x: 12
        y: 16
        level: row.modelData.level
        activeColor: row.modelData.connected ? Colors.primary : Colors.foreground
        inactiveColor: Colors.outlineVariant
    }

    Column {
        x: 44
        y: 6
        width: parent.width - 44 - (row.modelData.known && !row.modelData.connected ? 64 : 12)
        spacing: 1
        Text {
            width: parent.width
            elide: Text.ElideRight
            text: row.modelData.ssid || "Hidden network"
            color: row.modelData.connected ? Colors.primary : Colors.foreground
            font.family: Config.font.family
            font.pixelSize: Config.font.base
            font.bold: row.modelData.connected
        }
        Text {
            width: parent.width
            elide: Text.ElideRight
            text: row.statusText
            visible: text !== ""
            color: row.isFailed ? Colors.error : Colors.mutedForeground
            font.family: Config.font.family
            font.pixelSize: Config.font.sm
        }
    }

    // Forget saved network
    Text {
        visible: row.modelData.known && !row.modelData.connected && !row.promptOpen
        anchors.right: parent.right
        anchors.rightMargin: 12
        y: 15
        text: "Forget"
        color: forgetArea.containsMouse ? Colors.error : Colors.mutedForeground
        font.family: Config.font.family
        font.pixelSize: Config.font.sm
        MouseArea {
            id: forgetArea
            anchors.fill: parent
            anchors.margins: -6
            hoverEnabled: true
            enabled: !row.service.busy
            cursorShape: Qt.PointingHandCursor
            onClicked: row.service.forgetSsid(row.modelData.ssid)
        }
    }

    PasswordPrompt {
        visible: row.promptOpen
        x: 10
        y: 46 + 2
        width: parent.width - 20
        busy: row.isBusy
        value: row.promptOpen ? row.service.passwordText : ""
        onEdited: v => {
            if (row.promptOpen)
                row.service.passwordText = v;
        }
        onSubmitted: v => row.service.connectWithPassphrase(row.modelData.ssid, v)
        onCancelled: row.service.cancelPasswordPrompt()
    }
}
