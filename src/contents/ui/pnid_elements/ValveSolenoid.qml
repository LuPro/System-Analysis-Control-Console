import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: valveServo
    width: 48
    height: 58
    /*layer.enabled: true //this should be antialiasing
    layer.samples: 4*/
    property double value;
    property int strokeWidth: 2;

    onValueChanged: {
        if (value > 0) {
            triangleRight.strokeColor = "#00aeff";
            triangleRight.fillColor = "transparent";
            triangleLeft.strokeColor = "#00aeff";
            triangleLeft.fillColor = "transparent";
            stem.strokeColor = "#00aeff";
            square.strokeColor = "#00aeff";
            label.strokeColor = "#ff0000";
            label.fillColor = "#ff0000";
        }
        else {
            triangleRight.strokeColor = "white";
            triangleRight.fillColor = "#ffa500";
            triangleLeft.strokeColor = "white";
            triangleLeft.fillColor = "#ffa500";
            stem.strokeColor = "white";
            square.strokeColor = "white";
            label.strokeColor = "white";
            label.fillColor = "white";
        }
    }

    Shape {
        //TODO: according to docs it's better to have as few shapes as possible and rather have more shapepaths
        //can I make pnid elements to be just shape paths and have one shape per pnid?
        //vendorExtensionsEnabled: false
        width: parent.width
        height: parent.height
        asynchronous: true


        ShapePath {
            id: triangleRight
            strokeWidth: valveServo.strokeWidth
            strokeColor: "white"
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
            strokeWidth: valveServo.strokeWidth
            strokeColor: "white"
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
            strokeWidth: valveServo.strokeWidth
            strokeColor: "white"
            strokeStyle: ShapePath.SolidLine
            fillColor: "transparent"

            startX: 24;  startY: 36
            PathLine {
                x: 24; y: 19
            }
        }
        ShapePath {
            id: square
            strokeWidth: valveServo.strokeWidth
            strokeColor: "white"
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
            strokeWidth: valveServo.strokeWidth == 1 ? 1 : valveServo.strokeWidth / 2
            strokeColor: "white"
            strokeStyle: ShapePath.SolidLine
            fillColor: "white"
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
