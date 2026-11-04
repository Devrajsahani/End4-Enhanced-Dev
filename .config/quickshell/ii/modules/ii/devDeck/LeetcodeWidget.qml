import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    readonly property color colDiff: {
        switch (LeetcodeService.dailyDifficulty) {
            case "Easy": return "#22c55e";
            case "Medium": return "#f59e0b";
            case "Hard": return "#ef4444";
            default: return Appearance.colors.colPrimary;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Hero Daily Card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 180
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer2
            border.width: 1.5
            border.color: root.colDiff

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                // Header row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    MaterialSymbol {
                        text: "code"
                        iconSize: 22
                        color: root.colDiff
                    }

                    StyledText {
                        text: "DAILY CODING CHALLENGE"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        font.letterSpacing: 1.0
                        color: root.colDiff
                    }

                    Item { Layout.fillWidth: true }

                    // Difficulty chip
                    Rectangle {
                        implicitHeight: 22
                        implicitWidth: diffText.implicitWidth + 16
                        radius: Appearance.rounding.full
                        color: ColorUtils.applyAlpha(root.colDiff, 0.2)
                        border.width: 1
                        border.color: root.colDiff

                        StyledText {
                            id: diffText
                            anchors.centerIn: parent
                            text: LeetcodeService.dailyDifficulty
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: root.colDiff
                        }
                    }
                }

                // Problem Title
                StyledText {
                    Layout.fillWidth: true
                    text: `${LeetcodeService.dailyId}. ${LeetcodeService.dailyTitle}`
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    color: Appearance.colors.colOnLayer0
                    elide: Text.ElideRight
                }

                // Tags Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    Repeater {
                        model: LeetcodeService.dailyTags
                        delegate: Rectangle {
                            required property var modelData
                            implicitHeight: 22
                            implicitWidth: tagLabel.implicitWidth + 12
                            radius: 6
                            color: Appearance.colors.colLayer1
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border

                            StyledText {
                                id: tagLabel
                                anchors.centerIn: parent
                                text: modelData
                                font.pixelSize: 11
                                color: Appearance.colors.colOnLayer1
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Acceptance rate
                    StyledText {
                        text: `Acceptance: ${LeetcodeService.dailyAcRate}%`
                        font.pixelSize: 11
                        color: Appearance.colors.colSubtext
                    }
                }

                Item { Layout.fillHeight: true }

                // Actions row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    RippleButton {
                        Layout.fillWidth: true
                        implicitHeight: 38
                        buttonRadius: Appearance.rounding.small
                        colBackground: root.colDiff
                        onClicked: Quickshell.execDetached(["xdg-open", LeetcodeService.dailyLink])

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 8
                            MaterialSymbol {
                                text: "open_in_new"
                                iconSize: 18
                                color: "#000000"
                            }
                            StyledText {
                                text: "Solve Problem on LeetCode"
                                font.pixelSize: 13
                                font.weight: Font.Bold
                                color: "#000000"
                            }
                        }
                    }

                    RippleButton {
                        implicitWidth: 38
                        implicitHeight: 38
                        buttonRadius: Appearance.rounding.small
                        colBackground: Appearance.colors.colLayer1
                        onClicked: LeetcodeService.refresh()
                        StyledToolTip { text: "Refresh Daily Question" }
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "refresh"
                            iconSize: 20
                            color: Appearance.colors.colOnLayer0
                        }
                    }
                }
            }
        }

        // Student & Dev Productivity Tips / Study Motivation
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer1
            border.width: 1
            border.color: Appearance.colors.colLayer0Border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                RowLayout {
                    spacing: 8
                    MaterialSymbol {
                        text: "psychology"
                        iconSize: 20
                        color: Appearance.colors.colPrimary
                    }
                    StyledText {
                        text: "Daily Study Strategy"
                        font.pixelSize: Appearance.font.pixelSize.normal
                        font.weight: Font.DemiBold
                        color: Appearance.colors.colOnLayer0
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "• Spend 25 minutes understanding constraints before writing code.\n• Identify subproblems: Recursion tree → Memoization → Bottom-up table.\n• Practice explaining your optimal time & space complexity clearly."
                    font.pixelSize: 12
                    lineHeight: 1.4
                    color: Appearance.colors.colOnLayer1
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
