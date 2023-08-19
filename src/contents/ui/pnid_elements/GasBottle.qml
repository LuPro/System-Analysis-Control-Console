import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../popup_components"
import "../components"

Item {
    id: pnidElement
    width: rotation % 2 ? 1000 : 400
    height: rotation % 2 ? 400 : 1000
    /*layer.enabled: true //this should be antialiasing
    layer.samples: 4*/
    property string displayName
    property double guiState
    property double setState
    property double value
    property double maxValue: 100 //TODO: Some way of turning off fill level display would be good I think

    property int strokeWidth: 2
    property string valuePosition: "right"
    property string label: ""
    property string labelPosition: "center"
    property int rotation: 0 //rotation id: 0, 1, 2, 3 -> 90° steps

    property string unit
    property string content
    property var connections //list of connection points that other elements can connect to

    property bool checkSensTolerance: true

    property bool disablePopup: false
    //popup lists are for elements that aren't following the main value of the pnid element
    //eg: having a speed setting on a servo additionally to its position slider

    //list of available sub objects (human readable). only needed for eventual UI builder
    property var subObjectSlots: []
    property var subObjectIds: undefined //list of strings
    property var subObjectGuiStates //list of double
    property var subObjectSetStates //list of double
    property var subObjectValues //list of double

    property string _formattedValue //this is only for internal use
    property int _scaledStrokeWidth: strokeWidth / pnid.zoomScale

    Component.onCompleted: {
        if (subObjectIds !== undefined) {
            subObjectGuiStates = Array(subObjectIds.length).fill(undefined);
            subObjectSetStates = Array(subObjectIds.length).fill(undefined);
            subObjectValues = Array(subObjectIds.length).fill(undefined);

            for (let subObject of subObjectIds) {
                pnidHandler.registerSubObject(pnidElement.objectName, subObject);
            }
        }
    }

    function isInTolerance(measurement, reference) {
        //console.log("check is in tolerance", measurement, reference)
        if (!checkSensTolerance || measurement === reference) {
            //console.log("is in tolerance");
            return true;
        }
        //console.log("is not in tolerance");
        return false;
    }

    function applyStyling() {
        //console.log("applying styling", value, setState);
        _formattedValue = value + unit;
    }

    onDisplayNameChanged: {
        popup.title = displayName;
    }

    onGuiStateChanged: {
        console.log("gui state changed in pnid element");
    }

    onSetStateChanged: {
        applyStyling();
    }

    onValueChanged: {
        applyStyling();
    }

    Kirigami.ApplicationWindow {
        id: popup
        title: pnidElement.displayName
        width: 400
        height: 300
        flags: Qt.WindowStaysOnTopHint
        visible: false

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing

            ValueDisplay {
                id: valueDisplay
                value: pnidElement._formattedValue
            }
            Graph {
                id: graphDisplay
                label: "Cool Graph " + pnidElement.displayName
                value: pnidElement.value

                Layout.fillWidth: true
            }
        }
    }

    Shape {
        //TODO: according to docs it's better to have as few shapes as possible and rather have more shapepaths
        //can I make pnid elements to be just shape paths and have one shape per pnid?
        //vendorExtensionsEnabled: false
        width: parent.width
        height: parent.height
        asynchronous: true
        transform: [
            Rotation {
                origin.x: 0
                origin.y: 0
                angle: 90 * (rotation % 4)
            },
            Translate {
                x: (rotation % 4) == 1 || (rotation % 4) == 2 ? pnidElement.width : 0
                y: (rotation % 4) == 2 || (rotation % 4) == 3 ? pnidElement.height : 0
            }
        ]

        TapHandler {
            onTapped: {
                if (popup.visible == true)
                {
                    //somehow highlight the already open popup
                }
                else
                {
                    popup.visible = true && (!pnidElement.disablePopup);;
                }

            }
        }

        ShapePath {
            id: connector
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 250; startY: 139;
            PathLine {
                x: 250; y: 50;
            }
            PathSvg {
                path: "M 250 50 A 50 50 0 0 0 150 50 250"
            }
            PathLine {
                x: 150; y: 139;
            }
        }
        ShapePath {
            id: body
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 400; startY: 1000
            PathLine {
                x: 400; y: 250
            }
            PathSvg {
                path: "M 400 250 A 230 230 0 0 0 0 250"
            }
            PathLine {
                x: 0; y: 1000
            }
            PathLine {
                x: 400; y: 1000
            }
        }
    }

    PnidUiLabel {
        text: pnidElement._formattedValue
        position: pnidElement.valuePosition
    }
    PnidUiLabel {
        text: pnidElement.label
        position: pnidElement.labelPosition
        size: "large"
        yOffset: pnidElement.labelPosition == "center" ? 70 : 0
    }
}
