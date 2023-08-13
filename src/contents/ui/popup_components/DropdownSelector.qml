import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: dropdownInput

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    property string objectId: pnidElement.objectName
    property string label: ""
    property bool guiState
    property bool setState
    property bool value

    property string unit: ""
    property var options
    property var explicitValues: undefined

    onGuiStateChanged: {
        combobox.value = guiState;
        checkDeviation();
    }
    onValueChanged: {
        checkDeviation();
    }
    function checkDeviation() {
        if (value == guiState)
        {
            customTextInput.color = Kirigami.Theme.textColor;
        }
        else
        {
            customTextInput.color = Kirigami.Theme.negativeTextColor;
        }
    }

    signal userInput(string id, real value)

    Component.onCompleted: {
        options.push("Unknown");
        dropdownInput.userInput.connect(pnidHandler.handleUserInput);
    }

    Layout.margins: Kirigami.Units.largeSpacing

    function _getValue() {
        if (explicitValues === undefined) {
            return combobox.currentIndex;
        }
        return explicitValues[combobox.currentIndex];
    }

    RowLayout {
        id: mainLayout
        Controls.ComboBox {
            id: combobox
            model: dropdownInput.options
            onActivated: {
                let selectedValue = dropdownInput._getValue();
                dropdownInput.userInput(dropdownInput.objectId, selectedValue);
                dropdownInput.guiState = selectedValue;
            }
        }
    }
}
