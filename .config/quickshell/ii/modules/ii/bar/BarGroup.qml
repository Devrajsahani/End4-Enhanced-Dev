import qs.modules.common
import QtQuick
import QtQuick.Layouts
import qs.modules.common.functions

Item {
    id: root
    property bool vertical: false
    readonly property string layoutName: Persistent.states.bar?.layout ?? "reference"
    property bool surfaceVisible: true
    property real padding: layoutName === "minimal" ? 7 : 5
    implicitWidth: !visible ? 0 : (vertical ? Appearance.sizes.baseVerticalBarWidth : (gridLayout.implicitWidth + padding * 2))
    implicitHeight: !visible ? 0 : (vertical ? (gridLayout.implicitHeight + padding * 2) : Appearance.sizes.baseBarHeight)
    default property alias items: gridLayout.children

    Rectangle {
        id: background
        anchors {
            fill: parent
            topMargin: root.vertical ? 0 : (root.layoutName === "minimal" ? 1 : 3)
            bottomMargin: root.vertical ? 0 : (root.layoutName === "minimal" ? 1 : 3)
            leftMargin: root.vertical ? 4 : 0
            rightMargin: root.vertical ? 4 : 0
        }
        color: {
            if (Config.options?.bar.borderless || !root.surfaceVisible) return "transparent";
            // Matugen derives both surfaces from the active wallpaper; the accent blend
            // keeps each layout visibly wallpaper-linked while preserving readable content.
            const base = ColorUtils.mix(Appearance.m3colors.m3surfaceContainer, Appearance.m3colors.m3primaryContainer, root.layoutName === "centered" ? 0.20 : 0.14);
            return ColorUtils.applyAlpha(base, root.layoutName === "minimal" ? 0.86 : 0.80);
        }
        radius: Appearance.rounding.full
        border.width: Config.options?.bar.borderless || !root.surfaceVisible ? 0 : (root.layoutName === "centered" ? 1.5 : 1)
        border.color: ColorUtils.applyAlpha(ColorUtils.mix(Appearance.m3colors.m3outlineVariant, Appearance.m3colors.m3primary, root.layoutName === "centered" ? 0.72 : 0.48), root.layoutName === "minimal" ? 0.72 : 0.54)
        Behavior on color {
            ColorAnimation { duration: 360; easing.type: Easing.InOutCubic }
        }
        Behavior on border.color {
            ColorAnimation { duration: 360; easing.type: Easing.InOutCubic }
        }
        Behavior on border.width {
            NumberAnimation { duration: 360; easing.type: Easing.InOutCubic }
        }
    }

    GridLayout {
        id: gridLayout
        columns: root.vertical ? 1 : -1
        anchors {
            verticalCenter: root.vertical ? undefined : parent.verticalCenter
            horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
            left: root.vertical ? undefined : parent.left
            right: root.vertical ? undefined : parent.right
            top: root.vertical ? parent.top : undefined
            bottom: root.vertical ? parent.bottom : undefined
            margins: root.padding
        }
        columnSpacing: 4
        rowSpacing: 12
    }
}
