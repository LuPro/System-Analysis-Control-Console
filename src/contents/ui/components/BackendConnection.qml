import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

ColumnLayout {
    id: backendConnection
    property bool wideMode: true //TODO: remove explicitly setting wide mode as it adapts automatically
    signal serverStart(string tcpServerPort)
    signal serverConnect(string tcpForwardServerAddress, string tcpForwardServerPort)

    Controls.TabBar {
        Layout.alignment: Qt.AlignHCenter
        id: connectTabBar
        currentIndex: 1

        Controls.TabButton {
            text: "Client"
        }
        Controls.TabButton {
            text: "Server"
        }
    }

    StackLayout {
        id: connectTabs
        Layout.fillWidth: true
        currentIndex: connectTabBar.currentIndex

        Kirigami.FormLayout {
            anchors.fill: parent
            wideMode: backendConnection.wideMode

            Controls.Label {
                text: "Connect to already running Server"
            }
            Controls.TextField {
                id: connectForwardServerAddressField
                text: "localhost"
                Kirigami.FormData.label: "Server Address"
            }
            Controls.TextField {
                id: connectForwardServerPortField
                inputMask: "D0000"
                text: "3003"
                Kirigami.FormData.label: "Server Port"
            }
            Controls.Button {
                text: "Connect"
                onClicked: backendConnection.serverConnect(connectForwardServerAddressField.text, connectForwardServerPortField.text)
            }
        }

        Kirigami.FormLayout {
            anchors.fill: parent
            wideMode: backendConnection.wideMode

            Controls.Label {
                text: "Start servers for backend & frontends to connect"
            }
            Controls.TextField {
                id: serverPortField
                inputMask: "D0000"
                text: "3000"
                Kirigami.FormData.label: "Backend Port"
            }
            Controls.TextField {
                id: forwardServerPortField
                inputMask: "D0000"
                text: "3003"
                Kirigami.FormData.label: "Frontend Port"
            }
            Controls.Button {
                text: "Start"
                onClicked: backendConnection.serverStart(serverPortField.text, forwardServerPortField)
            }
        }
    }
}
