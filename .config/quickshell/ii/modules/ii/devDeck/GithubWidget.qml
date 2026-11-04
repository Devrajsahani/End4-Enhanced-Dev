import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // Repo & Status Card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 64
            radius: Appearance.rounding.small
            color: Appearance.colors.colLayer2
            border.width: 1
            border.color: Appearance.colors.colLayer0Border

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                MaterialSymbol {
                    text: "source"
                    iconSize: 26
                    color: Appearance.colors.colPrimary
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        spacing: 8
                        StyledText {
                            text: GithubService.activeRepoName
                            font.pixelSize: Appearance.font.pixelSize.large
                            font.weight: Font.Bold
                            color: Appearance.colors.colOnLayer0
                        }

                        // Branch badge
                        Rectangle {
                            implicitHeight: 20
                            implicitWidth: branchRow.implicitWidth + 12
                            radius: Appearance.rounding.full
                            color: Appearance.colors.colPrimaryContainer

                            Row {
                                id: branchRow
                                anchors.centerIn: parent
                                spacing: 4
                                MaterialSymbol {
                                    text: "fork_right"
                                    iconSize: 13
                                    color: Appearance.colors.colOnPrimaryContainer
                                }
                                StyledText {
                                    text: GithubService.activeBranch
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: Appearance.colors.colOnPrimaryContainer
                                }
                            }
                        }

                        // Clean / modified badge
                        Rectangle {
                            implicitHeight: 20
                            implicitWidth: cleanRow.implicitWidth + 10
                            radius: Appearance.rounding.full
                            color: GithubService.isClean ? Appearance.colors.colLayer1 : Appearance.colors.colErrorContainer

                            Row {
                                id: cleanRow
                                anchors.centerIn: parent
                                spacing: 4
                                StyledText {
                                    text: GithubService.isClean ? "✔ clean" : "● modified"
                                    font.pixelSize: 11
                                    color: GithubService.isClean ? Appearance.colors.colSubtext : Appearance.colors.colOnErrorContainer
                                }
                            }
                        }
                    }

                    StyledText {
                        text: GithubService.repoPath
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: Appearance.colors.colSubtext
                        elide: Text.ElideMiddle
                    }
                }

                // Action Buttons
                RowLayout {
                    spacing: 6

                    RippleButton {
                        implicitWidth: 32
                        implicitHeight: 32
                        buttonRadius: Appearance.rounding.small
                        colBackground: Appearance.colors.colLayer1
                        onClicked: Quickshell.execDetached(["kitty", "-d", GithubService.repoPath])
                        StyledToolTip { text: "Open in Terminal" }
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "terminal"
                            iconSize: 18
                            color: Appearance.colors.colOnLayer0
                        }
                    }

                    RippleButton {
                        implicitWidth: 32
                        implicitHeight: 32
                        buttonRadius: Appearance.rounding.small
                        colBackground: Appearance.colors.colLayer1
                        onClicked: Quickshell.execDetached(["xdg-open", `https://github.com/${GithubService.username}/${GithubService.activeRepoName}`])
                        StyledToolTip { text: "Open in GitHub" }
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "open_in_browser"
                            iconSize: 18
                            color: Appearance.colors.colOnLayer0
                        }
                    }

                    RippleButton {
                        implicitWidth: 32
                        implicitHeight: 32
                        buttonRadius: Appearance.rounding.small
                        colBackground: Appearance.colors.colLayer1
                        onClicked: GithubService.refresh()
                        StyledToolTip { text: "Refresh Commits" }
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "refresh"
                            iconSize: 18
                            color: Appearance.colors.colOnLayer0
                        }
                    }
                }
            }
        }

        // Section Title
        RowLayout {
            Layout.fillWidth: true
            StyledText {
                text: Translation.tr("Recent Local Commits")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.DemiBold
                color: Appearance.colors.colOnLayer0
            }
            Item { Layout.fillWidth: true }
            StyledText {
                text: `${GithubService.localCommits.length} commits`
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colSubtext
            }
        }

        // Commits List
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ListView {
                id: commitList
                model: GithubService.localCommits
                spacing: 6

                delegate: Rectangle {
                    required property var modelData
                    width: commitList.width
                    implicitHeight: 52
                    radius: Appearance.rounding.small
                    color: Appearance.colors.colLayer1
                    border.width: 1
                    border.color: Appearance.colors.colLayer0Border

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        // Commit Hash Badge
                        Rectangle {
                            implicitHeight: 22
                            implicitWidth: 62
                            radius: 6
                            color: Appearance.colors.colLayer2
                            border.width: 1
                            border.color: Appearance.colors.colLayer0Border

                            StyledText {
                                anchors.centerIn: parent
                                text: modelData.hash
                                font.family: Appearance.font.family.monospace
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: Appearance.colors.colPrimary
                            }
                        }

                        // Commit Message & Info
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.message
                                font.pixelSize: Appearance.font.pixelSize.normal
                                color: Appearance.colors.colOnLayer0
                                elide: Text.ElideRight
                            }

                            RowLayout {
                                spacing: 8
                                StyledText {
                                    text: modelData.author
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    font.weight: Font.DemiBold
                                    color: Appearance.colors.colSubtext
                                }
                                StyledText {
                                    text: `•  ${modelData.time}`
                                    font.pixelSize: Appearance.font.pixelSize.smallest
                                    color: Appearance.colors.colSubtext
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
