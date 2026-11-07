pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string username: Config.options?.customWidgets?.githubUsername ?? "Devrajsahani"
    property string repoPath: Config.options?.customWidgets?.activeRepoPath ?? "/home/dev/End4-Enhanced-Dev"
    
    property string activeRepoName: "End4-Enhanced-Dev"
    property string activeBranch: "main"
    property bool isClean: true
    property var localCommits: []
    property var remoteEvents: []
    property var contributions: []
    property int totalContributions: 0
    property bool isLoading: fetchProc.running

    function refresh() {
        if (!fetchProc.running) {
            fetchProc.running = true;
        }
    }

    Timer {
        id: autoRefreshTimer
        interval: 120000 // 2 minutes
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Process {
        id: fetchProc
        running: true
        command: ["/home/dev/.local/bin/ii-github-fetch", root.username, root.repoPath]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data.local) {
                        root.activeRepoName = data.local.name || "End4-Enhanced-Dev";
                        root.activeBranch = data.local.branch || "main";
                        root.isClean = !!data.local.clean;
                        root.localCommits = data.local.commits || [];
                    }
                    if (data.remote) {
                        root.remoteEvents = data.remote || [];
                    }
                    if (data.contributions) {
                        root.totalContributions = data.contributions.total || 0;
                        root.contributions = data.contributions.contributions || [];
                    }
                } catch (e) {
                    console.log("[GithubService] Parse error:", e);
                }
            }
        }
    }
}

