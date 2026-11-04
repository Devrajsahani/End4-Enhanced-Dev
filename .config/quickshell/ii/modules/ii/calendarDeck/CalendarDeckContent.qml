pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.modules.ii.sidebarRight
import qs.modules.ii.sidebarRight.calendar
import qs.modules.ii.sidebarRight.todo
import qs.modules.ii.sidebarRight.pomodoro

Rectangle {
    id: root

    implicitWidth: Config.options?.customWidgets?.calendarDeckWidth ?? 780
    implicitHeight: Config.options?.customWidgets?.calendarDeckHeight ?? 520
    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer0
    border.width: 1
    border.color: Appearance.colors.colLayer0Border

    // Selected tab inside the right pane (0: Todo, 1: Timer, 2: Widgets)
    property int currentDeckTab: GlobalStates.calendarDeckTab

    Connections {
        target: GlobalStates
        function onCalendarDeckTabChanged() {
            root.currentDeckTab = GlobalStates.calendarDeckTab;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        // Top Header Row
        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Big Clock & Date
            RowLayout {
                spacing: 10

                MaterialSymbol {
                    text: "calendar_today"
                    iconSize: 26
                    color: Appearance.colors.colPrimary
                }

                ColumnLayout {
                    spacing: 1

                    RowLayout {
                        spacing: 6
                        StyledText {
                            font.pixelSize: Appearance.font.pixelSize.larger * 1.3
                            font.weight: Font.DemiBold
                            color: Appearance.colors.colOnLayer0
                            text: DateTime.time
                        }
                        StyledText {
                            font.pixelSize: Appearance.font.pixelSize.small
                            color: Appearance.colors.colPrimary
                            text: "•"
                        }
                        StyledText {
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnLayer0
                            text: DateTime.longDate
                        }
                    }

                    RowLayout {
                        spacing: 8
                        StyledText {
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnSurfaceVariant
                            text: Translation.tr("Uptime: %1").arg(DateTime.uptime)
                        }

                        StyledText {
                            visible: Todo.list.length > 0
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colPrimary
                            text: "• " + Translation.tr("%1 tasks pending").arg(Todo.list.filter(function(i) { return !i.done; }).length)
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // Action Buttons in Header
            RowLayout {
                spacing: 6

                // Do Not Disturb Toggle Button
                RippleButton {
                    implicitWidth: 38
                    implicitHeight: 34
                    buttonRadius: Appearance.rounding.small
                    colBackground: Notifications.silent ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.22) : ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.7)
                    colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.3)
                    onClicked: Notifications.silent = !Notifications.silent

                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        text: Notifications.silent ? "notifications_off" : "notifications_active"
                        iconSize: Appearance.font.pixelSize.large
                        color: Notifications.silent ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                    }

                    StyledToolTip {
                        text: Notifications.silent ? Translation.tr("Unmute notifications") : Translation.tr("Do Not Disturb")
                    }
                }

                // Quick Pomodoro Toggle
                RippleButton {
                    implicitHeight: 34
                    implicitWidth: pomodoroBtnRow.implicitWidth + 20
                    buttonRadius: Appearance.rounding.small
                    colBackground: TimerService.pomodoroRunning ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.25) : ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.7)
                    colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.35)
                    onClicked: TimerService.togglePomodoro()

                    contentItem: RowLayout {
                        id: pomodoroBtnRow
                        anchors.centerIn: parent
                        spacing: 6

                        MaterialSymbol {
                            text: TimerService.pomodoroRunning ? "pause" : "timer"
                            iconSize: Appearance.font.pixelSize.normal
                            color: TimerService.pomodoroRunning ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                        }

                        StyledText {
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.Medium
                            color: TimerService.pomodoroRunning ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                            text: {
                                if (TimerService.pomodoroRunning) {
                                    let mins = Math.floor(TimerService.pomodoroSecondsLeft / 60);
                                    let secs = TimerService.pomodoroSecondsLeft % 60;
                                    return (mins < 10 ? "0" : "") + mins + ":" + (secs < 10 ? "0" : "") + secs;
                                }
                                return Translation.tr("Focus");
                            }
                        }
                    }

                    StyledToolTip {
                        text: TimerService.pomodoroRunning ? Translation.tr("Pause Pomodoro timer") : Translation.tr("Start 25m Focus session")
                    }
                }

                // Close Button
                RippleButton {
                    implicitWidth: 34
                    implicitHeight: 34
                    buttonRadius: Appearance.rounding.small
                    colBackground: ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.6)
                    colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colError, 0.25)
                    onClicked: GlobalStates.calendarPopupOpen = false

                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        text: "close"
                        iconSize: Appearance.font.pixelSize.normal
                        color: Appearance.colors.colOnLayer1
                    }

                    StyledToolTip {
                        text: Translation.tr("Close (Esc)")
                    }
                }
            }
        }

        // Horizontal Separator
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Appearance.colors.colOutlineVariant
            opacity: 0.4
        }

        // Two-Column Main Content
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            // Left Pane: Calendar Widget & Summary Card
            ColumnLayout {
                Layout.preferredWidth: 325
                Layout.fillHeight: true
                spacing: 10

                // Calendar View Container
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colLayer0Border
                    clip: true

                    CalendarWidget {
                        anchors.centerIn: parent
                    }
                }

                // Today Quick Info Card
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: Appearance.rounding.small
                    color: ColorUtils.applyAlpha(Appearance.colors.colPrimaryContainer, 0.25)
                    border.width: 1
                    border.color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.2)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        MaterialSymbol {
                            text: "event_available"
                            iconSize: 18
                            color: Appearance.colors.colPrimary
                        }

                        StyledText {
                            Layout.fillWidth: true
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: Appearance.colors.colOnLayer0
                            text: {
                                const unfinished = Todo.list.filter(function(i) { return !i.done; }).length;
                                return unfinished > 0 
                                    ? Translation.tr("Today: %1 pending tasks remaining").arg(unfinished)
                                    : Translation.tr("Today: All tasks caught up!");
                            }
                        }

                        RippleButton {
                            implicitWidth: 28
                            implicitHeight: 28
                            buttonRadius: Appearance.rounding.full
                            colBackground: "transparent"
                            colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.2)
                            onClicked: {
                                root.currentDeckTab = 0;
                                GlobalStates.calendarDeckTab = 0;
                            }

                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "arrow_forward"
                                iconSize: 16
                                color: Appearance.colors.colPrimary
                            }

                            StyledToolTip {
                                text: Translation.tr("View to-do list")
                            }
                        }
                    }
                }
            }

            // Vertical Separator
            Rectangle {
                Layout.fillHeight: true
                implicitWidth: 1
                color: Appearance.colors.colOutlineVariant
                opacity: 0.35
            }

            // Right Pane: Dynamic Multi-View Deck (Tasks, Timer, Widgets)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                // Segmented Tab Selector Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: [
                            {
                                id: 0,
                                label: Translation.tr("To-Do"),
                                icon: "checklist",
                                badge: Todo.list.filter(function(i) { return !i.done; }).length
                            },
                            {
                                id: 1,
                                label: Translation.tr("Timer"),
                                icon: "schedule",
                                badge: TimerService.pomodoroRunning ? "●" : 0
                            },
                            {
                                id: 2,
                                label: Translation.tr("Widgets"),
                                icon: "tune",
                                badge: 0
                            }
                        ]

                        delegate: RippleButton {
                            id: tabButton
                            required property var modelData

                            Layout.fillWidth: true
                            implicitHeight: 34
                            buttonRadius: Appearance.rounding.small
                            colBackground: (root.currentDeckTab === modelData.id)
                                ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.22)
                                : ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.6)
                            colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.32)

                            onClicked: {
                                root.currentDeckTab = modelData.id;
                                GlobalStates.calendarDeckTab = modelData.id;
                            }

                            contentItem: RowLayout {
                                anchors.centerIn: parent
                                spacing: 5

                                MaterialSymbol {
                                    text: tabButton.modelData.icon
                                    iconSize: Appearance.font.pixelSize.normal
                                    color: (root.currentDeckTab === tabButton.modelData.id) ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                                }

                                StyledText {
                                    font.pixelSize: Appearance.font.pixelSize.small
                                    font.weight: (root.currentDeckTab === tabButton.modelData.id) ? Font.DemiBold : Font.Normal
                                    color: (root.currentDeckTab === tabButton.modelData.id) ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                                    text: tabButton.modelData.label
                                }

                                // Badge count
                                Rectangle {
                                    visible: tabButton.modelData.badge !== 0
                                    implicitWidth: badgeText.implicitWidth + 8
                                    implicitHeight: 16
                                    radius: 8
                                    color: (root.currentDeckTab === tabButton.modelData.id) ? Appearance.colors.colPrimary : Appearance.colors.colLayer2

                                    StyledText {
                                        id: badgeText
                                        anchors.centerIn: parent
                                        font.pixelSize: 10
                                        font.weight: Font.Bold
                                        color: (root.currentDeckTab === tabButton.modelData.id) ? Appearance.colors.colOnPrimary : Appearance.colors.colPrimary
                                        text: tabButton.modelData.badge.toString()
                                    }
                                }
                            }
                        }
                    }
                }

                // Deck Content View
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colLayer0Border
                    clip: true

                    StackLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        currentIndex: root.currentDeckTab

                        // Page 0: Large To-Do Agenda View
                        Item {
                            id: todoPage
                            TodoWidget {
                                anchors.fill: parent
                            }
                        }

                        // Page 1: Pomodoro & Stopwatch
                        Item {
                            id: timerPage
                            PomodoroWidget {
                                anchors.fill: parent
                            }
                        }

                        // Page 2: Quick Widgets (Sliders, Resources, Media)
                        Item {
                            id: widgetsPage
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 6
                                spacing: 10

                                // Sliders Card
                                QuickSliders {
                                    Layout.fillWidth: true
                                }

                                // System Resources Card
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 70
                                    radius: Appearance.rounding.small
                                    color: Appearance.colors.colLayer2
                                    border.width: 1
                                    border.color: Appearance.colors.colLayer0Border

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 12

                                        // CPU
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            RowLayout {
                                                MaterialSymbol { text: "memory"; iconSize: 16; color: Appearance.colors.colPrimary }
                                                StyledText { text: "CPU"; font.pixelSize: Appearance.font.pixelSize.smaller; color: Appearance.colors.colOnSurfaceVariant }
                                            }
                                            StyledText {
                                                text: `${Math.round(ResourceUsage.cpuUsage * 100)}%`
                                                font.pixelSize: Appearance.font.pixelSize.normal
                                                font.weight: Font.DemiBold
                                                color: Appearance.colors.colOnLayer2
                                            }
                                            StyledProgressBar {
                                                Layout.fillWidth: true
                                                value: ResourceUsage.cpuUsage
                                            }
                                        }

                                        // Memory
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2
                                            RowLayout {
                                                MaterialSymbol { text: "storage"; iconSize: 16; color: Appearance.colors.colPrimary }
                                                StyledText { text: "RAM"; font.pixelSize: Appearance.font.pixelSize.smaller; color: Appearance.colors.colOnSurfaceVariant }
                                            }
                                            StyledText {
                                                text: `${Math.round(ResourceUsage.memoryUsedPercentage * 100)}%`
                                                font.pixelSize: Appearance.font.pixelSize.normal
                                                font.weight: Font.DemiBold
                                                color: Appearance.colors.colOnLayer2
                                            }
                                            StyledProgressBar {
                                                Layout.fillWidth: true
                                                value: ResourceUsage.memoryUsedPercentage
                                            }
                                        }
                                    }
                                }

                                // Media Controller summary card (if player active)
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    radius: Appearance.rounding.small
                                    color: Appearance.colors.colLayer2
                                    border.width: 1
                                    border.color: Appearance.colors.colLayer0Border

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10

                                        MaterialSymbol {
                                            text: MprisController.activePlayer?.isPlaying ? "album" : "music_off"
                                            iconSize: 28
                                            color: Appearance.colors.colPrimary
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1

                                            StyledText {
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                                font.pixelSize: Appearance.font.pixelSize.small
                                                font.weight: Font.Medium
                                                color: Appearance.colors.colOnLayer2
                                                text: MprisController.activePlayer?.trackTitle || Translation.tr("No media playing")
                                            }

                                            StyledText {
                                                Layout.fillWidth: true
                                                elide: Text.ElideRight
                                                font.pixelSize: Appearance.font.pixelSize.smaller
                                                color: Appearance.colors.colOnSurfaceVariant
                                                text: MprisController.activePlayer?.trackArtist || Translation.tr("Play audio in browser or player")
                                            }
                                        }

                                        RowLayout {
                                            visible: !!MprisController.activePlayer
                                            spacing: 4

                                            RippleButton {
                                                implicitWidth: 30
                                                implicitHeight: 30
                                                buttonRadius: Appearance.rounding.full
                                                colBackground: "transparent"
                                                colBackgroundHover: Appearance.colors.colLayer1Hover
                                                onClicked: MprisController.activePlayer?.previous()
                                                contentItem: MaterialSymbol { anchors.centerIn: parent; text: "skip_previous"; iconSize: 18; color: Appearance.colors.colOnLayer2 }
                                            }

                                            RippleButton {
                                                implicitWidth: 32
                                                implicitHeight: 32
                                                buttonRadius: Appearance.rounding.full
                                                colBackground: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.2)
                                                colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.35)
                                                onClicked: MprisController.activePlayer?.playPause()
                                                contentItem: MaterialSymbol { anchors.centerIn: parent; text: MprisController.activePlayer?.isPlaying ? "pause" : "play_arrow"; iconSize: 20; color: Appearance.colors.colPrimary }
                                            }

                                            RippleButton {
                                                implicitWidth: 30
                                                implicitHeight: 30
                                                buttonRadius: Appearance.rounding.full
                                                colBackground: "transparent"
                                                colBackgroundHover: Appearance.colors.colLayer1Hover
                                                onClicked: MprisController.activePlayer?.next()
                                                contentItem: MaterialSymbol { anchors.centerIn: parent; text: "skip_next"; iconSize: 18; color: Appearance.colors.colOnLayer2 }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
