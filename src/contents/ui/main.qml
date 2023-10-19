// Includes relevant modules used by the QML
import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

import com.tust.sysanalysis 0.1

import "components"

// Provides basic features needed for all kirigami applications
Kirigami.ApplicationWindow {
    // Unique identifier to reference this object
    id: root

    // Window title
    // i18nc() makes a string translatable
    // and provides additional context for the translators
    title: i18nc("@title:window", "System Analysis & Control Console")

    contextDrawer: Kirigami.ContextDrawer {}

    globalDrawer: Kirigami.GlobalDrawer {
        isMenu: true
        actions: [
            Kirigami.Action {
                text: "Settings"
                icon.name: "settings-configure"
                shortcut: StandardKey.Preferences
                onTriggered: settingsDialogLoader.showDialog();
            },
            Kirigami.Action {
                text: "About"
                icon.name: "help-about"
                onTriggered: pageStack.layers.push(aboutPage)
            }

        ]
    }

    Component {
        id: aboutPage

        Kirigami.AboutPage {
            aboutData: About
        }
    }

    Item {
        id: settingsDialogLoader

        function showDialog() {
            settingsDialog.visible = true;
        }

        SettingsDialog {
            id: settingsDialog
        }
    }

    // Set the first page that will be loaded when the app opens
    // This can also be set to an id of a Kirigami.Page
    pageStack.initialPage: Qt.resolvedUrl("home.qml")
    /*pageStack.initialPage: Kirigami.Page {
        Controls.Label {
            // Center label horizontally and vertically within parent object
            anchors.centerIn: parent
            text: i18n("Home")
        }
    }*/

}
