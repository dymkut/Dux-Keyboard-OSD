import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets

// DMS Keyboard OSD settings
// Author: Dymkut
// License: AGPL-3.0-only

FocusScope {
    id: root

    readonly property string pluginId: "dms-kosd"
    property var pluginService: null

    implicitHeight: settingsColumn.implicitHeight + 32
    height: implicitHeight

    // Settings shown in this page
    property string currentMode: loadSettings("displayMode", "flag_iso")
    property bool currentTintFlag: loadSettings("tintFlag", false)
    property int currentInterval: loadSettings("autoHideInterval", 1200)
    property var customMapObj: {
        try {
            var raw = loadSettings("customMap", "{}");
            return typeof raw === "string" ? JSON.parse(raw) : raw;
        } catch (e) {
            console.warn("DMS Keyboard OSD: Invalid saved aliases:", e);
            return {};
        }
    }
    property string searchFilter: ""

    // Layouts available in the alias editor
    readonly property var allSupportedLayouts: [
        "Arabic", "Armenian", "Bosnian", "Bulgarian", "Catalan", "Chinese",
        "Croatian", "Czech", "Danish", "Dutch", "English", "English (US)",
        "Estonian", "Finnish", "French", "Georgian", "German", "Greek",
        "Hebrew", "Hindi", "Hungarian", "Icelandic", "Indonesian", "Italian",
        "Japanese", "Kazakh", "Korean", "Latvian", "Lithuanian", "Norwegian",
        "Polish", "Portuguese", "Portuguese (Brazil)", "Romanian", "Russian",
        "Serbian", "Slovak", "Slovenian", "Spanish", "Swedish", "Swiss French",
        "Swiss German", "Thai", "Turkish", "Ukrainian", "Vietnamese"
    ]

    function saveSettings(key, value) {
        if (pluginService) {
            pluginService.savePluginData(pluginId, key, value);
            if (pluginService.setGlobalVar) {
                pluginService.setGlobalVar(pluginId, key, value);
            }
        }
    }

    function loadSettings(key, defaultValue) {
        if (pluginService)
            return pluginService.loadPluginData(pluginId, key, defaultValue);
        return defaultValue;
    }

    Column {
        id: settingsColumn
        anchors.fill: parent
        anchors.margins: 16
        spacing: 20

        // Display style
        Column {
            width: parent.width
            spacing: 12

            Text {
                text: "Display Style"
                font.pixelSize: 15
                font.bold: true
                color: Theme.primary
            }

            Text {
                text: "Select layout presentation style"
                font.pixelSize: 12
                color: Qt.rgba(1, 1, 1, 0.7)
            }

            Row {
                spacing: 8
                width: parent.width

                Repeater {
                    model: [
                        { "id": "flag_iso", "label": "Flag + ISO" },
                        { "id": "iso", "label": "ISO Only" },
                        { "id": "iso_flag", "label": "ISO + Flag" },
                        { "id": "custom", "label": "Custom" }
                    ]

                    Rectangle {
                        width: (settingsColumn.width - 24) / 4
                        height: 38
                        radius: 8
                        color: root.currentMode === modelData.id ? Theme.primary : Qt.rgba(1, 1, 1, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.pixelSize: 13
                            font.bold: root.currentMode === modelData.id
                            color: root.currentMode === modelData.id ? "#000000" : "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.currentMode = modelData.id;
                                root.saveSettings("displayMode", modelData.id);
                            }
                        }
                    }
                }
            }

            // Theme color for flags
            Row {
                spacing: 12
                width: parent.width

                Rectangle {
                    width: 22
                    height: 22
                    radius: 6
                    color: root.currentTintFlag ? Theme.primary : Qt.rgba(1, 1, 1, 0.08)
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "✓"
                        font.pixelSize: 14
                        font.bold: true
                        visible: root.currentTintFlag
                        color: "#000000"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.currentTintFlag = !root.currentTintFlag;
                            root.saveSettings("tintFlag", root.currentTintFlag);
                        }
                    }
                }

                Text {
                    text: "Tint flag with theme color (monochrome look)"
                    font.pixelSize: 13
                    color: "#FFFFFF"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(1, 1, 1, 0.1)
        }

        // OSD duration
        Column {
            width: parent.width
            spacing: 8

            Text {
                text: "OSD Duration"
                font.pixelSize: 15
                font.bold: true
                color: Theme.primary
            }

            Row {
                spacing: 12
                width: parent.width

                DankTextField {
                    id: intervalInput
                    width: 140
                    height: 38
                    text: root.currentInterval.toString()
                    placeholderText: "1200"
                    backgroundColor: Qt.rgba(1, 1, 1, 0.08)
                    textColor: "#FFFFFF"
                }

                Rectangle {
                    width: 80
                    height: 38
                    radius: 8
                    color: Theme.primary

                    Text {
                        anchors.centerIn: parent
                        text: "Apply"
                        font.bold: true
                        font.pixelSize: 13
                        color: "#000000"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var val = Number(intervalInput.text.trim());
                            if (!Number.isInteger(val)) return;
                            if (!isNaN(val) && val >= 300) {
                                root.currentInterval = val;
                                root.saveSettings("autoHideInterval", val);
                            }
                        }
                    }
                }

                Rectangle {
                    width: 80
                    height: 38
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.08)

                    Text {
                        anchors.centerIn: parent
                        text: "Default"
                        font.pixelSize: 13
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            intervalInput.text = "1200";
                            root.currentInterval = 1200;
                            root.saveSettings("autoHideInterval", 1200);
                        }
                    }
                }
            }
        }

        Rectangle {
            width: parent.width
            height: 1
            color: Qt.rgba(1, 1, 1, 0.1)
        }

        // Custom layout labels
        Column {
            width: parent.width
            spacing: 12

            Row {
                width: parent.width

                Text {
                    text: "Layout Alias Editor"
                    font.pixelSize: 15
                    font.bold: true
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Item {
                    width: Math.max(0, parent.width - 90 - 10 - 150)
                    height: 1
                }

                Rectangle {
                    width: 90
                    height: 30
                    radius: 6
                    color: Qt.rgba(1, 0.3, 0.3, 0.18)
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "Reset All"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#FF8080"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.customMapObj = {};
                            root.saveSettings("customMap", "{}");
                        }
                    }
                }
            }

            DankTextField {
                id: searchInput
                width: parent.width
                height: 38
                placeholderText: "Search layouts (e.g. Spanish, English, Russian)..."
                backgroundColor: Qt.rgba(1, 1, 1, 0.08)
                textColor: "#FFFFFF"
                onTextEdited: {
                    root.searchFilter = text.trim().toLowerCase();
                }
            }

            Column {
                width: parent.width
                spacing: 6

                Repeater {
                    model: root.allSupportedLayouts.filter(function(name) {
                        return root.searchFilter === "" || name.toLowerCase().indexOf(root.searchFilter) !== -1;
                    }).slice(0, 8)

                    Rectangle {
                        width: settingsColumn.width
                        height: 44
                        radius: 8
                        color: Qt.rgba(1, 1, 1, 0.05)

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Text {
                                text: modelData
                                font.pixelSize: 13
                                color: "#FFFFFF"
                                width: 140
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            DankTextField {
                                id: rowInput
                                width: 150
                                height: 32
                                anchors.verticalCenter: parent.verticalCenter
                                placeholderText: "Custom label..."
                                text: root.customMapObj[modelData] || ""
                                backgroundColor: Qt.rgba(1, 1, 1, 0.08)
                                textColor: "#FFFFFF"
                            }

                            Rectangle {
                                width: 64
                                height: 30
                                radius: 6
                                color: Theme.primary
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: "Set"
                                    font.bold: true
                                    font.pixelSize: 12
                                    color: "#000000"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        var map = Object.assign({}, root.customMapObj);
                                        if (rowInput.text.trim() === "") {
                                            delete map[modelData];
                                        } else {
                                            map[modelData] = rowInput.text.trim();
                                        }
                                        root.customMapObj = map;
                                        root.saveSettings("customMap", JSON.stringify(map));
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
