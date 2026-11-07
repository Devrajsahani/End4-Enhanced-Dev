pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property string status: "Waiting for screen-time data…"
    property int totalSeconds: 0
    property var apps: []
    property var hourly: []
    property string uptime: "—"
    property int currentHour: 12
    property string updatedAt: ""

    function refresh() {
        if (summaryProcess.running)
            return
        summaryProcess.running = true
    }

    function formatDuration(seconds) {
        const minutes = Math.floor(Math.max(0, seconds) / 60)
        const hours = Math.floor(minutes / 60)
        const remainder = minutes % 60
        if (hours > 0)
            return hours + "h " + remainder + "m"
        return minutes + "m"
    }

    Process {
        id: summaryProcess
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/ii/scripts/screen-time-summary.py"]
        stdout: StdioCollector {
            id: summaryOutput
            onStreamFinished: {
                try {
                    const result = JSON.parse(summaryOutput.text.trim())
                    if (!result.ok) {
                        root.available = false
                        root.status = "Awatcher is starting…"
                        return
                    }
                    root.totalSeconds = result.totalSeconds ?? 0
                    root.apps = result.apps ?? []
                    root.hourly = result.hourly ?? []
                    root.uptime = result.uptime ?? "—"
                    root.currentHour = result.currentHour ?? 12
                    root.updatedAt = result.updated ?? ""
                    root.available = true
                    root.status = root.totalSeconds > 0 ? "" : "No tracked time yet today"
                } catch (error) {
                    root.available = false
                    root.status = "Waiting for screen-time data…"
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.available = false
                root.status = "Awatcher is starting…"
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Timer {
        interval: 10000
        running: true
        repeat: false
        onTriggered: root.refresh()
    }
}
