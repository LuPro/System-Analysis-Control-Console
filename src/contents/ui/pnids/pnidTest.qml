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
            text: "blank"
            onClicked: {

            }
        }
    }

    ValveSolenoid {
        id: testSolenoid1
        objectName: "testSolenoid1"
        displayName: "Solenoid 1"
        x: 20
        y: 30
    }

    ValveSolenoid {
        id: testGreenLight
        //objectName: "4:01_Distribution/4:Indicators/4:Lights/4:Yellow"
        objectName: "4:01_Distribution/4:Indicators/4:StationState/4:Manual"
        displayName: "Yellow Light"
        checkSensTolerance: false
        x: 100
        y: 30
    }

    ValveSolenoid {
        id: testLight
        objectName: "4:01_Distribution/4:MES/4:Product"
        displayName: "Product Selection"
        checkSensTolerance: false
        x: 180
        y: 30
    }

    ValveSolenoid {
        id: testMockServer
        objectName: "2:MyObject/2:MyVariable"
        displayName: "Mock Server MyVar"
        checkSensTolerance: false
        x: 260
        y: 30
        rotation: 1
    }

    Shape {
        ShapePath {
            property var connectedElements: ["testSolenoid1", "testSolenoid2"] //list of connected pnid elements
            strokeWidth: 2
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine

            startX: 68; startY: 66
            PathLine {
                x: 100
                y: 66
            }
        }
    }
}
