import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami

Controls.Label {
    id: textLabel

    //TODO: Offset not implemented yet
    property int xOffset
    property int yOffset

    transform: [
        Scale {
            xScale: 1/pnid.zoomScale
            yScale: 1/pnid.zoomScale
        },
        Translate  {
            x: pnidElement.valuePosition !== "right"
               ? pnidElement.valuePosition === "left"
                 ? -(textLabel.width)/pnid.zoomScale
                 : -(textLabel.width/2)/pnid.zoomScale
               : 0
            y: pnidElement.valuePosition !== "bottom"
               ? pnidElement.valuePosition === "top"
                 ? -(textLabel.height)/pnid.zoomScale
                 : -(textLabel.height/2)/pnid.zoomScale
               : 0
        }
    ]

    text: "Label text not connected to value!"
    visible: pnidElement.valuePosition == "none" ? false : true
    anchors.margins: (pnidElement.valuePosition == "bottom") || (pnidElement.valuePosition == "top")
                     ? 5/pnid.zoomScale : 8/pnid.zoomScale
    anchors.top: pnidElement.valuePosition == "bottom" ? pnidElement.bottom : undefined
    anchors.bottom: pnidElement.valuePosition == "top" ? pnidElement.top : undefined
    anchors.left: pnidElement.valuePosition == "right" ? pnidElement.right : undefined
    anchors.right: pnidElement.valuePosition == "left" ? pnidElement.left : undefined
    anchors.horizontalCenter: (pnidElement.valuePosition == "bottom") || (pnidElement.valuePosition == "top")
                              ? pnidElement.horizontalCenter : undefined
    anchors.verticalCenter: (pnidElement.valuePosition == "left") || (pnidElement.valuePosition == "right")
                            ? pnidElement.verticalCenter : undefined
}
