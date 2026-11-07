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

    configEntryName: "github"
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    property var hoveredDay: null

    StyledDropShadow {
        target: card
    }

    Rectangle {
        id: card
        implicitWidth: cardContent.implicitWidth + 36
        implicitHeight: cardContent.implicitHeight + 32
        radius: Appearance.rounding.windowRounding
        color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.94)
        border.width: 1
        border.color: ColorUtils.applyAlpha(Appearance.colors.colOutlineVariant, 0.70)

        ColumnLayout {
            id: cardContent
            anchors {
                top: parent.top
                left: parent.left
                margins: 18
            }
            spacing: 12

            // Top Header: Profile + Stats + External Link
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // GitHub / Code Icon Pill
                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: Appearance.rounding.small
                    color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.16)
                    border.width: 1
                    border.color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.28)

                    StyledText {
                        anchors.centerIn: parent
                        text: "</>"
                        color: Appearance.colors.colPrimary
                        font.pixelSize: 11
                        font.weight: Font.Bold
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        spacing: 6
                        StyledText {
                            text: "@" + GithubService.username
                            color: Appearance.colors.colOnLayer1
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.DemiBold
                        }

                        Rectangle {
                            visible: GithubService.isLoading
                            implicitWidth: 8
                            implicitHeight: 8
                            radius: 4
                            color: Appearance.colors.colPrimary
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                running: GithubService.isLoading
                                NumberAnimation { from: 0.3; to: 1.0; duration: 600 }
                                NumberAnimation { from: 1.0; to: 0.3; duration: 600 }
                            }
                        }
                    }

                    StyledText {
                        text: root.hoveredDay 
                            ? (root.hoveredDay.count + " contributions on " + root.hoveredDay.date)
                            : (GithubService.totalContributions + " contributions in the last year")
                        color: root.hoveredDay ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: root.hoveredDay ? Font.DemiBold : Font.Normal
                    }
                }

                // External Profile Button
                RippleButton {
                    implicitWidth: 30
                    implicitHeight: 30
                    buttonRadius: Appearance.rounding.full
                    colBackground: "transparent"
                    colBackgroundHover: ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.08)
                    onClicked: Qt.openUrlExternally("https://github.com/" + GithubService.username)

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "open_in_new"
                        color: Appearance.colors.colSubtext
                        iconSize: 16
                    }
                }
            }

            // Heatmap Grid Area
            Item {
                id: gridContainer
                readonly property int cellW: 6
                readonly property int cellH: 6
                readonly property int colGap: 2
                readonly property int rowGap: 2
                readonly property int totalCols: 52
                readonly property int totalRows: 7

                implicitWidth: totalCols * cellW + (totalCols - 1) * colGap
                implicitHeight: totalRows * cellH + (totalRows - 1) * rowGap

                Grid {
                    id: activityGrid
                    anchors.fill: parent
                    rows: 7
                    columns: 52
                    flow: Grid.TopToBottom
                    rowSpacing: gridContainer.rowGap
                    columnSpacing: gridContainer.colGap

                    Repeater {
                        model: {
                            const list = GithubService.contributions;
                            if (!list || list.length === 0) return 364;
                            // Take last 364 items (52 weeks x 7 days)
                            return Math.min(364, list.length);
                        }
                        delegate: Rectangle {
                            required property int index
                            width: gridContainer.cellW
                            height: gridContainer.cellH
                            radius: 1.5

                            readonly property var dayData: {
                                const list = GithubService.contributions;
                                if (!list || list.length === 0) return null;
                                const offset = Math.max(0, list.length - 364);
                                return list[offset + index] ?? null;
                            }
                            readonly property int level: dayData ? (dayData.level ?? 0) : 0
                            readonly property bool isHovered: root.hoveredDay && dayData && root.hoveredDay.date === dayData.date

                            color: {
                                if (level <= 0)
                                    return ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.09);
                                if (level === 1)
                                    return "#196127";
                                if (level === 2)
                                    return "#239a3b";
                                if (level === 3)
                                    return "#2ea043";
                                return "#39d353";
                            }
                            border.width: isHovered ? 1 : 0
                            border.color: Appearance.colors.colPrimary
                            scale: isHovered ? 1.6 : 1.0
                            z: isHovered ? 10 : 1

                            Behavior on scale {
                                NumberAnimation { duration: 120 }
                            }
                        }
                    }
                }

                // High-performance single mouse area for cell inspection
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    onPositionChanged: mouse => {
                        const cellTotalW = gridContainer.cellW + gridContainer.colGap;
                        const cellTotalH = gridContainer.cellH + gridContainer.rowGap;
                        const col = Math.floor(mouse.x / cellTotalW);
                        const row = Math.floor(mouse.y / cellTotalH);
                        if (col >= 0 && col < gridContainer.totalCols && row >= 0 && row < gridContainer.totalRows) {
                            const idx = col * 7 + row;
                            const list = GithubService.contributions;
                            if (list && list.length > 0) {
                                const offset = Math.max(0, list.length - 364);
                                root.hoveredDay = list[offset + idx] ?? null;
                                return;
                            }
                        }
                        root.hoveredDay = null;
                    }
                    onExited: root.hoveredDay = null
                }
            }

            // Legend / Status Footer
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    Layout.fillWidth: true
                    text: GithubService.activeRepoName ? ("Repo: " + GithubService.activeRepoName + " (" + GithubService.activeBranch + ")") : "Active developer activity"
                    color: Appearance.colors.colSubtext
                    font.pixelSize: 10
                    elide: Text.ElideRight
                }

                RowLayout {
                    spacing: 3
                    StyledText {
                        text: "Less"
                        color: Appearance.colors.colSubtext
                        font.pixelSize: 9
                    }
                    Rectangle { width: 5; height: 5; radius: 1; color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.09) }
                    Rectangle { width: 5; height: 5; radius: 1; color: "#196127" }
                    Rectangle { width: 5; height: 5; radius: 1; color: "#239a3b" }
                    Rectangle { width: 5; height: 5; radius: 1; color: "#2ea043" }
                    Rectangle { width: 5; height: 5; radius: 1; color: "#39d353" }
                    StyledText {
                        text: "More"
                        color: Appearance.colors.colSubtext
                        font.pixelSize: 9
                    }
                }
            }
        }
    }
}
