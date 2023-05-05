import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.FormLayout {
    id: backendConnection
    wideMode: false
    signal backendConnect(string tcpServerPort)

    Controls.TextField {
        id: backendIpField
        text: "3000"
        Kirigami.FormData.label: "Server Port"
    }
    Controls.Button {
        text: "Start"
        onClicked: backendConnection.backendConnect(backendIpField.text)
    }
}
