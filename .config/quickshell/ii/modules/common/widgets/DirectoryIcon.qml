import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

// From https://github.com/caelestia-dots/shell with modifications.
// License: GPLv3

Item {
    id: root
    required property var fileModelData

    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.small
        color: ColorUtils.applyAlpha(Appearance.colors.colPrimary, 0.08)
    }

    StyledImage {
        id: imageIcon
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.45, 56)
        height: Math.min(parent.height * 0.45, 56)
        fillMode: Image.PreserveAspectFit
        asynchronous: true

        source: {
            if (!fileModelData.fileIsDir)
                return Quickshell.iconPath("application-x-zerosize", "text-x-generic");

            if ([Directories.documents, Directories.downloads, Directories.music, Directories.pictures, Directories.videos].some(dir => FileUtils.trimFileProtocol(dir) === fileModelData.filePath))
                return Quickshell.iconPath(`folder-${fileModelData.fileName.toLowerCase()}`, "folder");

            return Quickshell.iconPath("folder", "inode-directory");
        }
    }

    MaterialSymbol {
        anchors.centerIn: parent
        visible: imageIcon.status !== Image.Ready
        iconSize: 42
        color: Appearance.colors.colPrimary
        text: fileModelData.fileIsDir ? "folder" : "description"
    }

    Process {
        running: !fileModelData.fileIsDir
        command: ["file", "--mime", "-b", fileModelData.filePath]
        stdout: StdioCollector {
            onStreamFinished: {
                const mime = text.split(";")[0].replace("/", "-");
                imageIcon.source = Images.validImageTypes.some(t => mime === `image-${t}`) ? fileModelData.fileUrl : Quickshell.iconPath(mime, "image-missing");
            }
        }
    }
}
