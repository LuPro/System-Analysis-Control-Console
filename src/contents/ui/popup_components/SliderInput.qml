import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: sliderInput

    property string label: ""
    property double guiState
    property double setState
    property double value

    property double min: 0.0
    property double max: 100.0
    property double stepSize: 0
    property string minLabel
    property string maxLabel

    onGuiStateChanged: {
        checkbox.checked = guiState;
        checkDeviation();
    }
    onValueChanged: {
        checkDeviation();
    }
    function checkDeviation() {
        if (value == guiState)
        {
            checkbox.contentItem.color = Kirigami.Theme.textColor;
        }
        else
        {
            checkbox.contentItem.color = Kirigami.Theme.negativeTextColor;
        }
    }

    signal userInput(string id, real value)

    Component.onCompleted: {
        sliderInput.userInput.connect(pnidHandler.handleUserInput);
    }

    Layout.margins: Kirigami.Units.largeSpacing

    RowLayout {
        Controls.Slider {
            id: slider
            from: sliderInput.min
            to: sliderInput.max
            stepSize: sliderInput.stepSize
            snapMode: Controls.Slider.SnapAlways

            //tickmarksEnabled: stepSize > 0 && ((max - min) / stepSize) <= 10 ? true : false
            onValueChanged: {
                sliderInput.userInput(pnidElement.objectName, slider.value);
                sliderInput.guiState = slider.value;
            }
        }
    }
}
