import QtQuick
import Quickshell.Networking

// Networking state + Wi-Fi actions (native NetworkManager backend). No UI here.
Item {
    id: root

    // Set by the widget: true while the panel is open.
    property bool active: false
    signal actionFinished()

    // ---------------- devices / state ----------------
    readonly property bool nmAvailable: Networking.backend === NetworkBackendType.NetworkManager
    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property var devices: Networking.devices ? Networking.devices.values : []
    readonly property var wifiDevice: findDevice(DeviceType.Wifi)
    readonly property var wiredDevice: findDevice(DeviceType.Wired)
    readonly property var wifiNetworkObjects: wifiDevice && wifiDevice.networks ? wifiDevice.networks.values : []
    readonly property var connectedWifi: findConnectedWifi()
    readonly property bool canToggleWifi: nmAvailable && !!wifiDevice

    // Prefer a connected device: a machine can expose several NICs of one type.
    function findDevice(type) {
        var list = devices || [], fallback = null;
        for (var i = 0; i < list.length; i++) {
            var d = list[i];
            if (!d || d.type !== type)
                continue;
            if (d.connected)
                return d;
            if (!fallback)
                fallback = d;
        }
        return fallback;
    }

    function findConnectedWifi() {
        var nets = wifiNetworkObjects || [];
        for (var i = 0; i < nets.length; i++)
            if (nets[i] && nets[i].connected)
                return nets[i];
        return null;
    }

    readonly property string kind: {
        if (wiredDevice && wiredDevice.connected)
            return "ethernet";
        if (connectedWifi)
            return "wifi";
        if (wifiDevice && wifiDevice.connected)
            return "wifi";   // profile momentarily out of range list
        return "disconnected";
    }

    // Signal strength may be reported as 0..1 or 0..100 depending on version.
    function norm(s) {
        return s > 1 ? s / 100 : s;
    }
    function levelFor(s) {
        var v = norm(s);
        if (!(v > 0))
            return 0;
        return Math.max(1, Math.min(4, Math.ceil(v * 4)));
    }
    readonly property int connectedLevel: kind === "wifi" && connectedWifi ? levelFor(connectedWifi.signalStrength) : (kind === "wifi" ? 3 : 0)

    // Captive portal / limited connectivity, as reported by NetworkManager.
    readonly property bool checksEnabled: nmAvailable && Networking.canCheckConnectivity && Networking.connectivityCheckEnabled
    readonly property string connectivity: {
        if (!checksEnabled || kind === "disconnected")
            return "";
        if (Networking.connectivity === NetworkConnectivity.Portal)
            return "portal";
        if (Networking.connectivity === NetworkConnectivity.Limited)
            return "limited";
        return "";
    }
    readonly property bool restricted: connectivity !== ""
    onKindChanged: Qt.callLater(function () {
        if (checksEnabled && kind !== "disconnected")
            Networking.checkConnectivity();
    })

    function toggleWifi() {
        if (nmAvailable)
            Networking.wifiEnabled = !Networking.wifiEnabled;
    }

    // ---------------- Wi-Fi list ----------------
    property var wifiNetworks: []

    function requiresCredentials(sec) {
        return sec !== WifiSecurityType.Open && sec !== WifiSecurityType.Owe;
    }
    function isEnterprise(sec) {
        return sec === WifiSecurityType.Wpa2Eap || sec === WifiSecurityType.WpaEap;
    }

    function syncWifiNetworks() {
        var rows = [];
        var nets = wifiNetworkObjects || [];
        for (var i = 0; i < nets.length; i++) {
            var n = nets[i];
            if (!n)
                continue;
            checkActionCompletion(n);
            rows.push({
                ssid: n.name || "",
                level: levelFor(n.signalStrength),
                security: n.security,
                known: !!n.known,
                connected: !!n.connected
            });
        }
        rows.sort(function (a, b) {
            return (b.connected - a.connected) || (b.known - a.known) || (b.level - a.level) || a.ssid.localeCompare(b.ssid);
        });
        // Only publish real changes: replacing the model rebuilds every row,
        // which would steal focus from the passphrase field mid-typing.
        if (JSON.stringify(rows) !== JSON.stringify(wifiNetworks))
            wifiNetworks = rows;
    }

    function networkForSsid(ssid) {
        var nets = wifiNetworkObjects || [];
        for (var i = 0; i < nets.length; i++)
            if (nets[i] && nets[i].name === ssid)
                return nets[i];
        return null;
    }

    onWifiNetworkObjectsChanged: syncWifiNetworks()
    onWifiDeviceChanged: {
        setScanner(active);
        syncWifiNetworks();
    }

    // ---------------- per-row actions ----------------
    property string actionSsid: ""
    property string actionKind: ""     // "connect" | "disconnect" | "forget"
    property string failureSsid: ""
    property string failureReason: ""
    property string passwordSsid: ""
    property string passwordText: ""
    readonly property bool busy: actionKind !== ""

    function runNetworkAction(kind, network, callback) {
        if (actionKind !== "" || !network)
            return;
        actionSsid = network.name || "";
        actionKind = kind;
        failureSsid = "";
        failureReason = "";
        callback(network);
        actionTimeout.restart();   // safety net if no completion signal ever arrives
    }

    function clearNetworkAction() {
        actionTimeout.stop();
        if (actionKind === "connect")
            passwordSsid = "";
        failureSsid = "";
        failureReason = "";
        actionSsid = "";
        actionKind = "";
        syncWifiNetworks();
        actionFinished();
    }

    function failNetworkAction(network, reason) {
        if (!network || actionKind === "" || actionSsid !== (network.name || ""))
            return;
        actionTimeout.stop();
        failureSsid = actionSsid;
        failureReason = failureText(reason, requiresCredentials(network.security));
        actionSsid = "";
        actionKind = "";
        syncWifiNetworks();
    }

    function authFailure(reason) {
        return reason === ConnectionFailReason.NoSecrets || reason === ConnectionFailReason.WifiAuthTimeout;
    }
    function failureText(reason, needsCreds) {
        if (needsCreds && authFailure(reason))
            return "Wrong password";
        if (reason === ConnectionFailReason.WifiNetworkLost)
            return "Network out of range";
        if (reason === ConnectionFailReason.WifiClientDisconnected)
            return "Disconnected";
        return "Couldn't connect";
    }

    function checkActionCompletion(network) {
        if (!network || actionKind === "" || actionSsid !== (network.name || ""))
            return;
        if (actionKind === "connect" && network.connected)
            clearNetworkAction();
        else if (actionKind === "disconnect" && !network.connected && !network.stateChanging)
            clearNetworkAction();
        else if (actionKind === "forget" && !network.known && !network.stateChanging)
            clearNetworkAction();
    }

    function openPasswordPrompt(ssid) {
        if (passwordSsid !== ssid)
            passwordText = "";
        passwordSsid = ssid;
    }
    function cancelPasswordPrompt() {
        passwordSsid = "";
        passwordText = "";
    }

    function connectDirectly(ssid) {
        runNetworkAction("connect", networkForSsid(ssid), function (n) {
            n.connect();
        });
    }
    function connectWithPassphrase(ssid, pw) {
        runNetworkAction("connect", networkForSsid(ssid), function (n) {
            n.connectWithPsk(pw);
        });
    }
    function disconnectSsid(ssid) {
        // Only act on a row that still resolves, never on "whatever is connected now".
        var n = networkForSsid(ssid);
        if (n)
            runNetworkAction("disconnect", n, function (x) {
                x.disconnect();
            });
    }
    function forgetSsid(ssid) {
        var n = networkForSsid(ssid);
        if (n)
            runNetworkAction("forget", n, function (x) {
                x.forget();
            });
    }
    function reportEnterpriseUnsupported(ssid) {
        failureSsid = ssid;
        failureReason = "Enterprise networks need a saved profile";
    }

    Timer {
        id: actionTimeout
        interval: 30000   // outlasts NetworkManager's ~25s auth timeout
        onTriggered: {
            if (!root.actionKind)
                return;
            root.failureSsid = root.actionSsid;
            root.failureReason = "Timed out";
            root.actionSsid = "";
            root.actionKind = "";
        }
    }

    // ---------------- scanner (shared flag on the device) ----------------
    property var scannerDevice: null
    function setScanner(enabled) {
        var next = enabled ? wifiDevice : null;
        if (scannerDevice && scannerDevice !== next)
            scannerDevice.scannerEnabled = false;
        scannerDevice = next;
        if (scannerDevice)
            scannerDevice.scannerEnabled = true;
    }
    Component.onDestruction: if (scannerDevice)
        scannerDevice.scannerEnabled = false

    onActiveChanged: {
        if (active) {
            failureSsid = "";
            failureReason = "";
            setScanner(true);
            syncWifiNetworks();
        } else {
            setScanner(false);
            cancelPasswordPrompt();
        }
    }

    Timer {
        interval: 2000
        repeat: true
        running: root.active
        onTriggered: root.syncWifiNetworks()
    }
}
