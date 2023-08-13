import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: numberInput

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    property string objectId: pnidElement.objectName
    property string label: ""
    property bool guiState
    property bool setState
    property bool value

    property string unit: ""
    property int min: 0
    property int max: 100

    onGuiStateChanged: {
        spinbox.value = guiState;
        checkDeviation();
    }
    onValueChanged: {
        checkDeviation();
    }
    function checkDeviation() {
        console.log("checking deviation", value, guiState); //TODO: Something is broken here
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
        numberInput.userInput.connect(pnidHandler.handleUserInput);
    }

    Layout.margins: Kirigami.Units.largeSpacing

    RowLayout {
        id: mainLayout
        Controls.SpinBox {
            id: spinbox

            from: numberInput.min
            to: numberInput.max

            onValueModified: {
                numberInput.userInput(numberInput.objectId, spinbox.value);
                numberInput.guiState = spinbox.value;
            }
            contentItem: RowLayout {
                TextInput {
                    id: customTextInput
                    z: 2
                    text: spinbox.textFromValue(spinbox.value, spinbox.locale)

                    font: spinbox.font
                    color: Kirigami.Theme.textColor
                    selectionColor: Kirigami.Theme.highlightColor
                    selectedTextColor: Kirigami.Theme.highlightedTextColor
                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter

                    readOnly: !spinbox.editable
                    validator: spinbox.validator
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    onTextEdited: {
                        console.log("text edited", this.text)
                        spinbox.value = parseInt(customTextInput.text)
                    }
                }
                Controls.Label {
                    visible: unit.length > 0
                    text: unit
                    color: Kirigami.Theme.disabledTextColor
                }
                Item {
                    width: Kirigami.Units.smallSpacing
                }
            }
        }
    }
}
