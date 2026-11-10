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

    configEntryName: "screenTime"
    implicitWidth: card.implicitWidth
    implicitHeight: card.implicitHeight

    StyledDropShadow {
        target: card
    }

    Rectangle {
        id: card
        width: implicitWidth
        height: implicitHeight
        implicitWidth: 360
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

            // Header Row: Clock Icon + Title + Status Pill
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: Appearance.rounding.small
                    color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.16)
                    border.width: 1
                    border.color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.28)

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "schedule"
                        color: Appearance.colors.colPrimary
                        iconSize: 18
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    StyledText {
                        text: "Screen Time"
                        color: Appearance.colors.colOnLayer1
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.DemiBold
                    }

                    StyledText {
                        text: "Active window usage"
                        color: Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.smaller
                    }
                }

                Rectangle {
                    implicitWidth: todayLabel.implicitWidth + 14
                    implicitHeight: todayLabel.implicitHeight + 6
                    radius: Appearance.rounding.full
                    color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.14)

                    StyledText {
                        id: todayLabel
                        anchors.centerIn: parent
                        text: "TODAY"
                        color: Appearance.colors.colPrimary
                        font.pixelSize: 10
                        font.weight: Font.Bold
                    }
                }
            }

            // Stat Block: Large Active Time + System Uptime
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: ScreenTime.available ? ScreenTime.formatDuration(ScreenTime.totalSeconds) : "—"
                    color: Appearance.colors.colOnLayer1
                    font.pixelSize: 34
                    font.weight: Font.DemiBold
                }

                StyledText {
                    text: "Uptime: " + ScreenTime.uptime
                    color: Appearance.colors.colSubtext
                    font.pixelSize: Appearance.font.pixelSize.smaller
                }
            }

            // Hourly Activity Bar Chart
            Item {
                Layout.fillWidth: true
                implicitHeight: 52

                // Horizontal grid lines
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 14
                    width: parent.width
                    height: 1
                    color: ColorUtils.applyAlpha(Appearance.colors.colOutlineVariant, 0.35)
                }

                // Hourly Bars
                Row {
                    anchors.fill: parent
                    anchors.bottomMargin: 14
                    spacing: Math.max(2, (parent.width - (24 * 7)) / 23)

                    Repeater {
                        model: 24
                        delegate: Item {
                            required property int index
                            width: 7
                            height: parent.height

                            readonly property int activeSec: (ScreenTime.hourly && ScreenTime.hourly[index] !== undefined) ? ScreenTime.hourly[index] : 0
                            // Maximum active time in 1 hour is 3600 seconds
                            readonly property real fraction: Math.min(1.0, activeSec / 3600)
                            readonly property int barH: activeSec > 0 ? Math.max(4, Math.round(fraction * (parent.height - 4))) : 2
                            readonly property bool isCurrent: index === ScreenTime.currentHour

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: parent.barH
                                radius: 2
                                color: {
                                    if (parent.activeSec > 0) {
                                        return parent.isCurrent ? Appearance.colors.colPrimary : ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.70);
                                    }
                                    return ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.10);
                                }
                            }
                        }
                    }
                }

                // Time labels below baseline
                RowLayout {
                    anchors.bottom: parent.bottom
                    width: parent.width

                    StyledText {
                        text: "00:00"
                        color: Appearance.colors.colSubtext
                        font.pixelSize: 9
                    }

                    Item { Layout.fillWidth: true }

                    StyledText {
                        text: "12:00"
                        color: Appearance.colors.colSubtext
                        font.pixelSize: 9
                    }

                    Item { Layout.fillWidth: true }

                    StyledText {
                        text: "23:59"
                        color: Appearance.colors.colSubtext
                        font.pixelSize: 9
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: ColorUtils.applyAlpha(Appearance.colors.colOutlineVariant, 0.35)
            }

            // Top Apps: 2x2 Grid with Progress Bars
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 14
                visible: ScreenTime.available && ScreenTime.apps.length > 0

                Repeater {
                    model: ScreenTime.apps ? ScreenTime.apps.slice(0, 4) : []
                    delegate: ColumnLayout {
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        spacing: 3

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            // Small colored indicator or initial letter
                            Rectangle {
                                implicitWidth: 18
                                implicitHeight: 18
                                radius: 4
                                color: {
                                    const colors = [
                                        Appearance.colors.colPrimary,
                                        "#ff9800",
                                        "#00b8a3",
                                        "#9c27b0"
                                    ];
                                    return ColorUtils.applyAlpha(colors[index % colors.length], 0.20);
                                }
                                border.width: 1
                                border.color: {
                                    const colors = [
                                        Appearance.colors.colPrimary,
                                        "#ff9800",
                                        "#00b8a3",
                                        "#9c27b0"
                                    ];
                                    return ColorUtils.applyAlpha(colors[index % colors.length], 0.40);
                                }

                                StyledText {
                                    anchors.centerIn: parent
                                    text: modelData.name.length > 0 ? modelData.name[0].toUpperCase() : "?"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: Appearance.colors.colOnLayer1
                                }
                            }

                            StyledText {
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                text: modelData.name
                                color: Appearance.colors.colOnLayer1
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: ScreenTime.formatDuration(modelData.seconds)
                                color: Appearance.colors.colSubtext
                                font.pixelSize: 10
                            }
                        }

                        // App usage progress bar
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 3
                            radius: 1.5
                            color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.08)

                            Rectangle {
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                readonly property real ratio: ScreenTime.totalSeconds > 0 ? Math.min(1.0, modelData.seconds / ScreenTime.totalSeconds) : 0
                                width: Math.max(3, parent.width * ratio)
                                radius: 1.5
                                color: {
                                    const colors = [
                                        Appearance.colors.colPrimary,
                                        "#ff9800",
                                        "#00b8a3",
                                        "#9c27b0"
                                    ];
                                    return colors[index % colors.length];
                                }
                            }
                        }
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                visible: !ScreenTime.available || ScreenTime.apps.length === 0
                text: ScreenTime.status
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.small
                wrapMode: Text.WordWrap
            }
        }
    }
}
