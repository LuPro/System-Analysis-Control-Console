import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../popup_components"
import "../components"

Item {
    id: pnidElement
    width: rotation % 2 ? 600 : 600
    height: rotation % 2 ? 600 : 600
    /*layer.enabled: true //this should be antialiasing
    layer.samples: 4*/
    property string displayName
    property double guiState
    property double setState
    property double value
    property double maxValue: 1
    property int strokeWidth: 2
    property string valuePosition: "bottom"
    property int rotation: 0 //rotation id: 0, 1, 2, 3 -> 90° steps

    property string unit
    property string content
    property var connections //list of connection points that other elements can connect to

    property bool checkSensTolerance: true

    property bool disablePopup: false
    //sub objects are for elements that aren't following the main value of the pnid element
    //eg: having a speed setting on a servo additionally to its position slider

    //list of available sub objects (human readable). only needed for eventual UI builder
    //TODO: add some metadata to this? eg: is value optional, is it readonly, writeonly, rw, ...
    property var subObjectSlots: ["ArmRetracted", "SuctionCupDown", "SuctionCupIsUp", "VacuumOn", "WorkpiecePickedUp"]
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

        piston.updatePistonPosition(0);
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
        armBase.updateArmPos(value/maxValue);
        if (subObjectValues[3]) {
            suctionArm.strokeColor = Kirigami.Theme.neutralTextColor;
        } else {
            suctionArm.strokeColor = Kirigami.Theme.textColor;
        }

        if (subObjectValues[4]) {
            object.strokeColor = Kirigami.Theme.textColor;
            object.strokeStyle = ShapePath.SolidLine;
        } else {
            object.strokeStyle = ShapePath.DashLine;
            //TODO: Commented out due to Qt bug, otherwise it's invisible forever
            //object.strokeColor = "transparent";
        }

        if (maxValue == 1) {
            if (value) {
                _formattedValue = "Extended";
            } else {
                _formattedValue = "Retracted";
            }
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
                value: pnidElement.value
                label: "Arm Extended"
            }
            DigitalInput {
                id: digitalInput
                label: "Extend Slide"
                value: pnidElement.subObjectValues[1] !== undefined ? pnidElement.subObjectValues[1] : false
                guiState: pnidElement.subObjectGuiStates[1] !== undefined ? pnidElement.subObjectGuiStates[1] : false
                setState: pnidElement.subObjectSetStates[1] !== undefined ? pnidElement.subObjectSetStates[1] : false
                objectId: pnidElement.subObjectIds[1] !== undefined ? pnidElement.subObjectIds[1] : false
            }

            Graph {
                id: graphDisplay
                label: pnidElement.displayName
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
                    popup.visible = true && (!pnidElement.disablePopup);
                }

            }
        }

        ShapePath {
            id: rail
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: Kirigami.Theme.highlightColor

            startX: 0;  startY: 0
            PathLine {
                x: 600; y: 0
            }
        }
        ShapePath {
            id: armBase
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            function updateArmPos(pos) {
                console.log("arm % pos", pos);
                let clampedPos = Math.max(Math.min(pos || 0, 1), 0);
                let basePos = 50 + clampedPos*400;
                armBasePath.path = `M ${basePos} 25 l 100 0 l 0 100 l -40 40 l -20 0 l -40 -40 l 0 -100`;
                //TODO: this currently uses the same max value as arm base
                suctionArm.updateExtension(subObjectValues[1]/maxValue, basePos + 50);
            }

            PathSvg {
                id: armBasePath
                path: "M 50 25 l 100 0 l 0 100 l -40 40 l -20 0 l -40 -40 l 0 -100"
            }
        }
        ShapePath {
            id: suctionArm
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            function updateExtension(extension, basePos) {
                let clampedExtension = Math.max(Math.min(extension || 0, 1), 0);
                armPath.path = `M ${basePos} 165 l 0 ${65 + clampedExtension * 280} l -50 40 l 100 0 l -50 -40`;
                console.log("base pos", basePos, 270 + clampedExtension * 280, "extension", clampedExtension, extension)
                object.updatePosition(basePos, 270 + clampedExtension * 280);
            }

            PathSvg {
                id: armPath
                path: "M 100 165 l 0 65 l -50 40 l 100 0 l -50 -40"
            }
        }
        ShapePath {
            id: object
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            dashPattern: [1, 100]
            dashOffset: 5
            fillColor: "transparent"

            function updatePosition(baseX, baseY) {
                objectPath.path = `M ${baseX} ${baseY} m -75 0 l 0 50 l 150 0 l 0 -50 l -150 0`;
            }

            PathSvg {
                id: objectPath
                path: "M 25 270 l 150 0 l 0 50 l -150 0 l 0 -50"
            }
        }
    }

    PnidUiLabel {
        text: pnidElement._formattedValue
        position: pnidElement.valuePosition
    }
}
