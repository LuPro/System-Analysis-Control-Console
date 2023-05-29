import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../pnid_elements"

Item {
    id: pnidTest
    objectName: "pnidTest"
    //visible: false

    Component.onCompleted: {
        pnidHandler.registerPnid(pnidTest)
    }

    RowLayout {
        Controls.Button {
            text: "set state 0"
            onClicked: {
                testSolenoid1.setState = 0
            }
        }
        Controls.Button {
            text: "set state 1"
            onClicked: {
                testSolenoid1.setState = 1
            }
        }
        /*Controls.Button {
            text: "1 == 1"
            onClicked: {
                testSolenoid1.guiState = true
                testSolenoid1.value = 1
            }
        }*/
    }


    ValveSolenoid {
        id: testSolenoid1
        objectName: "testSolenoid1"
        displayName: "Solenoid 1"
        x: 20
        y: 30
    }

    ValveSolenoid {
        id: testSolenoid2
        objectName: "testSolenoid2"
        displayName: "Solenoid 2"
        x: 100
        y: 30
    }
}
