import qs.modules.ii.bar.weather
import qs.modules.ii.sidebarRight.quickToggles.classicStyle
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.UPower
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Item { // Bar content region
    id: root

    property var screen: root.QsWindow.window?.screen
    property var brightnessMonitor: Brightness.getMonitorForScreen(screen)
    readonly property string selectedBarLayout: ["reference", "minimal", "centered", "noctalia", "control-deck"].includes(Persistent.states.bar?.layout ?? "reference") ? (Persistent.states.bar?.layout ?? "reference") : "reference"
    readonly property bool centeredLayout: ["centered", "control-deck"].includes(selectedBarLayout)
    readonly property bool noctaliaZones: selectedBarLayout === "noctalia"
    readonly property bool unifiedControls: selectedBarLayout === "noctalia" || selectedBarLayout === "control-deck"
    readonly property bool controlDeck: selectedBarLayout === "control-deck"
    property real useShortenedForm: (Appearance.sizes.barHellaShortenScreenWidthThreshold >= screen?.width) ? 2 : (Appearance.sizes.barShortenScreenWidthThreshold >= screen?.width) ? 1 : 0
    readonly property int centerSideModuleWidth: (useShortenedForm == 2) ? Appearance.sizes.barCenterSideModuleWidthHellaShortened : (useShortenedForm == 1) ? Appearance.sizes.barCenterSideModuleWidthShortened : Appearance.sizes.barCenterSideModuleWidth

    onSelectedBarLayoutChanged: layoutTransition.restart()

    SequentialAnimation {
        id: layoutTransition
        NumberAnimation { target: root; property: "opacity"; to: 0.72; duration: 90; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: 220; easing.type: Easing.OutCubic }
    }

    component VerticalBarSeparator: Rectangle {
        Layout.topMargin: Appearance.sizes.baseBarHeight / 3
        Layout.bottomMargin: Appearance.sizes.baseBarHeight / 3
        Layout.fillHeight: true
        implicitWidth: 1
        color: Appearance.colors.colOutlineVariant
    }

    // Background shadow
    Loader {
        active: Config.options.bar.showBackground && Config.options.bar.cornerStyle === 1 && Config.options.bar.floatStyleShadow
        anchors.fill: barBackground
        sourceComponent: StyledRectangularShadow {
            anchors.fill: undefined // The loader's anchors act on this, and this should not have any anchor
            target: barBackground
        }
    }
    // Background
    Rectangle {
        id: barBackground
        anchors {
            fill: parent
            margins: Config.options.bar.cornerStyle === 1 ? (Appearance.sizes.hyprlandGapsOut) : 0 // idk why but +1 is needed
        }
        // The bar surface stays transparent; BarGroup draws the individual pills.
        color: "transparent"
        radius: 0
        border.width: 0
    }

    // Noctalia-inspired module zones: one soft island for the left and right
    // groups, with the clock remaining an independent center capsule.
    Rectangle {
        visible: root.noctaliaZones
        z: 0
        anchors.left: parent.left
        anchors.leftMargin: Appearance.rounding.screenRounding
        anchors.verticalCenter: parent.verticalCenter
        width: leftSectionRowLayout.implicitWidth + 14
        height: Appearance.sizes.baseBarHeight - 4
        radius: Appearance.rounding.full
        color: ColorUtils.applyAlpha(ColorUtils.mix(Appearance.m3colors.m3surfaceContainer, Appearance.m3colors.m3primaryContainer, 0.20), 0.80)
        border.width: 1
        border.color: ColorUtils.applyAlpha(Appearance.m3colors.m3outlineVariant, 0.46)
        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutCubic } }
        Behavior on border.color { ColorAnimation { duration: 300; easing.type: Easing.InOutCubic } }
    }

    Rectangle {
        visible: root.unifiedControls
        z: 0
        anchors.right: parent.right
        anchors.rightMargin: Appearance.rounding.screenRounding
        anchors.verticalCenter: parent.verticalCenter
        // The row's implicit width already includes its right-side screen inset.
        // Subtract that inset here so it is not duplicated as dead space on the
        // left edge of the unified capsule.
        width: Math.max(0, rightSectionRowLayout.implicitWidth - Appearance.rounding.screenRounding)
        height: Appearance.sizes.baseBarHeight - (root.controlDeck ? 2 : 4)
        radius: Appearance.rounding.full
        color: ColorUtils.applyAlpha(ColorUtils.mix(Appearance.m3colors.m3surfaceContainer, Appearance.m3colors.m3primaryContainer, root.controlDeck ? 0.28 : 0.20), root.controlDeck ? 0.86 : 0.80)
        border.width: 1
        border.color: ColorUtils.applyAlpha(ColorUtils.mix(Appearance.m3colors.m3outlineVariant, Appearance.m3colors.m3primary, root.controlDeck ? 0.58 : 0.18), root.controlDeck ? 0.75 : 0.46)
        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutCubic } }
        Behavior on border.color { ColorAnimation { duration: 300; easing.type: Easing.InOutCubic } }
    }

    FocusedScrollMouseArea { // Left side | scroll to change brightness
        id: barLeftSideMouseArea

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: middleSection.left
        }
        implicitWidth: leftSectionRowLayout.implicitWidth
        implicitHeight: Appearance.sizes.baseBarHeight

        onScrollDown: Brightness.decreaseBrightness()
        onScrollUp: Brightness.increaseBrightness()
        onMovedAway: GlobalStates.osdBrightnessOpen = false
        // Visual content
        ScrollHint {
            reveal: barLeftSideMouseArea.hovered
            icon: Hyprsunset.gamma === 100 ? "light_mode" : "wb_twilight"
            tooltipText: Translation.tr("Scroll to change brightness")
            side: "left"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        RowLayout {
            id: leftSectionRowLayout
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: implicitWidth
            spacing: 4

            BarGroup { // Arch system-information launcher
                surfaceVisible: !root.noctaliaZones
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.fillWidth: false
                Layout.leftMargin: Appearance.rounding.screenRounding
                padding: 4

                GroupButton {
                    id: archInfoButton
                    baseWidth: 68
                    baseHeight: 28
                    clickedWidth: 72
                    clickedHeight: 30
                    buttonRadius: Appearance.rounding.full
                    buttonRadiusPressed: Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: ColorUtils.applyAlpha(Appearance.m3colors.m3primary, 0.14)
                    colBackgroundActive: ColorUtils.applyAlpha(Appearance.m3colors.m3primary, 0.20)
                    onClicked: Quickshell.execDetached(["kitty", "-1", "--hold=yes", "fish", "-i", "-c", "if type -q fastfetch; fastfetch; else; echo 'Fastfetch is not installed.'; echo 'Install it with: sudo pacman -S fastfetch'; end"])

                    contentItem: Row {
                        anchors.centerIn: parent
                        spacing: 5

                        MaterialSymbol {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "terminal"
                            iconSize: 18
                            color: Appearance.colors.colOnLayer1
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Arch"
                            color: Appearance.colors.colOnLayer1
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }
                    }

                    StyledToolTip {
                        text: "Open system information in Kitty"
                    }
                }
            }

            BarGroup {
                id: workspaceGroup
                surfaceVisible: !root.noctaliaZones
                visible: !root.centeredLayout
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.fillWidth: false
                padding: 4

                Workspaces {
                    id: workspacesWidget
                    Layout.fillHeight: true
                    MouseArea {
                        // Right-click to toggle overview
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onPressed: event => {
                            if (event.button === Qt.RightButton)
                                GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
                        }
                    }
                }
            }

            BarGroup {
                visible: root.selectedBarLayout === "minimal"
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                padding: 6

                ClockWidget {
                    showDate: false
                    Layout.alignment: Qt.AlignVCenter
                }
            }

        }
    }

    Row { // Middle section
        id: middleSection
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 4
        visible: root.selectedBarLayout !== "minimal"

        BarGroup {
            id: clockGroup
            anchors.verticalCenter: parent.verticalCenter
            padding: 6

            RowLayout {
                spacing: root.centeredLayout ? 8 : 0

                Workspaces {
                    visible: root.centeredLayout
                    Layout.fillHeight: true
                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.RightButton
                        onPressed: event => {
                            if (event.button === Qt.RightButton)
                                GlobalStates.overviewOpen = !GlobalStates.overviewOpen;
                        }
                    }
                }

                ClockWidget {
                    showDate: root.selectedBarLayout !== "minimal"
                    Layout.alignment: Qt.AlignVCenter
                }

                // Action Pill: Pending Tasks Badge
                RippleButton {
                    visible: Todo.list.some(function(item) { return !item.done; })
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 28
                    implicitWidth: todoPillLayout.implicitWidth + 16
                    buttonRadius: Appearance.rounding.full
                    colBackground: (GlobalStates.calendarPopupOpen && GlobalStates.calendarDeckTab === 0)
                        ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.28)
                        : ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.6)
                    colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.35)

                    onClicked: {
                        if (GlobalStates.calendarPopupOpen && GlobalStates.calendarDeckTab === 0) {
                            GlobalStates.calendarPopupOpen = false;
                        } else {
                            GlobalStates.calendarDeckTab = 0;
                            GlobalStates.calendarPopupOpen = true;
                        }
                    }

                    contentItem: RowLayout {
                        id: todoPillLayout
                        anchors.centerIn: parent
                        spacing: 4

                        MaterialSymbol {
                            text: "checklist"
                            iconSize: 15
                            color: Appearance.colors.colPrimary
                        }

                        StyledText {
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnLayer1
                            text: Todo.list.filter(function(item) { return !item.done; }).length.toString()
                        }
                    }

                    StyledToolTip {
                        text: Translation.tr("Pending Tasks: Click to view Agenda")
                    }
                }

                // Action Pill: Active Pomodoro Countdown
                RippleButton {
                    visible: TimerService.pomodoroRunning
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 28
                    implicitWidth: pomodoroPillLayout.implicitWidth + 16
                    buttonRadius: Appearance.rounding.full
                    colBackground: (GlobalStates.calendarPopupOpen && GlobalStates.calendarDeckTab === 1)
                        ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.32)
                        : ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.18)
                    colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.36)

                    onClicked: {
                        if (GlobalStates.calendarPopupOpen && GlobalStates.calendarDeckTab === 1) {
                            GlobalStates.calendarPopupOpen = false;
                        } else {
                            GlobalStates.calendarDeckTab = 1;
                            GlobalStates.calendarPopupOpen = true;
                        }
                    }

                    contentItem: RowLayout {
                        id: pomodoroPillLayout
                        anchors.centerIn: parent
                        spacing: 4

                        MaterialSymbol {
                            text: "timer"
                            iconSize: 15
                            color: Appearance.colors.colPrimary
                        }

                        StyledText {
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colPrimary
                            text: {
                                let mins = Math.floor(TimerService.pomodoroSecondsLeft / 60);
                                let secs = TimerService.pomodoroSecondsLeft % 60;
                                return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
                            }
                        }
                    }

                    StyledToolTip {
                        text: Translation.tr("Pomodoro Active: Click to view Timer")
                    }
                }
            }
        }
    }

    FocusedScrollMouseArea { // Right side | scroll to change volume
        id: barRightSideMouseArea

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: middleSection.right
            right: parent.right
        }
        implicitWidth: rightSectionRowLayout.implicitWidth
        implicitHeight: Appearance.sizes.baseBarHeight

        onScrollDown: Audio.decrementVolume();
        onScrollUp: Audio.incrementVolume();
        onMovedAway: GlobalStates.osdVolumeOpen = false;

        Rectangle {
            visible: root.selectedBarLayout === "minimal" && !Config.options?.bar.borderless
            z: 0
            anchors.right: parent.right
            anchors.rightMargin: Appearance.rounding.screenRounding
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(0, rightSectionRowLayout.implicitWidth - Appearance.rounding.screenRounding)
            height: Appearance.sizes.baseBarHeight - 6
            radius: Appearance.rounding.full
            color: ColorUtils.applyAlpha(ColorUtils.mix(Appearance.m3colors.m3surfaceContainer, Appearance.m3colors.m3primaryContainer, 0.18), 0.86)
            border.width: 1
            border.color: ColorUtils.applyAlpha(ColorUtils.mix(Appearance.m3colors.m3outlineVariant, Appearance.m3colors.m3primary, 0.48), 0.72)
            Behavior on color { ColorAnimation { duration: 360; easing.type: Easing.InOutCubic } }
            Behavior on border.color { ColorAnimation { duration: 360; easing.type: Easing.InOutCubic } }
        }
        // Visual content
        ScrollHint {
            reveal: barRightSideMouseArea.hovered
            icon: "volume_up"
            tooltipText: Translation.tr("Scroll to change volume")
            side: "right"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        RowLayout {
            id: rightSectionRowLayout
            anchors {
                top: parent.top
                bottom: parent.bottom
                right: parent.right
            }
            // Keep the controls packed as one right-aligned cluster. Stretching
            // this row across the whole right half separates the battery from
            // its neighboring indicators, especially in unified-control styles.
            width: implicitWidth
            z: 1
            spacing: 5
            layoutDirection: Qt.RightToLeft

            BarGroup { // Dedicated settings/control-center pill
                surfaceVisible: !root.unifiedControls && root.selectedBarLayout !== "minimal"
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: Appearance.rounding.screenRounding
                padding: 4

                RippleButton {
                    id: settingsPillButton
                    implicitWidth: 42
                    implicitHeight: 28
                    buttonRadius: Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: Appearance.colors.colLayer1Hover
                    onClicked: GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen

                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        text: "tune"
                        iconSize: Appearance.font.pixelSize.large
                        color: GlobalStates.sidebarRightOpen ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                    }

                    StyledToolTip {
                        text: Translation.tr("Open quick settings")
                    }
                }
            }

            BarGroup {
                surfaceVisible: !root.unifiedControls && root.selectedBarLayout !== "minimal"
                visible: BluetoothStatus.available
                Layout.alignment: Qt.AlignVCenter
                padding: 4

                BluetoothToggle {
                    baseWidth: 42
                    baseHeight: 28
                    clickedWidth: 46
                    clickedHeight: 30
                    buttonRadius: Appearance.rounding.full
                    buttonRadiusPressed: Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: ColorUtils.applyAlpha(Appearance.m3colors.m3primary, 0.12)
                    colBackgroundToggled: ColorUtils.applyAlpha(Appearance.m3colors.m3primaryContainer, 0.12)
                    colBackgroundToggledHover: ColorUtils.applyAlpha(Appearance.m3colors.m3primaryContainer, 0.18)
                    colBackgroundToggledActive: ColorUtils.applyAlpha(Appearance.m3colors.m3primaryContainer, 0.24)
                    altAction: () => GlobalStates.sidebarRightOpen = true
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        iconSize: 22
                        fill: parent.toggled ? 1 : 0
                        color: Appearance.colors.colOnLayer1
                        text: parent.buttonIcon
                    }
                }
            }

            BarGroup {
                surfaceVisible: !root.unifiedControls && root.selectedBarLayout !== "minimal"
                Layout.alignment: Qt.AlignVCenter
                padding: 4

                NetworkToggle {
                    baseWidth: 42
                    baseHeight: 28
                    clickedWidth: 46
                    clickedHeight: 30
                    buttonRadius: Appearance.rounding.full
                    buttonRadiusPressed: Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: ColorUtils.applyAlpha(Appearance.m3colors.m3primary, 0.12)
                    colBackgroundToggled: ColorUtils.applyAlpha(Appearance.m3colors.m3primaryContainer, 0.12)
                    colBackgroundToggledHover: ColorUtils.applyAlpha(Appearance.m3colors.m3primaryContainer, 0.18)
                    colBackgroundToggledActive: ColorUtils.applyAlpha(Appearance.m3colors.m3primaryContainer, 0.24)
                    altAction: () => GlobalStates.sidebarRightOpen = true
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        iconSize: 22
                        fill: parent.toggled ? 1 : 0
                        color: Appearance.colors.colOnLayer1
                        text: parent.buttonIcon
                    }
                }
            }

            BarGroup { // Power profile is its own clickable pill
                surfaceVisible: !root.unifiedControls && root.selectedBarLayout !== "minimal"
                Layout.alignment: Qt.AlignVCenter
                padding: 4

                UtilButtons {
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            BarGroup { // Network download speed indicator beside power profile
                surfaceVisible: !root.unifiedControls && root.selectedBarLayout !== "minimal"
                Layout.alignment: Qt.AlignVCenter
                padding: 4

                DownloadSpeed {
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            BarGroup {
                surfaceVisible: !root.unifiedControls && root.selectedBarLayout !== "minimal"
                visible: root.selectedBarLayout !== "minimal"
                Layout.alignment: Qt.AlignVCenter
                padding: 5

                Resources {
                    compact: true
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            BarGroup {
                surfaceVisible: !root.unifiedControls && root.selectedBarLayout !== "minimal"
                visible: Battery.available
                Layout.alignment: Qt.AlignVCenter
                padding: 6

                BatteryIndicator {
                    Layout.alignment: Qt.AlignVCenter
                }
            }

            BarGroup {
                surfaceVisible: !root.unifiedControls && root.selectedBarLayout !== "minimal"
                visible: root.useShortenedForm === 0 && root.selectedBarLayout === "reference" && (TrayService.pinnedItems.length + TrayService.unpinnedItems.length > 0)
                Layout.alignment: Qt.AlignVCenter
                Layout.minimumWidth: 0
                Layout.preferredWidth: visible ? implicitWidth : 0
                padding: visible ? 5 : 0

                SysTray {
                    Layout.fillHeight: true
                    invertSide: Config?.options.bar.bottom
                }
            }

            // Weather
            Loader {
                active: Config.options.bar.weather.enable
                Layout.leftMargin: active ? 4 : 0
                Layout.minimumWidth: 0
                Layout.preferredWidth: active ? implicitWidth : 0

                sourceComponent: BarGroup {
                    surfaceVisible: !root.unifiedControls && root.selectedBarLayout !== "minimal"
                    WeatherBar {}
                }
            }

        }
    }
}
