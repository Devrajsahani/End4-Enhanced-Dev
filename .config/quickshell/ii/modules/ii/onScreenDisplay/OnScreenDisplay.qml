import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    property string protectionMessage: ""
    property string currentIndicator: "volume" // "volume" | "brightness" | "mic" | "gamma"
    property bool osdActive: false

    readonly property real volumeValue: Audio.sink?.audio?.volume ?? 0
    readonly property bool volumeMuted: Audio.sink?.audio?.muted ?? false
    readonly property real brightnessValue: Brightness.value
    readonly property bool micMuted: Audio.source?.audio?.muted ?? false

    function showVolume() {
        root.protectionMessage = "";
        root.currentIndicator = "volume";
        root.triggerOsd();
    }

    function showBrightness() {
        root.protectionMessage = "";
        root.currentIndicator = "brightness";
        root.triggerOsd();
    }

    function showMic() {
        root.protectionMessage = "";
        root.currentIndicator = "mic";
        root.triggerOsd();
    }

    function triggerOsd() {
        root.osdActive = true;
        GlobalStates.osdVolumeOpen = true;
        osdTimeout.restart();
    }

    function dismissOsd() {
        root.osdActive = false;
        closeDelayTimer.restart();
    }

    Timer {
        id: osdTimeout
        interval: 2200
        repeat: false
        running: false
        onTriggered: {
            root.dismissOsd();
        }
    }

    Timer {
        id: closeDelayTimer
        interval: 250
        repeat: false
        running: false
        onTriggered: {
            GlobalStates.osdVolumeOpen = false;
            root.protectionMessage = "";
        }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged() {
            root.showBrightness();
        }
    }

    Connections {
        target: Hyprsunset
        function onGammaChangeAttempt() {
            root.protectionMessage = "";
            root.currentIndicator = "gamma";
            root.triggerOsd();
        }
    }

    Connections {
        target: Audio.sink?.audio ?? null
        function onVolumeChanged() {
            if (!Audio.ready) return;
            root.showVolume();
        }
        function onMutedChanged() {
            if (!Audio.ready) return;
            root.showVolume();
        }
    }

    Connections {
        target: Audio.source?.audio ?? null
        function onMutedChanged() {
            if (!Audio.ready) return;
            root.showMic();
        }
    }

    Connections {
        target: Audio
        function onSinkProtectionTriggered(reason) {
            root.protectionMessage = reason;
            root.showVolume();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: osdWindow
            required property ShellScreen modelData
            screen: modelData

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(osdWindow.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            visible: GlobalStates.osdVolumeOpen && monitorIsFocused

            WlrLayershell.namespace: "quickshell:onScreenDisplay"
            WlrLayershell.layer: WlrLayer.Overlay
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
                bottom: false
            }
            implicitHeight: Appearance.sizes.barHeight + 120
            margins.top: 0

            mask: Region {
                item: headerPill
            }

            Item {
                id: headerPill
                anchors.horizontalCenter: parent.horizontalCenter
                y: root.osdActive ? (Appearance.sizes.barHeight + 12) : (Appearance.sizes.barHeight - 35)
                opacity: root.osdActive ? 1.0 : 0.0
                implicitWidth: 320
                implicitHeight: 58
                width: implicitWidth
                height: implicitHeight

                Behavior on y {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.1
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }

                StyledRectangularShadow {
                    target: pillBackground
                }

                Rectangle {
                    id: pillBackground
                    anchors.fill: parent
                    radius: Appearance.rounding.full
                    color: ColorUtils.applyAlpha(Appearance.m3colors.m3surfaceContainerHigh, 0.94)
                    border.width: 1.5
                    border.color: ColorUtils.applyAlpha(Appearance.m3colors.m3outlineVariant, 0.45)

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.dismissOsd()
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 16
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 12

                        // Icon badge
                        Rectangle {
                            id: iconBadge
                            implicitWidth: 40
                            implicitHeight: 40
                            radius: 20
                            Layout.alignment: Qt.AlignVCenter

                            readonly property bool isErrorState: {
                                if (root.currentIndicator === "volume") return root.volumeMuted;
                                if (root.currentIndicator === "mic") return root.micMuted;
                                return false;
                            }

                            color: isErrorState
                                ? ColorUtils.applyAlpha(Appearance.m3colors.m3error, 0.18)
                                : ColorUtils.applyAlpha(Appearance.m3colors.m3primary, 0.14)

                            MaterialSymbol {
                                anchors.centerIn: parent
                                iconSize: 22
                                color: iconBadge.isErrorState
                                    ? Appearance.m3colors.m3error
                                    : Appearance.colors.colPrimary

                                text: {
                                    if (root.currentIndicator === "brightness") {
                                        if (root.brightnessValue > 0.6) return "light_mode";
                                        if (root.brightnessValue > 0.25) return "brightness_medium";
                                        return "brightness_low";
                                    }
                                    if (root.currentIndicator === "mic") {
                                        return root.micMuted ? "mic_off" : "mic";
                                    }
                                    if (root.currentIndicator === "gamma") {
                                        return "wb_twilight";
                                    }
                                    // volume
                                    if (root.volumeMuted) return "volume_off";
                                    if (root.volumeValue > 0.6) return "volume_up";
                                    if (root.volumeValue > 0.2) return "volume_down";
                                    return "volume_mute";
                                }
                            }
                        }

                        // Right details & slider
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 4

                            // Title & percentage row
                            RowLayout {
                                Layout.fillWidth: true

                                StyledText {
                                    Layout.fillWidth: true
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.bold: true
                                    color: Appearance.colors.colOnLayer0
                                    text: {
                                        if (root.currentIndicator === "brightness") return Translation.tr("Brightness");
                                        if (root.currentIndicator === "mic") return Translation.tr("Microphone");
                                        if (root.currentIndicator === "gamma") return Translation.tr("Night Light");
                                        return Translation.tr("Volume");
                                    }
                                }

                                StyledText {
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.bold: true
                                    Layout.alignment: Qt.AlignRight

                                    readonly property bool isMuted: {
                                        if (root.currentIndicator === "volume") return root.volumeMuted;
                                        if (root.currentIndicator === "mic") return root.micMuted;
                                        return false;
                                    }

                                    color: isMuted ? Appearance.m3colors.m3error : Appearance.colors.colPrimary

                                    text: {
                                        if (root.currentIndicator === "brightness") {
                                            return `${Math.round(root.brightnessValue * 100)}%`;
                                        }
                                        if (root.currentIndicator === "mic") {
                                            return root.micMuted ? Translation.tr("MUTED") : Translation.tr("ACTIVE");
                                        }
                                        if (root.currentIndicator === "gamma") {
                                            return `${Hyprsunset.gamma}%`;
                                        }
                                        if (root.volumeMuted) {
                                            return Translation.tr("MUTED");
                                        }
                                        return `${Math.round(root.volumeValue * 100)}%`;
                                    }
                                }
                            }

                            // Progress bar track
                            Rectangle {
                                id: progressTrack
                                Layout.fillWidth: true
                                height: 6
                                radius: 3
                                color: ColorUtils.applyAlpha(Appearance.m3colors.m3onSurface, 0.14)

                                readonly property real fillFraction: {
                                    if (root.currentIndicator === "brightness") {
                                        return Math.max(0, Math.min(1.0, root.brightnessValue));
                                    }
                                    if (root.currentIndicator === "mic") {
                                        return root.micMuted ? 0.0 : 1.0;
                                    }
                                    if (root.currentIndicator === "gamma") {
                                        return Math.max(0, Math.min(1.0, Hyprsunset.gamma / 100.0));
                                    }
                                    if (root.volumeMuted) return 0.0;
                                    // Volume can exceed 100% up to 150%
                                    const maxVal = root.volumeValue > 1.0 ? 1.5 : 1.0;
                                    return Math.max(0, Math.min(1.0, root.volumeValue / maxVal));
                                }

                                Rectangle {
                                    id: progressFill
                                    height: parent.height
                                    radius: parent.radius
                                    width: Math.max(0, Math.min(progressTrack.width, progressTrack.width * progressTrack.fillFraction))

                                    readonly property bool isMuted: {
                                        if (root.currentIndicator === "volume") return root.volumeMuted;
                                        if (root.currentIndicator === "mic") return root.micMuted;
                                        return false;
                                    }

                                    color: isMuted ? Appearance.m3colors.m3error : Appearance.colors.colPrimary

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 100
                                            easing.type: Easing.OutQuad
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Protection warning pill
                Rectangle {
                    id: protectionWarningPill
                    visible: root.protectionMessage !== ""
                    anchors {
                        top: pillBackground.bottom
                        topMargin: 6
                        horizontalCenter: parent.horizontalCenter
                    }
                    implicitHeight: warningRow.implicitHeight + 10
                    implicitWidth: warningRow.implicitWidth + 20
                    radius: Appearance.rounding.full
                    color: Appearance.m3colors.m3error

                    RowLayout {
                        id: warningRow
                        anchors.centerIn: parent
                        spacing: 6

                        MaterialSymbol {
                            text: "dangerous"
                            iconSize: Appearance.font.pixelSize.normal
                            color: Appearance.m3colors.m3onError
                        }
                        StyledText {
                            text: root.protectionMessage
                            color: Appearance.m3colors.m3onError
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.bold: true
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "osd"

        function showVolume(): void {
            root.showVolume();
        }

        function showBrightness(): void {
            root.showBrightness();
        }

        function showMic(): void {
            root.showMic();
        }

        function trigger(): void {
            root.triggerOsd();
        }

        function hide(): void {
            root.dismissOsd();
        }

        function toggle(): void {
            if (root.osdActive) root.dismissOsd();
            else root.triggerOsd();
        }
    }

    IpcHandler {
        target: "osdVolume"

        function trigger(): void {
            root.triggerOsd();
        }

        function hide(): void {
            root.dismissOsd();
        }

        function toggle(): void {
            if (root.osdActive) root.dismissOsd();
            else root.triggerOsd();
        }
    }

    GlobalShortcut {
        name: "osdVolumeTrigger"
        description: "Triggers volume OSD on press"
        onPressed: root.triggerOsd()
    }

    GlobalShortcut {
        name: "osdVolumeHide"
        description: "Hides volume OSD on press"
        onPressed: {
            GlobalStates.osdVolumeOpen = false;
        }
    }
}
