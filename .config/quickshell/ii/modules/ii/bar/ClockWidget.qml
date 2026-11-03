import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool showDate: Config.options.bar.verbose
    implicitWidth: clockButton.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    RippleButton {
        id: clockButton
        anchors.centerIn: parent
        implicitWidth: rowLayout.implicitWidth + 18
        implicitHeight: Math.max(28, Appearance.sizes.baseBarHeight - 6)
        buttonRadius: Appearance.rounding.full

        colBackground: GlobalStates.calendarPopupOpen 
            ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.24) 
            : "transparent"
        colBackgroundHover: GlobalStates.calendarPopupOpen 
            ? ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.34) 
            : Appearance.colors.colLayer1Hover

        onClicked: {
            GlobalStates.calendarPopupOpen = !GlobalStates.calendarPopupOpen;
        }

        contentItem: RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 6

            MaterialSymbol {
                text: "schedule"
                iconSize: Appearance.font.pixelSize.normal
                color: GlobalStates.calendarPopupOpen ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
            }

            StyledText {
                font.pixelSize: Appearance.font.pixelSize.large
                font.weight: GlobalStates.calendarPopupOpen ? Font.DemiBold : Font.Normal
                color: GlobalStates.calendarPopupOpen ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                text: DateTime.time
            }

            StyledText {
                visible: root.showDate
                font.pixelSize: Appearance.font.pixelSize.small
                color: GlobalStates.calendarPopupOpen ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                text: "•"
            }

            StyledText {
                visible: root.showDate
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: GlobalStates.calendarPopupOpen ? Font.Medium : Font.Normal
                color: GlobalStates.calendarPopupOpen ? Appearance.colors.colPrimary : Appearance.colors.colOnLayer1
                text: DateTime.longDate
            }
        }

        StyledToolTip {
            text: GlobalStates.calendarPopupOpen 
                ? Translation.tr("Close Calendar & Agenda (Esc)") 
                : Translation.tr("Click to open Calendar, Tasks & Widgets")
        }
    }
}
