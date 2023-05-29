import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami
import "../popup_components"

Item {
    id: pnidElement
    width: 48
    height: 58
    /*layer.enabled: true //this should be antialiasing
    layer.samples: 4*/
    property string displayName
    property double guiState
    property double setState
    property double value
    property int strokeWidth: 2
    property string labelPosition: "bottom"

    property bool checkSensTolerance: true

    //popup lists are for elements that aren't following the main value of the pnid element
    //eg: having a speed setting on a servo additionally to its position slider
    property var popupPacketIds //list of strings
    property var popupGuiStates //list of double
    property var popupSetStates //list of double
    property var popupValues //list of double

    property string _formattedValue //this is only for internal use

    function isInTolerance(measurement, reference) {
        console.log("check is in tolerance", measurement, reference)
        if (!checkSensTolerance || measurement === reference) {
            console.log("is in tolerance");
            return true;
        }
        console.log("is not in tolerance");
        return false;
    }

    function applyStyling() {
        console.log("applying styling", value, setState);
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
            spacing: Kirigami.Units.largeSpacing

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
        }
    }

    Controls.Label {
        text: pnidElement._formattedValue
        visible: pnidElement.labelPosition == "none" ? false : true
        anchors.margins: (pnidElement.labelPosition == "bottom") || (pnidElement.labelPosition == "top")
                         ? 5 : 8
        anchors.top: pnidElement.labelPosition == "bottom" ? pnidElement.bottom : undefined
        anchors.bottom: pnidElement.labelPosition == "top" ? pnidElement.top : undefined
        anchors.left: pnidElement.labelPosition == "right" ? pnidElement.right : undefined
        anchors.right: pnidElement.labelPosition == "left" ? pnidElement.left : undefined
        anchors.horizontalCenter: (pnidElement.labelPosition == "bottom") || (pnidElement.labelPosition == "top")
                                  ? pnidElement.horizontalCenter : undefined
        anchors.verticalCenter: (pnidElement.labelPosition == "left") || (pnidElement.labelPosition == "right")
                                  ? pnidElement.verticalCenter : undefined
    }

    Shape {
        //TODO: according to docs it's better to have as few shapes as possible and rather have more shapepaths
        //can I make pnid elements to be just shape paths and have one shape per pnid?
        //vendorExtensionsEnabled: false
        width: parent.width
        height: parent.height
        asynchronous: true

        TapHandler {
            onTapped: {
                if (popup.visible == true)
                {
                    //somehow highlight the already open popup
                }
                else
                {
                    popup.visible = true;
                }

            }
        }

        ShapePath {
            id: triangleRight
            strokeWidth: pnidElement.strokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 24;  startY: 36
            PathLine {
                x: 48; y: 58
            }
            PathLine {
                x: 48; y: 14
            }
            PathLine {
                x: 24; y: 36
            }
            //PathSvg { path: "L 150 50 L 100 150 z" }
        }
        ShapePath {
            id: triangleLeft
            strokeWidth: pnidElement.strokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 0;  startY: 14
            PathLine {
                x: 0; y: 58
            }
            PathLine {
                x: 24; y: 36
            }
            PathLine {
                x: 0; y: 14
            }
        }
        ShapePath {
            id: stem
            strokeWidth: pnidElement.strokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 24;  startY: 36
            PathLine {
                x: 24; y: 19
            }
        }
        ShapePath {
            id: square
            strokeWidth: pnidElement.strokeWidth
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 14;  startY: 0
            PathLine {
                x: 34; y: 0
            }
            PathLine {
                x: 34; y: 19
            }
            PathLine {
                x: 14; y: 19
            }
            PathLine {
                x: 14; y: 0
            }
        }
        ShapePath {
            id: label
            strokeWidth: pnidElement.strokeWidth == 1 ? 1 : pnidElement.strokeWidth / 2
            strokeColor: Kirigami.Theme.textColor
            strokeStyle: ShapePath.SolidLine
            fillColor: Kirigami.Theme.textColor
            PathText {
                x: 20
                y: 4
                font.family: "Montserrat"
                font.pixelSize: 15
                text: "S"
            }
        }
    }
}
