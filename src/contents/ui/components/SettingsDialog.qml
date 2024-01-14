import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import QtQuick.Dialogs 1.3 as Dialogs
import Qt.labs.platform 1.1 as Platform

import at.tust.sysanalysis 0.1

Kirigami.ApplicationWindow {
    id: dialog

    title: i18nc("@title:window", "Settings")

    //TODO: These are just a crutch because it doesn't properly adapt to the content
    maximumWidth: 800
    maximumHeight: 600

    visible: false
    modality: Qt.ApplicationModal

    //minimumWidth: Kirigami.Units.gridUnit * 36
    //minimumHeight: Kirigami.Units.gridUnit * 32

    property bool _isDirty: false

    // Close when pressing Esc key
    Shortcut {
        sequence: StandardKey.Cancel
        onActivated: close()
    }

    Component.onCompleted: {
        loadSettings();
    }

    function loadSettings() {
        pnidPathInput.text = Config.readPnidPath;
        clientNameInput.text = Config.clientName;
        _isDirty = false;
    }

    function save() {
        Config.readPnidPath = pnidPathInput.text;
        Config.clientName = clientNameInput.text;

        Config.save();
    }

    Kirigami.ScrollablePage {
        anchors.fill: parent

        Kirigami.FormLayout {
            Layout.fillWidth: true

            Kirigami.Separator {
                Kirigami.FormData.isSection: true
                Kirigami.FormData.label: "General"
            }

            Controls.TextField {
                id: clientNameInput
                Kirigami.FormData.label: "Client Name:"
                placeholderText: "Name of your Client"

                onTextChanged: {
                    _isDirty = true;
                }
            }

            RowLayout {
                Kirigami.FormData.label: "PnID Location:"
                Controls.TextField {
                    id: pnidPathInput
                    placeholderText: {
                        if (Qt.platform.os === "windows") {
                            return Platform.StandardPaths.writableLocation(Platform.StandardPaths.AppDataLocation).toString().replace("file:///", "");
                        }
                        return Platform.StandardPaths.writableLocation(Platform.StandardPaths.AppDataLocation).toString().replace("file://", "");
                    }

                    onTextChanged: {
                        _isDirty = true;
                    }
                }

                Controls.Button {
                    icon.name: "document-open-folder"
                    onClicked: {
                        pnidPathDialog.visible = true
                    }

                    Dialogs.FileDialog {
                        id: pnidPathDialog

                        title: i18nc("@title:window", "Choose a Folder")
                        folder: {
                            if (Config.readPnidPath === "" || Config.readPnidPath === undefined) {
                                return shortcuts.home
                            }

                            if (Qt.platform.os === "windows") {
                                return "file:///" + Config.readPnidPath
                            }
                            return "file://" + Config.readPnidPath
                        }

                        selectFolder: true

                        onAccepted: {
                            const url = folder
                            if (Qt.platform.os === "windows") {
                                pnidPathInput.text = url.toString().replace("file:///", "");
                            } else {
                                pnidPathInput.text = url.toString().replace("file://", "");
                            }
                            _isDirty = true;
                        }
                    }
                }
            }
        }

        footer: Controls.DialogButtonBox {
            Controls.Button {
                text: i18nc("@action:button", "OK")
                icon.name: 'dialog-ok-apply'
                Controls.DialogButtonBox.buttonRole: Controls.DialogButtonBox.AcceptRole
                Accessible.onPressAction: onClicked
            }
            onAccepted: {
                save();
                _isDirty = false;
                close();
            }

            Controls.Button {
                text: i18nc("@action:button", "Apply")
                icon.name: 'dialog-ok-apply'
                Controls.DialogButtonBox.buttonRole: Controls.DialogButtonBox.ApplyRole
                Accessible.onPressAction: onClicked

                enabled: _isDirty
            }
            onApplied: {
                save();
                _isDirty = false;
            }

            Controls.Button {
                text: i18nc("@action:button", "Cancel")
                icon.name: 'dialog-cancel'
                Controls.DialogButtonBox.buttonRole: Controls.DialogButtonBox.RejectRole
                Accessible.onPressAction: onClicked
            }
            onRejected: {
                close()
            }
        }
    }

    Dialogs.MessageDialog {
        id: dirtyClosingDialog

        standardButtons: Dialogs.MessageDialog.Save | Dialogs.MessageDialog.Discard | Dialogs.MessageDialog.Cancel

        title: i18nc("@title:window", "Warning")

        text: i18nc("@info", 'You have unsaved changes. Do you want to apply the changes or discard them?')

        onButtonClicked: {
            switch(clickedButton) {
                case Dialogs.MessageDialog.Discard: {
                    loadSettings();
                    _isDirty = false;
                    dialog.close();
                    break;
                }
                case Dialogs.MessageDialog.Save: {
                    save();
                    _isDirty = false;
                    dialog.close();
                    break;
                }
            }
        }
    }

    onClosing: close => {
        if (_isDirty) {
            close.accepted = false
            dirtyClosingDialog.open()
        }
    }
}
