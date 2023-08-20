import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../pnid_elements"
import "../components"

Controls.ScrollView {
    id: pnid
    objectName: "pnidTest"
    //visible: false

    Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AsNeeded
    Controls.ScrollBar.vertical.policy: Controls.ScrollBar.AsNeeded
    contentHeight: pnidItem.height * pnid.zoomScale
    contentWidth: pnidItem.width * pnid.zoomScale

    property double zoomScale: 0.125
    //property double zoomScale: 1

    Component.onCompleted: {
        pnidHandler.registerPnid(pnid);
    }

    Item {
        id: pnidItem
        //anchors.fill: pnid
        //anchors.margins: 1/pnid.zoomScale
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
        transform: Scale {origin.x: 0; origin.y: 0; xScale: pnid.zoomScale; yScale: pnid.zoomScale}
        RowLayout {
            Controls.Button {
                transform: [Scale {
                    origin.x: 0; origin.y: 0; xScale: 1/pnid.zoomScale; yScale: 1/pnid.zoomScale
                }, Translate { y: 1000 }]
                text: "size"
                onClicked: {
                    console.log("size", childrenRect.width/pnid.zoomScale, childrenRect.height/pnid.zoomScale)
                }
            }
        }
        ValveSolenoid {
            id: testSolenoid1
            objectName: "testSolenoid1"
            displayName: "Solenoid 1"
            x: 0
            y: 0
        }

        ValveSolenoid {
            id: testGreenLight
            objectName: "4:01_Distribution/4:Indicators/4:StationState/4:Manual"
            displayName: "Yellow Light"
            checkSensTolerance: false
            x: 500
            y: 0
        }

        ValveSolenoid {
            id: testLight
            objectName: "4:01_Distribution/4:MES/4:Product"
            displayName: "Product Selection"
            checkSensTolerance: false
            x: 1000
            y: 0
        }

        ValveSolenoid {
            id: testMockServer
            objectName: "2:MyObject/2:MyVariable1"
            displayName: "Mock Server MyVar"
            checkSensTolerance: false
            x: 1500
            y: 0
            rotation: 1
        }

        Tank {
            id: testTank
            objectName: "2:MyObject/2:MyVariable2"
            displayName: "Tank"
            x: 2000
            y: 0
            label: "Fuel"
            valuePosition: "right"
            unit: "l"
        }

        Container {
            id: testContainer
            objectName: "2:MyObject/2:MyVariable3"
            displayName: "Container"
            x: 3000
            y: 0
            label: "Discs"
            labelPosition: "top"
            unit: "#"
        }

        Led {
            id: testLed
            objectName: "2:MyObject/2:MyVariable6"
            displayName: "Manual"
            x: 3175
            y: 1300
            rotation: 2
            label: displayName
            onColor: Kirigami.Theme.positiveTextColor
        }

        GasBottle {
            id: testBottle
            objectName: "testBottle"
            displayName: "Compressed Air Tank"
            x: 0
            y: 2000
            label: "Air"
        }

        MagazineEjector {
            id: testMagazine
            objectName: "2:MyObject/2:MyVariable4"
            displayName: "Ejector"
            x: 2300
            y: 1000
            maxValue: 100
            subObjectIds: ["2:MyObject/2:MyVariable5"]
        }

        LightBarrier {
            id: testBarrier
            objectName: "2:MyObject/2:MyVariable7"
            displayName: "LightBarrier"
            x: 600
            y: 2000
            valuePosition: "top"
        }

        /*Shape {
            PnidSvgLabel {
                text: "Hello"
                strokeWidthOverride: 2
                x: 2500
                y: 1500
            }
        }*/

        Shape {
            ShapePath {
                property var connectedElements: ["testSolenoid1", "testSolenoid2"] //list of connected pnid elements
                strokeWidth: 2/pnid.zoomScale
                strokeColor: Kirigami.Theme.textColor
                strokeStyle: ShapePath.SolidLine

                startX: 400; startY: 350
                PathLine {
                    x: 500
                    y: 350
                }
            }
        }
    }
}
