pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets

Scope {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: panelWindow
            required property ShellScreen modelData
            screen: modelData

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(panelWindow.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            visible: GlobalStates.calendarPopupOpen && monitorIsFocused

            function hide() {
                GlobalStates.calendarPopupOpen = false;
            }

            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.namespace: "quickshell:calendarDeck"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: GlobalStates.calendarPopupOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // Outside click dismissal backdrop
            MouseArea {
                anchors.fill: parent
                onClicked: panelWindow.hide()
            }

            Connections {
                target: GlobalStates
                function onCalendarPopupOpenChanged() {
                    if (GlobalStates.calendarPopupOpen) {
                        GlobalFocusGrab.addDismissable(panelWindow);
                    } else {
                        GlobalFocusGrab.removeDismissable(panelWindow);
                    }
                }
            }

            Connections {
                target: GlobalFocusGrab
                function onDismissed() {
                    panelWindow.hide();
                }
            }

            // Deck Container (prevent outside click from passing through)
            Item {
                id: deckContainer
                anchors.top: parent.top
                anchors.topMargin: Appearance.sizes.barHeight + Appearance.sizes.hyprlandGapsOut + 4
                anchors.horizontalCenter: parent.horizontalCenter
                implicitWidth: deckContent.implicitWidth
                implicitHeight: deckContent.implicitHeight

                // Consume clicks so they don't trigger backdrop MouseArea
                MouseArea {
                    anchors.fill: parent
                    // No onClicked: just blocks clicks
                }

                focus: GlobalStates.calendarPopupOpen
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        panelWindow.hide();
                        event.accepted = true;
                    }
                }

                StyledRectangularShadow {
                    target: deckContent
                }

                CalendarDeckContent {
                    id: deckContent
                    anchors.centerIn: parent
                }
            }
        }
    }

    IpcHandler {
        target: "calendarDeck"

        function toggle(): void {
            GlobalStates.calendarPopupOpen = !GlobalStates.calendarPopupOpen;
        }

        function close(): void {
            GlobalStates.calendarPopupOpen = false;
        }

        function open(): void {
            GlobalStates.calendarPopupOpen = true;
        }

        function openTab(tab: int): void {
            GlobalStates.calendarDeckTab = tab;
            GlobalStates.calendarPopupOpen = true;
        }
    }

    GlobalShortcut {
        name: "calendarDeckToggle"
        description: "Toggles calendar and widget deck on press"

        onPressed: {
            GlobalStates.calendarPopupOpen = !GlobalStates.calendarPopupOpen;
        }
    }
}
