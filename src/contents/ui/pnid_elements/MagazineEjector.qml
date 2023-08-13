import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../popup_components"
import "../components"

Item {
    id: pnidElement
    width: 1200
    height: 300
    /*layer.enabled: true //this should be antialiasing
    layer.samples: 4*/
    property string displayName
    property double guiState
    property double setState
    property double value
    property double maxValue: 100
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
    property var subObjectIds //list of strings
    property var subObjectGuiStates //list of double
    property var subObjectSetStates //list of double
    property var subObjectValues //list of double

    property string _formattedValue //this is only for internal use
    property int _scaledStrokeWidth: strokeWidth / pnid.zoomScale

    Component.onCompleted: {
        piston.updatePistonPosition(0);
        for (let subObject of subObjectIds) {
            pnidHandler.registerSubObject(pnidElement.objectName, subObject);
        }
        subObjectGuiStates = Array(subObjectIds.length).fill(undefined);
        subObjectSetStates = Array(subObjectIds.length).fill(undefined);
        subObjectValues = Array(subObjectIds.length).fill(undefined);
        console.log("set up sub object gui states", subObjectGuiStates);
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
        console.log("styling for magazine ejector not yet done");
        piston.updatePistonPosition(value/maxValue);
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
        console.log("sub object gui states changed", subObjectGuiStates);
    }

    onSubObjectSetStatesChanged: {
        console.log("sub object set states changed", subObjectSetStates);
    }

    onSubObjectValuesChanged: {
        console.log("sub object values changed", subObjectValues);
        piston.updatePistonPosition(subObjectValues[0]);
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
                    popup.visible = true && (!pnidElement.disablePopup);
                }

            }
        }

        ShapePath {
            id: container
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 700;  startY: 0
            PathLine {
                x: 1200; y: 0
            }
            PathLine {
                x: 1200; y: 300
            }
            PathLine {
                x: 700; y: 300
            }
            PathLine {
                x: 700; y: 0
            }
        }
        ShapePath {
            id: piston
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            function updatePistonPosition(pos) {
                let clampedPos = Math.max(Math.min(pos || 0, 1), 0);
                let moveDistance = 250;
                let piston = `M ${100+clampedPos*moveDistance} 0 l 0 300 m 100 0 l 0 -300 `;
                let pistonPlunger = `M ${200+clampedPos*moveDistance} 100 l 500 0 l 0 100 l -500 0 `;
                let springPath = `M ${200+clampedPos*moveDistance} 30 L ${300+clampedPos*moveDistance*3/4} 270
                l 0 -70 m 0 -100 l 0 -70 L ${400+clampedPos*moveDistance*2/4} 270
                l 0 -70 m 0 -100 l 0 -70 L ${500+clampedPos*moveDistance*1/4} 270
                l 0 -70 m 0 -100 l 0 -70 L 600 270`;

                pistonPath.path = piston + pistonPlunger + springPath;
                console.log("pistonPath", pistonPath.path);
            }

            PathSvg {
                id: pistonPath
                path: ""
            }
        }
        ShapePath {
            id: cylinder
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 0;  startY: 0
            PathLine {
                x: 600; y: 0
            }
            PathLine {
                x: 600; y: 300
            }
            PathLine {
                x: 0; y: 300
            }
            PathLine {
                x: 0; y: 0
            }
        }
    }
}
