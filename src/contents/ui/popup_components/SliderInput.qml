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
    property string minLabel: min
    property string maxLabel: max
    property double _deviationTolerance: 0.01
    //TODO: I don't like that the tolerance here can be different to the pnid tolerance

    onGuiStateChanged: {
        console.log("gui state changed", guiState);
        slider.value = guiState;
        checkDeviation();
    }
    onValueChanged: {
        console.log("value changed", value);
        checkDeviation();
    }
    function checkDeviation() {
        if (value + (sliderInput.max - sliderInput.min) * _deviationTolerance > guiState &&
            value - (sliderInput.max - sliderInput.min) * _deviationTolerance < guiState)
        {
            //sliderLabel.color = Kirigami.Theme.textColor;
            handle.color = Kirigami.Theme.backgroundColor
        }
        else
        {
            //sliderLabel.color = Kirigami.Theme.negativeTextColor;
            handle.color = Kirigami.Theme.negativeBackgroundColor
        }
    }

    signal userInput(string id, real value)

    Component.onCompleted: {
        sliderInput.userInput.connect(pnidHandler.handleUserInput);
    }

    Layout.margins: Kirigami.Units.largeSpacing


    RowLayout {
        ColumnLayout {
            //Controls.Slider {}
            Controls.Slider {
                id: slider
                from: sliderInput.min
                to: sliderInput.max
                stepSize: sliderInput.stepSize
                snapMode: Controls.Slider.SnapAlways

                implicitHeight: Kirigami.Units.gridUnit * 1.1

                //tickmarksEnabled: stepSize > 0 && ((max - min) / stepSize) <= 10 ? true : false
                onMoved: {
                    sliderInput.userInput(pnidElement.objectName, slider.value);
                    sliderInput.guiState = slider.value;
                }

                //TODO: Qt.lighter should be Qt.darker on a light theme and vice versa
                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: slider.availableWidth
                    height: implicitHeight
                    radius: 3
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window
                    Kirigami.Theme.inherit: false
                    color: Qt.lighter(Kirigami.Theme.alternateBackgroundColor, 1.2)
                    border.color: Qt.lighter(Kirigami.Theme.alternateBackgroundColor, 1.8)

                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        Kirigami.Theme.colorSet: Kirigami.Theme.Button
                        Kirigami.Theme.inherit: false
                        color: Qt.darker(Kirigami.Theme.focusColor, 1.8)
                        radius: parent.radius
                        border.color: Kirigami.Theme.focusColor
                        border.width: 1
                    }
                    Rectangle {
                        width: (sliderInput.value - sliderInput.min) / sliderInput.max * parent.width
                        height: parent.height
                        Kirigami.Theme.colorSet: Kirigami.Theme.Button
                        Kirigami.Theme.inherit: false
                        color: Kirigami.Theme.focusColor
                        radius: parent.radius
                    }
                }
                handle: Rectangle {
                    id: handle
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    implicitWidth: Kirigami.Units.gridUnit
                    implicitHeight: Kirigami.Units.gridUnit
                    radius: Kirigami.Units.gridUnit / 2

                    Kirigami.Theme.colorSet: Kirigami.Theme.Window
                    Kirigami.Theme.inherit: false
                    color: Kirigami.Theme.backgroundColor
                    border.color: slider.hovered || slider.focus ? Kirigami.Theme.focusColor : Qt.lighter(Kirigami.Theme.alternateBackgroundColor, 2.5)
                }
            }
            RowLayout {
                Controls.Label {
                    text: minLabel
                }
                Item {
                    Layout.fillWidth: true
                }
                Controls.Label {
                    text: maxLabel
                }
            }
        }
        ColumnLayout {
            Kirigami.Chip {
                id: sliderLabel
                Layout.topMargin: -4
                checked: false
                checkable: false
                text: Math.round(sliderInput.guiState * 100) / 100
                closable: false
            }
            Item {
                Layout.fillHeight: true
            }
        }

    }
}
