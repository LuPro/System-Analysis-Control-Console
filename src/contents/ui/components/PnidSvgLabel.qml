import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami

ShapePath {
    id: label

    property string text: ""
    property int pixelSize: 150
    property var strokeWidthOverride: undefined
    property var x: undefined
    property var y: undefined

    property int xOffset: 0
    property int yOffset: 0

    strokeWidth: strokeWidthOverride !== undefined
                 ? strokeWidthOverride/pnid.zoomScale/2
                 : Math.max(1, pnidElement._scaledStrokeWidth / 2)
    strokeColor: Kirigami.Theme.textColor
    strokeStyle: ShapePath.SolidLine
    fillColor: Kirigami.Theme.textColor
    PathText {
        //TODO: unknown defaults to on the right, I'd rather have that default to center I think
        x: label.x !== undefined ? label.x : (pnidElement.labelPosition === "center" ||
           pnidElement.labelPosition === "top" ||
           pnidElement.labelPosition === "bottom")
           ? pnidElement.width/2 - width / 2 - 10 + label.xOffset
           : pnidElement.labelPosition === "left" ? -60 - width + label.xOffset : pnidElement.width + 60 + label.xOffset
        //TODO: this defaults to bottom on unknown, similar issue as with x coord
        y: label.y !== undefined ? label.y : (pnidElement.labelPosition === "center" ||
            pnidElement.labelPosition === "left" ||
            pnidElement.labelPosition === "right")
            ? pnidElement.height/2 - height / 2 + label.yOffset
            : pnidElement.labelPosition === "top" ? -60 - height + label.yOffset : pnidElement.height + 60 + label.yOffset
        font.family: "Montserrat"
        font.pixelSize: label.pixelSize
        font.weight: Font.Thin
        text: label.text
    }
}
