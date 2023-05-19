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
                text: "Connect to other backend"
                icon.name: "network-connect"
                shortcut: StandardKey.New
                onTriggered: {
                    connectOverlay.open();
                }
            },
            Kirigami.Action {
                text: "Simulate Disconnect"
                icon.name: "network-disconnect"
                shortcut: StandardKey.Close
                onTriggered: {
                    backendDisconnectWarning.visible = true;
                }
            }

        ]
    }

    Connections {
        target: tcpHandler
        function onIncomingData (packets) {
            console.log("hello", packets[0]);
            for (let i = 0; i < packets.length; i++)
            {
                let packet = packets[i];
                console.log("value", packet.value);
                /*let pnidElement = pnidLamarr.findChild(function (child) {
                    return child.id === packet.id;
                });
                pnidElement.value = packet.value;*/
                testSolenoid.value = packet.value;
            }
        }
        function onConnected() {
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
            text: "Popup"
            onClicked: {
                testPopupWindow.active = true
            }
        }

        Loader {
            id: testPopupWindow
            active: false
            sourceComponent: Kirigami.ApplicationWindow {
                title: "Test Popup"
                width: 300
                height: 200
                visible: true
                onClosing: {
                    testPopupWindow.active = false
                }
                flags: Qt.WindowStaysOnTopHint
            }
        }

        Controls.Button {
            text: "send data"
            onClicked: {
                console.log("clicked");
                websocket.sendData("someId", 3.7);
            }
        }

        ValveSolenoid {

        }

        StackLayout {
            id: pnidTabsContainer
            objectName: "pnidTabsContainer"
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: pnidTabs.currentIndex

            Component.onCompleted: {
                console.log("loading pnids stacklayout");
                pnidHandler.loadPnids(pnidTabsContainer);
            }

            Repeater {
                model: pnidHandler.pnids
                Loader {
                    objectName: modelData.name
                    source: modelData.filePath
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: connectOverlay


        header: Kirigami.Heading {
            text: "Connect to Backend"
        }

        BackendConnection {
            Layout.preferredWidth: Kirigami.Units.gridUnit * 25
            onBackendConnect: {
                console.log("connecting to", backendIp);
                connectOverlay.close();
            }
        }
    }
}
