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
    implicitWidth: 336
    implicitHeight: cardContent.implicitHeight + 36

    StyledDropShadow {
        target: card
    }

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Appearance.rounding.windowRounding
        color: ColorUtils.applyAlpha(Appearance.colors.colLayer1Base, 0.96)
        border.width: 1
        border.color: ColorUtils.applyAlpha(Appearance.colors.colOutlineVariant, 0.82)

        ColumnLayout {
            id: cardContent
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 18
            }
            spacing: 11

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                StyledText {
                    Layout.fillWidth: true
                    text: "SCREEN TIME"
                    color: Appearance.colors.colOnLayer1
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.DemiBold
                }

                Rectangle {
                    implicitWidth: todayLabel.implicitWidth + 18
                    implicitHeight: todayLabel.implicitHeight + 8
                    radius: Appearance.rounding.full
                    color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.15)

                    StyledText {
                        id: todayLabel
                        anchors.centerIn: parent
                        text: "TODAY"
                        color: Appearance.colors.colPrimary
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.DemiBold
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                StyledText {
                    text: ScreenTime.available ? ScreenTime.formatDuration(ScreenTime.totalSeconds) : "—"
                    color: Appearance.colors.colOnLayer1
                    font.pixelSize: 42
                    font.weight: Font.DemiBold
                }

                StyledText {
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 8
                    text: ScreenTime.available ? "active today" : ScreenTime.status
                    color: Appearance.colors.colSubtext
                    font.pixelSize: Appearance.font.pixelSize.small
                    wrapMode: Text.WordWrap
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: ColorUtils.applyAlpha(Appearance.colors.colOutlineVariant, 0.48)
            }

            Repeater {
                model: ScreenTime.available ? ScreenTime.apps.slice(0, 3) : []
                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 12

                    StyledText {
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        text: modelData.name
                        color: Appearance.colors.colOnLayer1
                        font.pixelSize: Appearance.font.pixelSize.small
                    }

                    StyledText {
                        text: ScreenTime.formatDuration(modelData.seconds)
                        color: Appearance.colors.colSubtext
                        font.pixelSize: Appearance.font.pixelSize.small
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

            StyledText {
                Layout.fillWidth: true
                text: ScreenTime.updatedAt.length > 0 ? "Updated " + ScreenTime.updatedAt : "Drag card to move"
                color: Appearance.colors.colSubtext
                font.pixelSize: Appearance.font.pixelSize.smaller
            }
        }
    }
}
