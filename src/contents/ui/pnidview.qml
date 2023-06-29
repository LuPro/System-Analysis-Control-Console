import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Window 2.2
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "components"
import "pnid_elements"
import "pnids"

Kirigami.Page {
    title: i18nc("@title", "PnID")
    id: pagePnid

    actions {
        contextualActions: [
            Kirigami.Action {
                visible: !tcpHandler.isClientMode() && tcpHandler.backendSockets.length > 0
                text: "Connected Backends"
                onTriggered: {
                    backendsListOverlay.open();
                }
            },
            Kirigami.Action {
                visible: !tcpHandler.isClientMode() && tcpHandler.frontendSockets.length > 0
                text: "Connected Frontends"
                onTriggered: {
                    frontendsListOverlay.open();
                }
            },

            Kirigami.Action {
                text: "Connect to other backend"
                icon.name: "network-connect"
                shortcut: StandardKey.New
                onTriggered: {
                    connectOverlay.open();
                }
            }

        ]
    }

    Connections {
        target: tcpHandler
        function onBackendSocketsChanged() {
            console.log("backend sockets changed");
        }
        function onFrontendSocketsChanged() {
            console.log("frontend sockets changed");
            console.log(tcpHandler.frontendSockets, tcpHandler.frontendSockets.modelData);
        }

        function onConnectedBackend() {
            allBackendDisconnectWarning.visible = false;
            backendDisconnectWarning.visible = false;
        }
        function onDisconnected(remainingConnectionCount) {
            if (remainingConnectionCount === 0) {
                allBackendDisconnectWarning.visible = true;
            } else {
                backendDisconnectWarning.visible = true;
            }
        }
        Component.onCompleted: {
            if (tcpHandler.isClientMode()) {
                allBackendDisconnectWarning.visible = false;
                backendDisconnectWarning.visible = false;
                clientModeInfo.visible = true;
            }
        }
    }

    Connections {
        target: pnidHandler
    }

    ColumnLayout {
        spacing: Kirigami.Units.largeSpacing
        width: parent.width
        height: parent.height

        Kirigami.InlineMessage {
            id: backendDisconnectWarning
            Layout.fillWidth: true
            visible: false
            type: Kirigami.MessageType.Information
            showCloseButton: true

            text: qsTr("Connection to one backend has been lost.")
        }

        Kirigami.InlineMessage {
            id: allBackendDisconnectWarning
            Layout.fillWidth: true
            visible: true
            type: Kirigami.MessageType.Warning
            showCloseButton: true

            text: qsTr("No connection to any backend.")
        }

        Kirigami.InlineMessage {
            id: clientModeInfo
            Layout.fillWidth: true
            visible: false
            type: Kirigami.MessageType.Information
            showCloseButton: true

            text: qsTr("Connected to a forward server, backend disconnects will not be detected.")
        }

        Controls.TabBar {
            id: pnidTabs
            Layout.fillWidth: true

            Repeater {
                model: pnidHandler.pnids
                Controls.TabButton {
                    text: modelData.name
                }
            }
        }

        Controls.Button {
            text: "blank"
            onClicked: {
            }
        }

        ValveSolenoid {
            displayName: "Solenoid New"
        }

        StackLayout {
            id: pnidTabsContainer
            objectName: "pnidTabsContainer"
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: pnidTabs.currentIndex

            Component.onCompleted: {
                pnidHandler.loadPnids(pnidTabsContainer);
            }

            Repeater {
                model: pnidHandler.pnids
                /*onModelChanged: {
                    pnidLoader.item.visible = true
                }*/

                Loader {
                    //id: pnidLoader
                    objectName: modelData.name
                    source: modelData.filePath
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: backendsListOverlay

        header: Kirigami.Heading {
            text: "List of connected Backends"
        }

        contentItem: RowLayout {

        }
    }

    Kirigami.OverlaySheet {
        id: frontendsListOverlay

        header: Kirigami.Heading {
            text: "List of connected Frontends"
        }

        contentItem: Item {
            implicitWidth: frontendsListLayout.implicitWidth
            implicitHeight: frontendsListLayout.implicitHeight

            Kirigami.FormLayout {
                id: frontendsListLayout
                Controls.Switch {
                    text: "Disable UI interactions for connected frontends"
                }
                Kirigami.CardsListView {
                    model: tcpHandler.frontendSockets
                    implicitWidth: frontendsList.implicitWidth
                    implicitHeight: frontendsList.implicitHeight

                    Kirigami.AbstractCard {
                        contentItem: Item {
                            implicitWidth: frontendsList.implicitWidth
                            implicitHeight: frontendsList.implicitHeight

                            ColumnLayout {
                                id: frontendsList
                                Controls.Label {
                                    text: "Hello"
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: connectOverlay

        header: Kirigami.Heading {
            text: "Connect to Backend"
        }

        contentItem: BackendConnection {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 25
            onServerStart: {
                console.log("starting server as", tcpServerPort);
                connectOverlay.close();
            }
            onServerConnect: {
                console.log("connecting to server at", tcpForwardServerAddress, tcpForwardServerPort);
                connectOverlay.close();
            }
        }
    }
}
