import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property bool showBoth: false

    // Strictly fixed width & height so the pill NEVER expands, shrinks or distracts
    width: 86
    implicitWidth: 86
    height: Math.max(26, Appearance.sizes.baseBarHeight - 6)
    implicitHeight: Math.max(26, Appearance.sizes.baseBarHeight - 6)
    clip: true

    Rectangle {
        id: bgHighlight
        anchors.fill: parent
        radius: Appearance.rounding.full
        color: mouseArea.containsMouse ? ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.08) : "transparent"
        Behavior on color { ColorAnimation { duration: 180 } }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        MaterialSymbol {
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            fill: 0
            text: root.showBoth ? "swap_vert" : "arrow_downward"
            iconSize: 16
            color: NetworkSpeed.downSpeedBytes > (1024 * 1024) 
                ? Appearance.colors.colPrimary 
                : Appearance.colors.colOnLayer2
        }

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: root.showBoth ? NetworkSpeed.compactBothString : NetworkSpeed.downSpeedString
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.weight: Font.DemiBold
            color: NetworkSpeed.downSpeedBytes > (1024 * 1024) 
                ? Appearance.colors.colPrimary 
                : Appearance.colors.colOnLayer1
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) {
                root.showBoth = !root.showBoth;
            } else if (mouse.button === Qt.RightButton) {
                Quickshell.execDetached(["kitty", "-e", "btop"]);
            }
        }
    }

    StyledToolTip {
        text: `↓ Download: ${NetworkSpeed.downSpeedString}\n↑ Upload: ${NetworkSpeed.upSpeedString}` + 
              (NetworkSpeed.primaryInterface ? `\nInterface: ${NetworkSpeed.primaryInterface}` : "") +
              `\n(Click to toggle compact dual view • Right-click for Btop)`
    }
}
