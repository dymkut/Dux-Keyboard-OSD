import QtQuick
import QtQuick.Effects
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

// DMS Keyboard OSD
// Author: Dymkut
// License: AGPL-3.0-only

PluginComponent {
    id: root

    readonly property string pluginId: "dms-kosd"

    // Keyboard layout names and their country codes
    readonly property var layoutDatabase: ({
        "Arabic":                "SA",
        "Armenian":              "AM",
        "Basque":                "ES",
        "Belarusian":            "BY",
        "Bosnian":               "BA",
        "Bulgarian":             "BG",
        "Catalan":               "ES",
        "Chinese":               "CN",
        "Croatian":              "HR",
        "Czech":                 "CZ",
        "Danish":                "DK",
        "Dutch":                 "NL",
        "English":               "US",
        "English (UK)":          "GB",
        "English (US)":          "US",
        "Estonian":              "EE",
        "Finnish":               "FI",
        "French":                "FR",
        "Galician":              "ES",
        "Georgian":              "GE",
        "German":                "DE",
        "German (Austria)":      "AT",
        "German (Germany)":      "DE",
        "German (Switzerland)":  "CH",
        "Greek":                 "GR",
        "Hebrew":                "IL",
        "Hindi":                 "IN",
        "Hungarian":             "HU",
        "Icelandic":             "IS",
        "Indonesian":            "ID",
        "Italian":               "IT",
        "Japanese":              "JP",
        "Kazakh":                "KZ",
        "Korean":                "KR",
        "Latvian":               "LV",
        "Lithuanian":            "LT",
        "Macedonian":            "MK",
        "Norwegian":             "NO",
        "Polish":                "PL",
        "Portuguese":            "PT",
        "Portuguese (Brazil)":  "BR",
        "Romanian":              "RO",
        "Russian":               "RU",
        "Serbian":               "RS",
        "Slovak":                "SK",
        "Slovenian":             "SI",
        "Spanish":               "ES",
        "Swedish":               "SE",
        "Swiss French":          "CH",
        "Swiss German":          "CH",
        "Thai":                  "TH",
        "Turkish":               "TR",
        "Ukrainian":             "UA",
        "Vietnamese":            "VN"
    })

    // Country names that should not be displayed as variants
    readonly property var countryExclusions: [
        "us", "usa", "uk", "gb", "es", "spain", "ru", "russia", "de", "germany",
        "ch", "switzerland", "fr", "france", "it", "italy", "pt", "portugal",
        "br", "brazil", "latin america", "latam", "intl", "international"
    ]

    // Longer names must be checked first (e.g. English (UK) before English).
    readonly property var sortedLayoutNames: Object.keys(layoutDatabase).sort(function(a, b) {
        return b.length - a.length;
    })

    function loadSetting(key, fallback) {
        if (pluginData && pluginData[key] !== undefined) return pluginData[key];
        if (typeof PluginService !== "undefined" && PluginService.loadPluginData) {
            return PluginService.loadPluginData(root.pluginId, key, fallback);
        }
        return fallback;
    }

    // Unicode regional indicators are used to build flag emojis.
    function isoToFlag(isoCode) {
        if (typeof isoCode !== "string" || !/^[a-zA-Z]{2}$/.test(isoCode)) return "🌐";
        var upper = isoCode.toUpperCase();
        var charA = 0x1F1E6 + (upper.charCodeAt(0) - 65);
        var charB = 0x1F1E6 + (upper.charCodeAt(1) - 65);
        return String.fromCodePoint(charA, charB);
    }

    // Extract the variant while ignoring country names
    function extractVariant(rawName) {
        if (!rawName) return "";
        var match = rawName.match(/\(([^)]+)\)/);
        if (!match) return "";

        var parts = match[1].split(",");
        var cleanParts = [];

        for (var i = 0; i < parts.length; i++) {
            var item = parts[i].trim();
            if (countryExclusions.indexOf(item.toLowerCase()) === -1) {
                cleanParts.push(item);
            }
        }

        if (cleanParts.length === 0) return "";
        var result = cleanParts.join(" ").replace(/_/g, " ");
        return result.charAt(0).toUpperCase() + result.slice(1);
    }

    // Resolve the layout name, flag and variant
    function getLayoutData(rawName) {
        if (!rawName) return { iso: "KB", flag: "", variant: "" };

        var mode = root.loadSetting("displayMode", "flag_iso");
        var variant = root.extractVariant(rawName);

        if (mode === "custom" || mode === "Custom") {
            var rawCustom = root.loadSetting("customMap", "{}");
            try {
                var map = typeof rawCustom === "string" ? JSON.parse(rawCustom) : rawCustom;
                if (map && map[rawName]) {
                    return { iso: map[rawName], flag: "", variant: variant };
                }
            } catch (e) {
                console.warn("DMS Keyboard OSD: Invalid custom layout data:", e);
            }
        }

        var isoCode = "";
        for (var i = 0; i < sortedLayoutNames.length; i++) {
            if (rawName.indexOf(sortedLayoutNames[i]) !== -1) {
                isoCode = layoutDatabase[sortedLayoutNames[i]];
                break;
            }
        }

        if (!isoCode) {
            isoCode = rawName.replace(/[^a-zA-Z]/g, "").substring(0, 2).toUpperCase() || "KB";
        }

        var flag = root.isoToFlag(isoCode);
        if (mode === "iso" || mode === "ISO Only") flag = "";

        return { iso: isoCode, flag: flag, variant: variant };
    }

    Variants {
        model: SettingsData.getFilteredScreens("osd")

        delegate: DankOSD {
            id: osdInstance
            screen: modelData

            osdWidth: 165
            osdHeight: 52
            autoHideInterval: root.loadSetting("autoHideInterval", 1200)
            enableMouseInteraction: false

            Connections {
                target: (typeof NiriService !== "undefined") ? NiriService : null
                ignoreUnknownSignals: true
                function onCurrentKeyboardLayoutIndexChanged() { osdInstance.show(); }
            }

            Connections {
                target: (typeof HyprlandService !== "undefined") ? HyprlandService : null
                ignoreUnknownSignals: true
                function onKeyboardLayoutChanged() { osdInstance.show(); }
            }

            content: Component {
                Item {
                    anchors.fill: parent

                    readonly property string activeLayoutName: {
                        if (typeof NiriService !== "undefined" && NiriService.keyboardLayoutNames) {
                            var idx = NiriService.currentKeyboardLayoutIndex;
                            var names = NiriService.keyboardLayoutNames;
                            if (names && names.length > idx && idx >= 0) return names[idx];
                        } else if (typeof HyprlandService !== "undefined") {
                            return HyprlandService.currentKeyboardLayout || "";
                        }
                        return "";
                    }

                    readonly property var currentInfo: root.getLayoutData(activeLayoutName)
                    readonly property bool isTinted: Boolean(root.loadSetting("tintFlag", false))

                    // OSD content
                    Column {
                        anchors.centerIn: parent
                        spacing: 3

                        // Keyboard icon, flag and country code
                        Row {
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 8

                            DankIcon {
                                anchors.verticalCenter: parent.verticalCenter
                                name: "keyboard"
                                size: 22
                                color: Theme.primary
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: currentInfo.flag.length > 0 && root.loadSetting("displayMode", "flag_iso") !== "iso_flag"
                                text: currentInfo.flag
                                font.pixelSize: 18

                                layer.enabled: isTinted
                                layer.effect: MultiEffect {
                                    colorization: 1.0
                                    colorizationColor: Theme.primary
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: currentInfo.iso
                                font.pixelSize: 18
                                font.bold: true
                                color: Theme.primary
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: currentInfo.flag.length > 0 && root.loadSetting("displayMode", "flag_iso") === "iso_flag"
                                text: currentInfo.flag
                                font.pixelSize: 18

                                layer.enabled: isTinted
                                layer.effect: MultiEffect {
                                    colorization: 1.0
                                    colorizationColor: Theme.primary
                                }
                            }
                        }

                        // Keyboard variant
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: currentInfo.variant.length > 0
                            width: variantText.implicitWidth + 12
                            height: variantText.implicitHeight + 2
                            radius: 4
                            color: Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                id: variantText
                                anchors.centerIn: parent
                                text: currentInfo.variant
                                font.pixelSize: 10
                                font.bold: true
                                color: Qt.rgba(1, 1, 1, 0.8)
                            }
                        }
                    }
                }
            }
        }
    }
}
