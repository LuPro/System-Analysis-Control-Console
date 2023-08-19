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
    property double guiState
    property double setState
    property double value

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
            dropdownInput.text.color = Kirigami.Theme.textColor;
        }
        else
        {
            dropdownInput.text.color = Kirigami.Theme.negativeTextColor;
        }
    }

    signal userInput(string id, real value)

    Component.onCompleted: {
        options.push("Unknown"); //TODO: this seems to not do anything, maybe combobox doesn't take in updates to model?
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
