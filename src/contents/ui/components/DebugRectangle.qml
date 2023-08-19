import QtQuick 2.15

Rectangle {
    property var toFill: parent          // instantiation site "can" (optionally) override
    property color borderColor: 'yellow' // instantiation site "can" (optionally) override
    property int thickness: 1      // instantiation site "can" (optionally) override
    property double scale: pnid.zoomScale

    anchors.fill: toFill
    z: 200
    color: 'transparent'
    border.color: borderColor
    border.width: thickness / scale
}
