import qs.modules.common
import qs.modules.common.widgets
import qs.services
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property bool showBoth: false
    implicitHeight: Math.max(26, Appearance.sizes.baseBarHeight - 6)
    implicitWidth: speedButton.implicitWidth

    RippleButton {
        id: speedButton
        anchors.centerIn: parent
        implicitHeight: Math.max(26, Appearance.sizes.baseBarHeight - 6)
        implicitWidth: rowLayout.implicitWidth + 14
        buttonRadius: Appearance.rounding.full
        colBackground: "transparent"
        colBackgroundHover: Appearance.colors.colLayer1Hover

        onClicked: {
            root.showBoth = !root.showBoth
        }

        contentItem: RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            spacing: 4

            MaterialSymbol {
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                fill: 0
                text: "arrow_downward"
                iconSize: Appearance.font.pixelSize.normal
                color: NetworkSpeed.downSpeedBytes > (1024 * 1024) 
                    ? Appearance.colors.colPrimary 
                    : Appearance.colors.colOnLayer2
            }

            StyledText {
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                text: root.showBoth 
                    ? `↓ ${NetworkSpeed.downSpeedString}  ↑ ${NetworkSpeed.upSpeedString}`
                    : NetworkSpeed.downSpeedString
                font.pixelSize: Appearance.font.pixelSize.smaller
                font.weight: Font.DemiBold
                color: NetworkSpeed.downSpeedBytes > (1024 * 1024) 
                    ? Appearance.colors.colPrimary 
                    : Appearance.colors.colOnLayer1
            }
        }

        StyledToolTip {
            text: `↓ Download: ${NetworkSpeed.downSpeedString}\n↑ Upload: ${NetworkSpeed.upSpeedString}` + 
                  (NetworkSpeed.primaryInterface ? `\nInterface: ${NetworkSpeed.primaryInterface}` : "") +
                  `\n(Click to toggle upload display)`
        }
    }
}
