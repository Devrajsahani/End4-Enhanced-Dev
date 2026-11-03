pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

/** Loads Illogical Impulse's Matugen palette as the one live Quickshell palette. */
Singleton {
    id: root
    property string filePath: Directories.generatedMaterialThemePath

    function reapplyTheme() {
        themeFileView.reload()
    }

    function applyColors(fileContent) {
        if (!fileContent)
            return
        try {
            const json = JSON.parse(fileContent)
            for (const key in json) {
                if (!Object.prototype.hasOwnProperty.call(json, key))
                    continue
                const camelCaseKey = key.replace(/_([a-z])/g, (g) => g[1].toUpperCase())
                const m3Key = `m3${camelCaseKey}`
                Appearance.m3colors[m3Key] = json[key]
            }
            Appearance.m3colors.darkmode = Appearance.m3colors.m3background.hslLightness < 0.5
            root.applyHyprlandWindowColors(json)
        } catch (error) {
            console.error("Unable to load Matugen colors:", error)
        }
    }

    function applyHyprlandWindowColors(json) {
        const outline = String(json.outline_variant ?? "").replace(/^#/, "")
        const surface = String(json.surface_container_low ?? "").replace(/^#/, "")
        if (!/^[A-Fa-f0-9]{6}$/.test(outline) || !/^[A-Fa-f0-9]{6}$/.test(surface))
            return

        // Keep Hyprland's window frame accents in sync with Matugen without a full reload.
        Quickshell.execDetached(["hyprctl", "keyword", "general:col.active_border", `rgba(${outline}77)`])
        Quickshell.execDetached(["hyprctl", "keyword", "general:col.inactive_border", `rgba(${surface}33)`])
    }

    Timer {
        id: delayedFileRead
        interval: Config.options?.hacks?.arbitraryRaceConditionDelay ?? 100
        repeat: false
        onTriggered: root.applyColors(themeFileView.text())
    }

    FileView {
        id: themeFileView
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            this.reload()
            delayedFileRead.start()
        }
        onLoadedChanged: root.applyColors(themeFileView.text())
    }

    function toggleLightDark() {
        Quickshell.execDetached(["/home/dev/.local/bin/ii-theme", "mode", "toggle"])
    }

    GlobalShortcut {
        name: "toggleLightDark"
        description: "Toggles between dark theme and light theme"
        onPressed: root.toggleLightDark()
    }

    IpcHandler {
        target: "theme"
        function toggleLightDark(): void {
            root.toggleLightDark()
        }

    }
}
