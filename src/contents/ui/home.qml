import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import "components"

Kirigami.Page {
    title: i18nc("@title", "Home")
    id: pageHome

    Kirigami.FormLayout {
        anchors.centerIn: parent
        Kirigami.Heading {
            text: "Welcome to PnID Viewer"
            level: 1
        }
        Controls.Label {
            text: "Interactive System Visualization"
        }

        BackendConnection {
            onBackendConnect: (port) => {
                tcpHandler.start(port);
                pageStack.replace(Qt.resolvedUrl("pnidview.qml"));
            }
        }
    }
}
