import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../popup_components"
import "../components"

Item {
    id: pnidElement
    width: rotation % 2 ? 500 : 400
    height: rotation % 2 ? 400 : 500
    /*layer.enabled: true //this should be antialiasing
    layer.samples: 4*/
    property string displayName
    property double guiState
    property double setState
    property double value
    property int strokeWidth: 2
    property string valuePosition: "bottom"
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
        if (value > 0) {
            triangleRight.strokeColor = "#00aeff";
            triangleRight.fillColor = "transparent";
            triangleLeft.strokeColor = "#00aeff";
            triangleLeft.fillColor = "transparent";
            stem.strokeColor = "#00aeff";
            square.strokeColor = "#00aeff";
            label.strokeColor = Kirigami.Theme.negativeTextColor;
            label.fillColor = Kirigami.Theme.negativeTextColor;
            _formattedValue = "Open";
        }
        else {
            triangleRight.strokeColor = Kirigami.Theme.textColor;
            triangleRight.fillColor = "#ffa500";
            triangleLeft.strokeColor = Kirigami.Theme.textColor;
            triangleLeft.fillColor = "#ffa500";
            stem.strokeColor = Kirigami.Theme.textColor;
            square.strokeColor = Kirigami.Theme.textColor;
            label.strokeColor = Kirigami.Theme.textColor;
            label.fillColor = Kirigami.Theme.textColor;
            _formattedValue = "Closed";
        }

        //TODO: It'd be better if I stop doing stuff I don't need to if outside of tolerance (eg: coloring open/close
        //because this will be overridden here), but that may need code duplication for things that should happen
        //regardless of in tolerance or not?
        if (!isInTolerance(value, setState)) {
            triangleRight.strokeColor = Kirigami.Theme.negativeTextColor;
            triangleRight.fillColor = "transparent";
            triangleLeft.strokeColor = Kirigami.Theme.negativeTextColor;
            triangleLeft.fillColor = "transparent";
            stem.strokeColor = Kirigami.Theme.negativeTextColor;
            square.strokeColor = Kirigami.Theme.negativeTextColor;
            label.strokeColor = Kirigami.Theme.textColor;
            label.fillColor = Kirigami.Theme.textColor;
        }
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
            DigitalInput {
                id: checkboxInput
                label: "this is a cool label"
                value: pnidElement.value
                guiState: pnidElement.guiState
                setState: pnidElement.setState
            }
            SliderInput {
                id: sliderInput
                value: pnidElement.value
                guiState: pnidElement.guiState
                setState: pnidElement.setState
            }
            NumberInput {
                id: numberInput
                value: pnidElement.value
                guiState: pnidElement.guiState
                setState: pnidElement.setState
                unit: "kg"
            }
            DropdownSelector {
                id: dropdownInput
                options: ["Product A", "Product B"]
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
            id: triangleRight
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 400;  startY: 200
            PathLine {
                x: 200; y: 350
            }
            PathLine {
                x: 400; y: 500
            }
            PathLine {
                x: 400; y: 200
            }
            //PathSvg { path: "L 150 50 L 100 150 z" }
        }
        ShapePath {
            id: triangleLeft
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 200;  startY: 350
            PathLine {
                x: 0; y: 200
            }
            PathLine {
                x: 0; y: 500
            }
            PathLine {
                x: 200; y: 350
            }
        }
        ShapePath {
            id: stem
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 200;  startY: 200
            PathLine {
                x: 200; y: 350
            }
        }
        ShapePath {
            id: square
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 100;  startY: 0
            PathLine {
                x: 300; y: 0
            }
            PathLine {
                x: 300; y: 200
            }
            PathLine {
                x: 100; y: 200
            }
            PathLine {
                x: 100; y: 0
            }
        }
        PnidSvgLabel {
            id: label
            text: "S"
            x: 155
            y: 45
        }
    }

    PnidUiLabel {
        text: pnidElement._formattedValue
        position: pnidElement.valuePosition
    }
}
