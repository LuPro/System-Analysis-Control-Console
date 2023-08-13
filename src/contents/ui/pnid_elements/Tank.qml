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
    property var subObjectIds //list of strings
    property var subObjectGuiStates //list of double
    property var subObjectSetStates //list of double
    property var subObjectValues //list of double

    property string _formattedValue //this is only for internal use
    property int _scaledStrokeWidth: strokeWidth / pnid.zoomScale

    Component.onCompleted: {
        subObjectGuiStates = Array(subObjectIds.length).fill(undefined);
        subObjectSetStates = Array(subObjectIds.length).fill(undefined);
        subObjectValues = Array(subObjectIds.length).fill(undefined);

        for (let subObject of subObjectIds) {
            pnidHandler.registerSubObject(pnidElement.objectName, subObject);
        }
    }

    function setSubObjectGuiState(subId: string, subValue: double) {
        for (let i = 0; i < subObjectIds.length; i++) {
            if (subObjectIds[i] === subId) {
                subObjectGuiStates[i] = subValue;
            }
        }
        subObjectGuiStatesChanged();
    }

    function setSubObjectSetState(subId: string, subValue: double) {
        for (let i = 0; i < subObjectIds.length; i++) {
            if (subObjectIds[i] === subId) {
                subObjectSetStates[i] = subValue;
            }
        }
        subObjectSetStatesChanged();
    }

    function setSubObjectValue(subId: string, subValue: double) {
        for (let i = 0; i < subObjectIds.length; i++) {
            if (subObjectIds[i] === subId) {
                subObjectValues[i] = subValue;
            }
        }
        subObjectValuesChanged();
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

    onSubObjectGuiStatesChanged: {
    }

    onSubObjectSetStatesChanged: {
    }

    onSubObjectValuesChanged: {
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
            id: topArc
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            PathSvg {
                path: "M 500 100 A 365 365 0 0 0 0 100"
            }
        }
        ShapePath {
            id: bottomArc
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            PathSvg {
                path: "M 0 900 A 365 365 0 0 0 500 900"
            }
        }
        ShapePath {
            id: content
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: "transparent"
            strokeStyle: ShapePath.SolidLine
            fillColor: Kirigami.Theme.highlightColor

            startX: 0;  startY: 900
            PathLine {
                id: contentTopLeft
                x: 0; y: 100 + 800 * (1 - Math.min(Math.max(pnidElement.value/pnidElement.maxValue, 0), 1))
            }
            PathLine {
                id: contentTopRight
                x: 500; y: 100 + 800 * (1 - Math.min(Math.max(pnidElement.value/pnidElement.maxValue, 0), 1))
            }
            PathLine {
                x: 500; y: 900
            }
            PathLine {
                x: 0; y: 900
            }
        }
        ShapePath {
            id: outline
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 0;  startY: 100
            PathLine {
                x: 500; y: 100
            }
            PathLine {
                x: 500; y: 900
            }
            PathLine {
                x: 0; y: 900
            }
            PathLine {
                x: 0; y: 100
            }
        }
    }
}
