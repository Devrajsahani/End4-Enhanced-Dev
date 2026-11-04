import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property int filterMode: 0 // 0: All, 1: Active, 2: Done

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // Input bar
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 44
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer2
            border.width: 1
            border.color: newTaskInput.activeFocus ? Appearance.colors.colPrimary : Appearance.colors.colLayer0Border

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 8
                spacing: 8

                MaterialSymbol {
                    text: "add_task"
                    iconSize: 20
                    color: Appearance.colors.colPrimary
                }

                TextInput {
                    id: newTaskInput
                    Layout.fillWidth: true
                    verticalAlignment: TextInput.AlignVCenter
                    font.pixelSize: Appearance.font.pixelSize.normal
                    color: Appearance.colors.colOnLayer0
                    selectionColor: Appearance.colors.colPrimary
                    selectedTextColor: Appearance.colors.colOnPrimary
                    clip: true

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: Translation.tr("Add new task... (Press Enter)")
                        color: Appearance.colors.colSubtext
                        font: parent.font
                        visible: !newTaskInput.text && !newTaskInput.activeFocus
                    }

                    onAccepted: {
                        if (text.trim().length > 0) {
                            Todo.addTask(text.trim());
                            text = "";
                        }
                    }
                }

                RippleButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    buttonRadius: Appearance.rounding.small
                    colBackground: Appearance.colors.colPrimary
                    enabled: newTaskInput.text.trim().length > 0
                    opacity: enabled ? 1 : 0.4
                    onClicked: {
                        if (newTaskInput.text.trim().length > 0) {
                            Todo.addTask(newTaskInput.text.trim());
                            newTaskInput.text = "";
                        }
                    }
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        text: "arrow_forward"
                        iconSize: 18
                        color: Appearance.colors.colOnPrimary
                    }
                }
            }
        }

        // Filter chips row
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: [
                    { name: Translation.tr("All"), mode: 0 },
                    { name: Translation.tr("Active"), mode: 1 },
                    { name: Translation.tr("Done"), mode: 2 }
                ]

                delegate: RippleButton {
                    required property var modelData
                    implicitHeight: 28
                    implicitWidth: 70
                    buttonRadius: Appearance.rounding.full
                    colBackground: root.filterMode === modelData.mode ? Appearance.colors.colPrimary : Appearance.colors.colLayer2
                    onClicked: root.filterMode = modelData.mode

                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: modelData.name
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: root.filterMode === modelData.mode ? Font.Bold : Font.Normal
                        color: root.filterMode === modelData.mode ? Appearance.colors.colOnPrimary : Appearance.colors.colOnLayer0
                    }
                }
            }

            Item { Layout.fillWidth: true }

            StyledText {
                text: `${Todo.list.filter(i => !i.done).length} active`
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
            }
        }

        // Task List
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: listView
                model: Todo.list.map((item, index) => Object.assign({}, item, { originalIndex: index }))
                    .filter(item => {
                        if (root.filterMode === 1) return !item.done;
                        if (root.filterMode === 2) return item.done;
                        return true;
                    })
                spacing: 6

                delegate: Rectangle {
                    required property var modelData
                    width: listView.width
                    implicitHeight: 46
                    radius: Appearance.rounding.small
                    color: modelData.done ? Appearance.colors.colLayer1 : Appearance.colors.colLayer2
                    border.width: 1
                    border.color: Appearance.colors.colLayer0Border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 8
                        spacing: 10

                        // Checkbox
                        MouseArea {
                            implicitWidth: 24
                            implicitHeight: 24
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.done) {
                                    Todo.markUnfinished(modelData.originalIndex);
                                } else {
                                    Todo.markDone(modelData.originalIndex);
                                }
                            }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: modelData.done ? "check_box" : "check_box_outline_blank"
                                iconSize: 22
                                color: modelData.done ? Appearance.colors.colPrimary : Appearance.colors.colSubtext
                            }
                        }

                        // Task Content
                        StyledText {
                            Layout.fillWidth: true
                            text: modelData.content
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.strikeout: modelData.done
                            color: modelData.done ? Appearance.colors.colSubtext : Appearance.colors.colOnLayer0
                            elide: Text.ElideRight
                        }

                        // Delete action
                        RippleButton {
                            implicitWidth: 30
                            implicitHeight: 30
                            buttonRadius: Appearance.rounding.full
                            colBackground: "transparent"
                            colBackgroundHover: Appearance.colors.colLayer1Hover
                            onClicked: Todo.deleteItem(modelData.originalIndex)

                            contentItem: MaterialSymbol {
                                anchors.centerIn: parent
                                text: "delete_outline"
                                iconSize: 18
                                color: Appearance.colors.colSubtext
                            }
                        }
                    }
                }

                // Empty state
                Item {
                    anchors.centerIn: parent
                    visible: listView.count === 0
                    width: parent.width
                    height: 120

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        MaterialSymbol {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.filterMode === 2 ? "checklist" : "task_alt"
                            iconSize: 36
                            color: Appearance.colors.colSubtext
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.filterMode === 2 ? "No completed tasks yet" : "All tasks completed! Great work!"
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: Appearance.colors.colSubtext
                        }
                    }
                }
            }
        }
    }
}

