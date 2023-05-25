import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: valueDisplay

    property string label: "Value";
    property string value;

    Layout.margins: Kirigami.Units.largeSpacing

    onValueChanged: {
        console.log("value changed popup", value);
        display.text = value;
    }

    RowLayout {
        Controls.Label {
            text: valueDisplay.label ? valueDisplay.label + ":" : ""
        }

        Controls.Label {
            id: display
            text: "-"
        }
    }
}
