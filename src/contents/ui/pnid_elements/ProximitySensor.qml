import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../popup_components"
import "../components"

Item {
    id: pnidElement
    width: rotation % 2 ? 350 : 300
    height: rotation % 2 ? 300 : 350
    /*layer.enabled: true //this should be antialiasing
    layer.samples: 4*/
    property string displayName
    property double guiState
    property double setState
    property double value
    property bool activeLow: false

    property int strokeWidth: 2
    property string valuePosition: "bottom"
    property string label: "Proximity"
    property string labelPosition: "top"
    property int rotation: 0 //rotation id: 0, 1, 2, 3 -> 90° steps

    property string unit
    property string content
    property var connections //list of connection points that other elements can connect to

    property bool checkSensTolerance: false

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

        //hack because color doesn't apply properly otherwise on detectedObject
        //detectedObject.strokeColor = "transparent";
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
        if (activeLow && value == 0 || !activeLow && value != 0) {
            detectedObject.strokeColor = Kirigami.Theme.positiveTextColor;
            detector.fillColor = Kirigami.Theme.positiveTextColor;
            _formattedValue = "Detected";
        } else {
            detectedObjectPath.path = "";
            detectedObject.strokeColor = "transparent";
            detector.fillColor = "transparent";
            _formattedValue = "Not Detected";
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
                    popup.visible = true && (!pnidElement.disablePopup);;
                }

            }
        }

        ShapePath {
            id: detector
            strokeWidth: pnidElement._scaledStrokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 0;  startY: 0
            PathLine {
                x: 300; y: 0
            }
            PathLine {
                x: 300; y: 150
            }
            PathLine {
                x: 0; y: 150
            }
            PathLine {
                x: 0; y: 0
            }
        }
        ShapePath {
            id: detectedObject
            strokeWidth: pnidElement._scaledStrokeWidth / 1.5
            strokeColor: Kirigami.Theme.positiveTextColor //TODO: should be "transparent", but due to Qt bug that breaks and makes it transparent forever
            strokeStyle: ShapePath.DashLine
            dashPattern: [1, 4]
            fillColor: "transparent"

            startX: 50; startY: 140
            PathSvg {
                id: detectedObjectPath
                path: "M 0 350 A 200 200 0 0 1 300 350" //empty because hack because color doesn't apply properly, see applyStyling() for path data
            }
        }
    }

    PnidUiLabel {
        text: pnidElement._formattedValue
        position: pnidElement.valuePosition
        yOffset: pnidElement.labelPosition == "bottom" && pnidElement.valuePosition == "bottom" ? 150 : 0
    }

    PnidUiLabel {
        text: pnidElement.label
        position: pnidElement.labelPosition
    }
}
