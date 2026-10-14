import QtQuick
import Quickshell.Io

// Connection details (IP, gateway, throughput) and DNS provider. No UI here.
Item {
    id: root

    property bool active: false

    property var details: ({})
    property real downRate: 0
    property real upRate: 0
    property string dnsProvider: ""
    property string pendingDns: ""
    readonly property var dnsProviders: ["DHCP", "Cloudflare", "Google"]

    property real prevRx: 0
    property real prevTx: 0
    property real prevTime: 0
    property string prevIface: ""

    readonly property string detailsScript: `
dev=$(ip -4 route show default 2>/dev/null | awk '{for(i=1;i<NF;i++) if($i=="dev"){print $(i+1); exit}}')
[ -n "$dev" ] || exit 0
echo "iface=$dev"
if [ -d "/sys/class/net/$dev/wireless" ]; then echo "type=wifi"; else echo "type=ethernet"; fi
addr=$(ip -4 -o addr show dev "$dev" scope global | awk '{print $4; exit}')
echo "ip=$(echo "$addr" | cut -d/ -f1)"
echo "gateway=$(ip -4 route show default dev "$dev" | awk '{for(i=1;i<NF;i++) if($i=="via"){print $(i+1); exit}}')"
echo "rx_bytes=$(cat /sys/class/net/$dev/statistics/rx_bytes 2>/dev/null)"
echo "tx_bytes=$(cat /sys/class/net/$dev/statistics/tx_bytes 2>/dev/null)"
`

    readonly property string dnsReadScript: `
c=$(nmcli -g GENERAL.CONNECTION device show "$1" 2>/dev/null)
[ -n "$c" ] || exit 0
dns=$(nmcli -g ipv4.dns connection show "$c" 2>/dev/null)
case "$dns" in
  "") echo DHCP ;;
  *1.1.1.1*) echo Cloudflare ;;
  *8.8.8.8*) echo Google ;;
  *) echo Custom ;;
esac
`

    readonly property string dnsWriteScript: `
c=$(nmcli -g GENERAL.CONNECTION device show "$1" 2>/dev/null)
[ -n "$c" ] || exit 1
case "$2" in
  DHCP) nmcli connection modify "$c" ipv4.ignore-auto-dns no ipv4.dns "" ;;
  Cloudflare) nmcli connection modify "$c" ipv4.ignore-auto-dns yes ipv4.dns "1.1.1.1 1.0.0.1" ;;
  Google) nmcli connection modify "$c" ipv4.ignore-auto-dns yes ipv4.dns "8.8.8.8 8.8.4.4" ;;
  *) exit 1 ;;
esac
nmcli connection up "$c"
`

    function parseKeyValue(raw) {
        var out = {};
        var lines = String(raw || "").split("\n");
        for (var i = 0; i < lines.length; i++) {
            var at = lines[i].indexOf("=");
            if (at > 0)
                out[lines[i].slice(0, at)] = lines[i].slice(at + 1).trim();
        }
        return out;
    }

    function update(raw) {
        var next = parseKeyValue(raw);
        var now = Date.now() / 1000;
        var rx = parseFloat(next.rx_bytes), tx = parseFloat(next.tx_bytes);
        // A fresh interface or the first sample has no baseline, so report 0, not a spike.
        if (next.iface && next.iface === prevIface && prevTime > 0 && now > prevTime && !isNaN(rx) && !isNaN(tx)) {
            var dt = now - prevTime;
            downRate = Math.max(0, (rx - prevRx) / dt);
            upRate = Math.max(0, (tx - prevTx) / dt);
        } else {
            downRate = 0;
            upRate = 0;
        }
        prevIface = next.iface || "";
        prevRx = isNaN(rx) ? 0 : rx;
        prevTx = isNaN(tx) ? 0 : tx;
        prevTime = now;
        details = next;
    }

    function refresh() {
        if (!detailsProc.running)
            detailsProc.running = true;
        if (details.iface && !dnsProc.running) {
            dnsProc.command = ["bash", "-c", dnsReadScript, "_", details.iface];
            dnsProc.running = true;
        }
    }

    function setDns(provider) {
        if (!details.iface || dnsSetProc.running)
            return;
        pendingDns = provider;
        dnsSetProc.command = ["bash", "-c", dnsWriteScript, "_", details.iface, provider];
        dnsSetProc.running = true;
    }

    function formatBytes(b) {
        if (isNaN(b))
            return "--";
        var units = ["B", "KB", "MB", "GB", "TB"], i = 0;
        while (b >= 1024 && i < units.length - 1) {
            b /= 1024;
            i++;
        }
        return (i === 0 ? Math.round(b) : b.toFixed(1)) + " " + units[i];
    }
    function formatRate(b) {
        return formatBytes(b) + "/s";
    }

    Process {
        id: detailsProc
        command: ["bash", "-c", root.detailsScript]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.update(text)
        }
    }
    Process {
        id: dnsProc
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: root.dnsProvider = text.trim()
        }
    }
    Process {
        id: dnsSetProc
        onExited: function (code) {
            if (code === 0)
                root.dnsProvider = root.pendingDns;
            root.pendingDns = "";
            root.refresh();
        }
    }

    // Poll only while the panel is open.
    Timer {
        interval: 1500
        repeat: true
        running: root.active
        onTriggered: root.refresh()
    }

    onActiveChanged: {
        if (active) {
            prevTime = 0;
            downRate = 0;
            upRate = 0;
            refresh();
        }
    }
}
