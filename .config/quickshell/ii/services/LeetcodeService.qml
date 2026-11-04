pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string username: Config.options?.customWidgets?.leetcodeUsername ?? "Devrajsahani"
    
    property string dailyTitle: "Minimum Operations to Make Elements Within K Subarrays Equal"
    property string dailyId: "3505"
    property string dailyDifficulty: "Hard"
    property real dailyAcRate: 55.8
    property string dailyLink: "https://leetcode.com/problems/minimum-operations-to-make-elements-within-k-subarrays-equal/"
    property var dailyTags: ["Array", "Hash Table", "Dynamic Programming"]
    
    property int totalSolved: 0
    property int easySolved: 0
    property int mediumSolved: 0
    property int hardSolved: 0
    property bool isLoading: fetchProc.running

    function refresh() {
        if (!fetchProc.running) {
            fetchProc.running = true;
        }
    }

    Timer {
        id: autoRefreshTimer
        interval: 300000 // 5 minutes
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Process {
        id: fetchProc
        running: true
        command: ["/home/dev/.local/bin/ii-leetcode-fetch", root.username]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data.daily) {
                        root.dailyTitle = data.daily.title || root.dailyTitle;
                        root.dailyId = data.daily.id || root.dailyId;
                        root.dailyDifficulty = data.daily.difficulty || "Medium";
                        root.dailyAcRate = data.daily.acRate || 50.0;
                        root.dailyLink = data.daily.link || root.dailyLink;
                        root.dailyTags = data.daily.tags || [];
                    }
                    if (data.user) {
                        root.totalSolved = data.user.totalSolved || 0;
                        root.easySolved = data.user.easySolved || 0;
                        root.mediumSolved = data.user.mediumSolved || 0;
                        root.hardSolved = data.user.hardSolved || 0;
                    }
                } catch (e) {
                    console.log("[LeetcodeService] Parse error:", e);
                }
            }
        }
    }
}

