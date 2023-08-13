import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../popup_components"
import "../components"

Item {
    id: pnidElement
    width: 500
    height: 1000
    /*layer.enabled: true //this should be antialiasing
    layer.samples: 4*/
    property string displayName
    property double guiState
    property double setState
    property double value
    property double maxValue: 5 //TODO: Some way of turning off fill level display would be good I think
    property bool showDividers: true
    //TODO: Right now the container assumes 0 is minimum, but maybe this is not always the case?

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
    property var popupPacketIds //list of strings
    property var popupGuiStates //list of double
    property var popupSetStates //list of double
    property var popupValues //list of double

    property string _formattedValue //this is only for internal use
    property int _scaledStrokeWidth: strokeWidth / pnid.zoomScale

    Component.onCompleted: {
        let pathSvg = "";
        for (let i = 1; i <= Math.round(maxValue); i++) {
            let yStr = "" + i * (1000 * (1 - Math.min(Math.max(pnidElement.value/pnidElement.maxValue, 0), 1)))/Math.round(maxValue);
            pathSvg += "M 0 " + yStr + " L 500 " + yStr + " ";
        }

        console.log("path svg", pathSvg);
        dividerLinesSvg.path = pathSvg;
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
        _formattedValue = value + "/" + maxValue;
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

    PnidUiLabel {
        text: pnidElement._formattedValue
        position: pnidElement.valuePosition
    }
    PnidUiLabel {
        text: pnidElement.label
        position: pnidElement.labelPosition
        size: "large"
    }

    Shape {
        //TODO: according to docs it's better to have as few shapes as possible and rather have more shapepaths
        //can I make pnid elements to be just shape paths and have one shape per pnid?
        //vendorExtensionsEnabled: false
        width: parent.width
        height: parent.height
        asynchronous: true
        transform: Rotation {
            origin.x: pnidElement.width/2
            origin.y: pnidElement.height/2
            angle: 90 * rotation
        }

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
            id: content
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: "transparent"
            strokeStyle: ShapePath.SolidLine
            fillColor: Kirigami.Theme.highlightColor

            startX: 0;  startY: 1000
            PathLine {
                x: 0; y: 1000 * (1 - Math.min(Math.max(pnidElement.value/pnidElement.maxValue, 0), 1))
            }
            PathLine {
                x: 500; y: 1000 * (1 - Math.min(Math.max(pnidElement.value/pnidElement.maxValue, 0), 1))
            }
            PathLine {
                x: 500; y: 1000
            }
            PathLine {
                x: 0; y: 1000
            }
        }

        ShapePath {
            id: dividerLines
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: pnidElement.showDividers === true ? Kirigami.Theme.textColor : "transparent"
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"
            PathSvg {
                id: dividerLinesSvg
                path: ""
            }
        }

        ShapePath {
            id: outline
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 0;  startY: 0
            PathLine {
                x: 500; y: 0
            }
            PathLine {
                x: 500; y: 1000
            }
            PathLine {
                x: 0; y: 1000
            }
            PathLine {
                x: 0; y: 0
            }
        }
    }
}
