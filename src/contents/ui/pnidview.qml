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
                //TODO: Some sort of tooltip or info about what the warning is about would be great
                visible: tcpHandler.exclusiveControl
                displayComponent: Kirigami.Icon {
                    source: tcpHandler.isPrimary ? "documentinfo" : "data-warning"
                }
            },

            Kirigami.Action {
                id: zoomOutAction
                visible: !Kirigami.Settings.isMobile
                icon.name: "file-zoom-out"
                shortcut: StandardKey.ZoomOut
                onTriggered: {
                    zoomStep("out");
                }
            },
            Kirigami.Action {
                id: zoomSelectAction
                visible: !Kirigami.Settings.isMobile
                displayComponent: Controls.ComboBox {
                    id: zoomSelector
                    Component.onCompleted: {
                        zoomSelector.currentIndex = _defaultZoomStep;
                        currentIndex = Qt.binding(function() { return pnidHandler.currentZoom });
                    }
                    onActivated: {
                        zoomSet(zoomSelector.currentIndex);
                    }

                    textRole: "text"
                    valueRole: "value"

                    model: _zoomSelectorModel
                }
            },
            Kirigami.Action {
                id: zoomInAction
                visible: !Kirigami.Settings.isMobile
                icon.name: "file-zoom-in"
                shortcut: StandardKey.ZoomIn
                onTriggered: {
                    zoomStep("in");
                }
            }/*,

            Kirigami.Action {
                text: "Connect to other backend"
                icon.name: "network-connect"
                shortcut: StandardKey.New
                onTriggered: {
                    connectOverlay.open();
                }
            }*/

        ]
    }

    property double _defaultScaleFactor: 0.125
    property int _defaultZoomStep: 5
    property var _zoomSelector: undefined
    property var _zoomSelectorModel: [
        {text: "25%", value: 0.25},
        {text: "33%", value: 0.33},
        {text: "50%", value: 0.50},
        {text: "66%", value: 0.66},
        {text: "75%", value: 0.75},
        {text: "100%", value: 1.0},
        {text: "125%", value: 1.25},
        {text: "150%", value: 1.50},
        {text: "200%", value: 2.0},
        {text: "300%", value: 3.0},
        {text: "400%", value: 4.0}
    ]

    function zoomSet(newZoom) {
        pnidHandler.setCurrentZoom(newZoom);
    }

    function zoomStep(type) {
        if (type === "in") {
            pnidHandler.setCurrentZoom(Math.min(pnidHandler.currentZoom + 1, _zoomSelectorModel.length - 1));
        } else if (type === "out") {
            pnidHandler.setCurrentZoom(Math.max(pnidHandler.currentZoom - 1, 0));
        }
    }

    Connections {
        target: tcpHandler
        function onBackendSocketsChanged() {
            console.log("backend sockets changed");
            console.log(tcpHandler.backendSockets.length);
        }
        function onFrontendSocketsChanged() {
            console.log("frontend sockets changed");
            console.log(tcpHandler.frontendSockets.length);
        }

        function onConnectedBackend() {
            allBackendDisconnectWarning.visible = false;
            backendDisconnectWarning.visible = false;
        }
        function onBackendDisconnected(remainingConnectionCount) {
            if (remainingConnectionCount === 0) {
                allBackendDisconnectWarning.visible = true;
            } else {
                backendDisconnectWarning.visible = true;
            }
        }

        function onExclusiveControlChanged() {
            if (!tcpHandler.isPrimary) {
                exclusiveControlWarning.visible = tcpHandler.exclusiveControl;
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

        function onCurrentZoomChanged() {
            let currentZoom = pnidHandler.getCurrentZoom();
            if (currentZoom === -1) {
                currentZoom = _defaultZoomStep;
            }

            let activePnid = pnidTabsContainer.itemAt(pnidTabs.currentIndex).item;
            activePnid.zoomScale = _zoomSelectorModel[currentZoom].value * _defaultScaleFactor;
        }
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

        Kirigami.InlineMessage {
            id: exclusiveControlWarning
            Layout.fillWidth: true
            visible: false
            type: Kirigami.MessageType.Warning
            showCloseButton: true

            text: qsTr("Primary client has switched to exclusive control. Until this is switched off you cannot send commands to hardware.")
        }

        Controls.TabBar {
            id: pnidTabs
            Layout.fillWidth: true

            Repeater {
                model: pnidHandler.pnids
                Controls.TabButton {
                    text: modelData.name
                    onClicked: {
                        pnidHandler.setActivePnid(pnidTabs.currentIndex);
                    }
                }
            }
        }

        Controls.Button {
            text: "blank"
            onClicked: {
            }
        }

        /*ValveSolenoid {
            transform: Scale {origin.x: 0; origin.y: 0; xScale: 0.15; yScale: 0.15}
            displayName: "Solenoid New"
        }*/

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

                Loader {
                    id: pnidLoader
                    objectName: modelData.name
                    source: modelData.filePath
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        id: backendsListOverlay

        header: Kirigami.Heading {
            id: backendsListHeading
            text: "List of connected Backends"
        }

        contentItem: ColumnLayout {
            property double contentWidth: 500
            property double contentHeight: 500

            Repeater {
                model: tcpHandler.backendSockets

                RowLayout {
                    spacing: Kirigami.Units.largeSpacing
                    Controls.Label {
                        text: modelData.name
                    }
                    Item {
                        width: Kirigami.Units.gridUnit * 4;
                    }

                    Controls.Label {
                        text: "Last sent data: 1s ago"
                    }
                }

            }
        }
    }

    Kirigami.OverlaySheet {
        id: frontendsListOverlay


        header: Kirigami.Heading {
            text: "List of connected Frontends"
        }

        contentItem: Kirigami.FormLayout {
            id: frontendsListLayout
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height + exclusiveControlSwitch.height + frontendsListSeparator.height

            Controls.Switch {
                id: exclusiveControlSwitch
                text: "Disable UI interactions for connected frontends"
                position: tcpHandler.exclusiveControl
                onPositionChanged: {
                    tcpHandler.setExclusiveControl(position);
                }
            }

            Kirigami.Separator {
                id: frontendsListSeparator
                Layout.fillWidth: true
            }

            Kirigami.CardsListView {
                id: cardsList
                model: tcpHandler.frontendSockets
                implicitWidth: contentItem.childrenRect.width
                implicitHeight: contentItem.childrenRect.height

                delegate: Kirigami.AbstractCard {

                    footer: Controls.Label {
                        text: modelData.name !== "name_unknown" ? modelData.name : "Frontend #" + index
                    }
                }
            }
        }
    }

    Kirigami.OverlaySheet {
        //TODO: Currently unused. what to do about that?
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
