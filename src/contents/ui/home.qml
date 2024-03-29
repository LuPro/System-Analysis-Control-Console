import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import "components"

import at.tust.sysanalysis 0.1

Kirigami.Page {
    title: i18nc("@title", "Home")
    id: pageHome

    Kirigami.FormLayout {
        anchors.centerIn: parent
        Kirigami.Heading {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Welcome to System Analysis & Control Console"
            level: 1
        }
        Controls.Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Interactive System Visualization"
        }

        Kirigami.Separator {}

        BackendConnection {
            onServerStart: (port, forwardPort) => {
                tcpHandler.start(port);
                pageStack.replace(Qt.resolvedUrl("pnidview.qml"));
            }
            onServerConnect: (address, port) => {
                tcpHandler.connect(address, port);
                pageStack.replace(Qt.resolvedUrl("pnidview.qml"));
            }
        }
    }
}
