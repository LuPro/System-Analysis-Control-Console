import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: digitalInput

    property string label: ""
    property bool guiState
    property bool value

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
        digitalInput.userInput.connect(pnidHandler.handleUserInput);
    }

    Layout.margins: Kirigami.Units.largeSpacing

    RowLayout {
        Controls.CheckBox {
            id: checkbox
            text: digitalInput.label
            onCheckStateChanged: {
                digitalInput.userInput(pnidElement.objectName, checkbox.checkState)
            }

            contentItem: Text {
                text: checkbox.text
                font: checkbox.font
                opacity: enabled ? 1.0 : 0.3
                color: Kirigami.Theme.textColor
                verticalAlignment: Text.AlignVCenter
                leftPadding: checkbox.indicator.width + checkbox.spacing
            }
        }
    }
}