import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../popup_components"
import "../components"

Item {
    id: pnidElement
    width: 300
    height: 300
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
    property var subObjectSlots: ["Motor Backwards"]
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
        if (value && !subObjectValues[0]) {
            _formattedValue = "Forwards";
            square.strokeColor = Kirigami.Theme.neutralTextColor;
        } else if (!value && subObjectValues[0]) {
            _formattedValue = "Backwards";
            square.strokeColor = Kirigami.Theme.neutralTextColor;
        } else if (!value && !subObjectValues[0]) {
            _formattedValue = "Off";
            square.strokeColor = Kirigami.Theme.textColor;
            square.fillColor = "transparent";
        } else {
            _formattedValue = "Undefined";
            square.strokeColor = Kirigami.Theme.negativeTextColor;
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
                label: pnidElement.subObjectIds !== undefined ? "Forwards" : "On/Off"
                value: pnidElement.value ? "On" : "Off"
            }
            DigitalInput {
                id: checkboxInput
                label: pnidElement.subObjectIds !== undefined ? "Motor Forwards" : "Motor On"
                value: pnidElement.value
                guiState: pnidElement.guiState
                setState: pnidElement.setState
            }
            ValueDisplay {
                id: backwardsDisplay
                visible: pnidElement.subObjectIds !== undefined
                label: "Backwards"
                value: pnidElement.subObjectIds !== undefined
                       ? pnidElement.subObjectValues[0] !== undefined
                         ? pnidElement.subObjectValues[0] : "On"
                       : "Off"
            }
            DigitalInput {
                visible: pnidElement.subObjectIds !== undefined
                label: "Motor Backwards"
                value: pnidElement.subObjectValues !== undefined
                       ? pnidElement.subObjectValues[0] !== undefined
                         ? pnidElement.subObjectValues[0]
                         : false
                       : false
                guiState: pnidElement.subObjectGuiState !== undefined
                          ? pnidElement.subObjectGuiState[0] !== undefined
                            ? pnidElement.subObjectGuiState[0]
                            : false
                          : false
                setState: pnidElement.subObjectSetState !== undefined
                          ? pnidElement.subObjectSetState[0] !== undefined
                            ? pnidElement.subObjectSetState[0]
                            : false
                          : false
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
            id: square
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 0;  startY: 0
            PathLine {
                x: 300; y: 0
            }
            PathLine {
                x: 300; y: 300
            }
            PathLine {
                x: 0; y: 300
            }
            PathLine {
                x: 0; y: 0
            }
        }
        PnidSvgLabel {
            text: "M"
            position: "center"
        }
    }

    PnidUiLabel {
        text: pnidElement._formattedValue
        position: pnidElement.valuePosition
    }
}
