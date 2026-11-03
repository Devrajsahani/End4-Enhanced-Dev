pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real downSpeedBytes: 0
    property real upSpeedBytes: 0
    property string downSpeedString: "0 KB/s"
    property string upSpeedString: "0 KB/s"
    property string compactBothString: "↓0K ↑0K"
    property string primaryInterface: ""

    property real previousRxBytes: 0
    property real previousTxBytes: 0
    property double previousTimestamp: 0

    function formatSpeed(bytesPerSec) {
        if (!Number.isFinite(bytesPerSec) || bytesPerSec <= 0) {
            return "0 KB/s";
        }
        if (bytesPerSec < 1024) {
            return "0 KB/s";
        } else if (bytesPerSec < 1024 * 1024) {
            const kb = bytesPerSec / 1024;
            return kb >= 100 ? Math.round(kb) + " KB/s" : kb.toFixed(1) + " KB/s";
        } else if (bytesPerSec < 1024 * 1024 * 1024) {
            return (bytesPerSec / (1024 * 1024)).toFixed(1) + " MB/s";
        } else {
            return (bytesPerSec / (1024 * 1024 * 1024)).toFixed(2) + " GB/s";
        }
    }

    function formatCompact(bytesPerSec) {
        if (!Number.isFinite(bytesPerSec) || bytesPerSec < 1024) {
            return "0K";
        } else if (bytesPerSec < 1024 * 1024) {
            return Math.round(bytesPerSec / 1024) + "K";
        } else if (bytesPerSec < 1024 * 1024 * 1024) {
            return (bytesPerSec / (1024 * 1024)).toFixed(1) + "M";
        } else {
            return (bytesPerSec / (1024 * 1024 * 1024)).toFixed(1) + "G";
        }
    }

    FileView {
        id: netDevFile
        path: "/proc/net/dev"
    }

    Timer {
        id: pollTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            netDevFile.reload();
            const text = netDevFile.text();
            if (!text) return;

            const lines = text.split("\n");
            let totalRx = 0;
            let totalTx = 0;
            let bestIface = "";
            let maxIfaceRx = 0;

            for (let i = 2; i < lines.length; i++) {
                const line = lines[i].trim();
                if (!line) continue;
                const colonIdx = line.indexOf(":");
                if (colonIdx === -1) continue;

                const iface = line.substring(0, colonIdx).trim();
                // Ignore loopback, docker, veth, bridge, virbr
                if (iface === "lo" || iface.startsWith("docker") || iface.startsWith("veth") || 
                    iface.startsWith("br-") || iface.startsWith("virbr")) {
                    continue;
                }

                const data = line.substring(colonIdx + 1).trim().split(/\s+/);
                if (data.length >= 9) {
                    const rx = Number(data[0]) || 0;
                    const tx = Number(data[8]) || 0;
                    totalRx += rx;
                    totalTx += tx;
                    if (rx > maxIfaceRx) {
                        maxIfaceRx = rx;
                        bestIface = iface;
                    }
                }
            }

            const now = Date.now();
            if (root.previousTimestamp > 0 && now > root.previousTimestamp) {
                const dt = (now - root.previousTimestamp) / 1000.0;
                if (dt > 0.1) {
                    const dRx = totalRx - root.previousRxBytes;
                    const dTx = totalTx - root.previousTxBytes;

                    if (dRx >= 0 && root.previousRxBytes > 0) {
                        root.downSpeedBytes = dRx / dt;
                        root.downSpeedString = root.formatSpeed(root.downSpeedBytes);
                    }
                    if (dTx >= 0 && root.previousTxBytes > 0) {
                        root.upSpeedBytes = dTx / dt;
                        root.upSpeedString = root.formatSpeed(root.upSpeedBytes);
                    }
                    root.compactBothString = `↓${root.formatCompact(root.downSpeedBytes)} ↑${root.formatCompact(root.upSpeedBytes)}`;
                }
            }

            root.previousRxBytes = totalRx;
            root.previousTxBytes = totalTx;
            root.previousTimestamp = now;
            if (bestIface) {
                root.primaryInterface = bestIface;
            }
        }
    }
}
