import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami

Controls.Label {
    id: textLabel

    //TODO: Offset not implemented yet
    property int xOffset: 0
    property int yOffset: 0

    property color labelColor: Kirigami.Theme.textColor
    property string size: "medium"
    property string position: "bottom"

    transform: [
        Scale {
            xScale: 1/pnid.zoomScale
            yScale: 1/pnid.zoomScale
        },
        Translate  {
            x: textLabel.position !== "right"
               ? textLabel.position === "left"
                 ? -(textLabel.width)/pnid.zoomScale + textLabel.width + xOffset
                 : -(textLabel.width/2)/pnid.zoomScale + textLabel.width/2 + xOffset
               : xOffset
            y: textLabel.position !== "bottom"
               ? textLabel.position === "top"
                 ? -(textLabel.height)/pnid.zoomScale + textLabel.height + yOffset
                 : -(textLabel.height/2)/pnid.zoomScale + textLabel.height/2 + yOffset
               : yOffset
        }
    ]

    text: "Label text not connected to value!"
    font.pointSize: size === "medium"
                    ? Kirigami.Theme.defaultFont.pointSize
                    : size === "small"
                      ? Kirigami.Theme.defaultFont.pointSize * 0.8
                      : size === "large"
                        ? Kirigami.Theme.defaultFont.pointSize * 1.3
                        : undefined;
    visible: textLabel.position == "none" ? false : true
    anchors.margins: (textLabel.position == "bottom") || (textLabel.position == "top")
                     ? 5/pnid.zoomScale : 8/pnid.zoomScale
    anchors.top: textLabel.position == "bottom" ? pnidElement.bottom : undefined
    anchors.bottom: textLabel.position == "top" ? pnidElement.top : undefined
    anchors.left: textLabel.position == "right" ? pnidElement.right : undefined
    anchors.right: textLabel.position == "left" ? pnidElement.left : undefined
    anchors.centerIn: textLabel.position == "center" ? pnidElement : undefined
    anchors.horizontalCenter: (textLabel.position == "bottom") || (textLabel.position == "top")
                              ? pnidElement.horizontalCenter : undefined
    anchors.verticalCenter: (textLabel.position == "left") || (textLabel.position == "right")
                            ? pnidElement.verticalCenter : undefined

    color: labelColor
}
