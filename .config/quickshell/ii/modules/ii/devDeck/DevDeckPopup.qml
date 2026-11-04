pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs
import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

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

            visible: GlobalStates.devDeckOpen && monitorIsFocused

            function hide() {
                GlobalStates.devDeckOpen = false;
            }

            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            color: "transparent"
            WlrLayershell.namespace: "quickshell:devDeck"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: GlobalStates.devDeckOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

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
                function onDevDeckOpenChanged() {
                    if (GlobalStates.devDeckOpen) {
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

            // Deck Container
            Item {
                id: deckContainer
                anchors.top: parent.top
                anchors.topMargin: Appearance.sizes.barHeight + Appearance.sizes.hyprlandGapsOut + 4
                anchors.right: parent.right
                anchors.rightMargin: 80 // Aligned with the top-right cluster

                implicitWidth: Config.options?.customWidgets?.devDeckWidth ?? 540
                implicitHeight: Config.options?.customWidgets?.devDeckHeight ?? 520

                // Consume clicks so they don't trigger backdrop MouseArea
                MouseArea {
                    anchors.fill: parent
                }

                focus: GlobalStates.devDeckOpen
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        panelWindow.hide();
                        event.accepted = true;
                    }
                }

                StyledRectangularShadow {
                    target: deckCard
                }

                // Main Frosted Acrylic Deck Card
                Rectangle {
                    id: deckCard
                    anchors.fill: parent
                    radius: Appearance.rounding.large
                    color: Appearance.colors.colLayer0
                    border.width: 1.5
                    border.color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.4)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 12

                        // Header & Tab Bar Row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            RowLayout {
                                spacing: 8
                                MaterialSymbol {
                                    text: "terminal"
                                    iconSize: 22
                                    color: Appearance.colors.colPrimary
                                }
                                StyledText {
                                    text: "Developer Hub"
                                    font.pixelSize: Appearance.font.pixelSize.large
                                    font.weight: Font.Bold
                                    color: Appearance.colors.colOnLayer0
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // Tab Pill Selector
                            Rectangle {
                                implicitHeight: 34
                                implicitWidth: tabRow.implicitWidth + 8
                                radius: Appearance.rounding.full
                                color: Appearance.colors.colLayer1
                                border.width: 1
                                border.color: Appearance.colors.colLayer0Border

                                Row {
                                    id: tabRow
                                    anchors.centerIn: parent
                                    spacing: 4

                                    Repeater {
                                        model: [
                                            { icon: "checklist", name: "To-Do", tab: 0 },
                                            { icon: "commit", name: "GitHub", tab: 1 },
                                            { icon: "code", name: "LeetCode", tab: 2 }
                                        ]

                                        delegate: RippleButton {
                                            required property var modelData
                                            implicitHeight: 28
                                            implicitWidth: tabContentRow.implicitWidth + 16
                                            buttonRadius: Appearance.rounding.full
                                            colBackground: GlobalStates.devDeckTab === modelData.tab ? Appearance.colors.colPrimary : "transparent"
                                            onClicked: GlobalStates.devDeckTab = modelData.tab

                                            Row {
                                                id: tabContentRow
                                                anchors.centerIn: parent
                                                spacing: 5
                                                MaterialSymbol {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: modelData.icon
                                                    iconSize: 15
                                                    color: GlobalStates.devDeckTab === modelData.tab ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer0
                                                }
                                                StyledText {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: modelData.name
                                                    font.pixelSize: 12
                                                    font.weight: GlobalStates.devDeckTab === modelData.tab ? Font.Bold : Font.Normal
                                                    color: GlobalStates.devDeckTab === modelData.tab ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer0
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Close Button
                            RippleButton {
                                implicitWidth: 32
                                implicitHeight: 32
                                buttonRadius: Appearance.rounding.full
                                colBackground: "transparent"
                                colBackgroundHover: Appearance.colors.colLayer1Hover
                                onClicked: panelWindow.hide()

                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "close"
                                    iconSize: 18
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }

                        // Divider
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 1
                            color: Appearance.colors.colLayer0Border
                        }

                        // Tab Content Area
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            TodoDeckWidget {
                                anchors.fill: parent
                                visible: GlobalStates.devDeckTab === 0
                            }

                            GithubWidget {
                                anchors.fill: parent
                                visible: GlobalStates.devDeckTab === 1
                            }

                            LeetcodeWidget {
                                anchors.fill: parent
                                visible: GlobalStates.devDeckTab === 2
                            }
                        }
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "devDeck"

        function toggle(): void {
            GlobalStates.devDeckOpen = !GlobalStates.devDeckOpen;
        }

        function close(): void {
            GlobalStates.devDeckOpen = false;
        }

        function open(): void {
            GlobalStates.devDeckOpen = true;
        }

        function openTab(tab: int): void {
            GlobalStates.devDeckTab = tab;
            GlobalStates.devDeckOpen = true;
        }
    }

    GlobalShortcut {
        name: "devDeckToggle"
        description: "Toggles Developer and Study Hub Deck"

        onPressed: {
            GlobalStates.devDeckOpen = !GlobalStates.devDeckOpen;
        }
    }

    GlobalShortcut {
        name: "devDeckGithub"
        description: "Open Developer Hub to GitHub"

        onPressed: {
            GlobalStates.devDeckTab = 1;
            GlobalStates.devDeckOpen = true;
        }
    }

    GlobalShortcut {
        name: "devDeckLeetcode"
        description: "Open Developer Hub to LeetCode"

        onPressed: {
            GlobalStates.devDeckTab = 2;
            GlobalStates.devDeckOpen = true;
        }
    }
}
