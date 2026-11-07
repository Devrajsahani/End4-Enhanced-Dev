import QtQuick
import QtQuick.Layouts
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets
import qs.modules.common.widgets.widgetCanvas
import qs.modules.ii.background.widgets

AbstractBackgroundWidget {
    id: root

    configEntryName: "leetcode"
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    StyledDropShadow {
        target: card
    }

    Rectangle {
        id: card
        implicitWidth: 380
        implicitHeight: cardContent.implicitHeight + 36
        radius: Appearance.rounding.windowRounding
        color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.94)
        border.width: 1
        border.color: ColorUtils.applyAlpha(Appearance.colors.colOutlineVariant, 0.70)

        ColumnLayout {
            id: cardContent
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 18
            }
            spacing: 12

            // Top Header: Title & Difficulty Badge
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: Appearance.rounding.small
                    color: ColorUtils.applyAlpha("#ffa116", 0.18)
                    border.width: 1
                    border.color: ColorUtils.applyAlpha("#ffa116", 0.35)

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "code"
                        color: "#ffa116"
                        iconSize: 18
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: "DAILY CHALLENGE"
                        color: Appearance.colors.colSubtext
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }

                    StyledText {
                        text: "LeetCode Daily"
                        color: Appearance.colors.colOnLayer1
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                    }
                }

                // Difficulty Pill
                Rectangle {
                    readonly property string diff: LeetcodeService.dailyDifficulty || "Medium"
                    readonly property color diffColor: {
                        if (diff === "Easy") return "#00b8a3";
                        if (diff === "Hard") return "#ff375f";
                        return "#ffc01e";
                    }

                    implicitWidth: diffText.implicitWidth + 16
                    implicitHeight: diffText.implicitHeight + 6
                    radius: Appearance.rounding.full
                    color: ColorUtils.applyAlpha(diffColor, 0.16)
                    border.width: 1
                    border.color: ColorUtils.applyAlpha(diffColor, 0.35)

                    StyledText {
                        id: diffText
                        anchors.centerIn: parent
                        text: parent.diff
                        color: parent.diffColor
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }
                }
            }

            // Problem Title
            StyledText {
                Layout.fillWidth: true
                text: LeetcodeService.dailyTitle || "Daily Coding Challenge"
                color: Appearance.colors.colOnLayer1
                font.pixelSize: 14
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            // Stats Subtitle (ID & Acceptance Rate)
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    text: "#" + (LeetcodeService.dailyId || "—")
                    color: Appearance.colors.colSubtext
                    font.pixelSize: 11
                }

                StyledText {
                    text: "•"
                    color: Appearance.colors.colSubtext
                    font.pixelSize: 11
                }

                StyledText {
                    text: (LeetcodeService.dailyAcRate ? LeetcodeService.dailyAcRate.toFixed(1) : "—") + "% Acceptance"
                    color: Appearance.colors.colSubtext
                    font.pixelSize: 11
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: LeetcodeService.totalSolved > 0 ? (LeetcodeService.totalSolved + " solved") : ""
                    color: Appearance.colors.colPrimary
                    font.pixelSize: 11
                    font.weight: Font.Medium
                }
            }

            // Tags Flow
            Flow {
                Layout.fillWidth: true
                spacing: 6
                visible: (LeetcodeService.dailyTags && LeetcodeService.dailyTags.length > 0)

                Repeater {
                    model: LeetcodeService.dailyTags ? LeetcodeService.dailyTags.slice(0, 4) : []
                    delegate: Rectangle {
                        required property string modelData
                        implicitWidth: tagText.implicitWidth + 12
                        implicitHeight: tagText.implicitHeight + 4
                        radius: 4
                        color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.07)

                        StyledText {
                            id: tagText
                            anchors.centerIn: parent
                            text: modelData
                            color: Appearance.colors.colSubtext
                            font.pixelSize: 10
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: ColorUtils.applyAlpha(Appearance.colors.colOutlineVariant, 0.35)
            }

            // Bottom Solve Button
            RippleButton {
                Layout.fillWidth: true
                implicitHeight: 34
                buttonRadius: Appearance.rounding.small
                colBackground: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.14)
                colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.24)
                onClicked: {
                    if (LeetcodeService.dailyLink) {
                        Qt.openUrlExternally(LeetcodeService.dailyLink);
                    } else {
                        Qt.openUrlExternally("https://leetcode.com/problemset/all/");
                    }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    MaterialSymbol {
                        text: "play_arrow"
                        color: Appearance.colors.colPrimary
                        iconSize: 16
                    }

                    StyledText {
                        text: "Solve on LeetCode"
                        color: Appearance.colors.colPrimary
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    MaterialSymbol {
                        text: "open_in_new"
                        color: Appearance.colors.colPrimary
                        iconSize: 13
                    }
                }
            }
        }
    }
}
