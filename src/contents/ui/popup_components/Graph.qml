import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import QtCharts 2.15
import org.kde.kirigami 2.20 as Kirigami
import com.tust.graphs 1.0

Item {
    id: graphDisplay

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    property string label: "Value";
    property string value;

    property int refreshInterval: 500; //refresh interval in milliseconds
    property double timeRange: 1; //time range to be shown in minutes

    Layout.margins: Kirigami.Units.largeSpacing

    onValueChanged: {
        chart.nextValue = value;
        //have a sliding "highest value" and "lowest value"
    }

    Timer {
        id: refreshTimer
        interval: graphDisplay.refreshInterval
        running: false
        repeat: true
        onTriggered: {
            dataHandler.update(graphData, chart.nextValue);
            //console.log("timer complete", label);
        }
    }

    GraphDataHandler {
        id: dataHandler
        maxQueueSize: graphDisplay.timeRange * 60 / (graphDisplay.refreshInterval / 1000.0)
        name: pnidElement.displayName
    }

    RowLayout {
        id: mainLayout
        ChartView {
            id: chart
            property double nextValue: 0;

            implicitWidth: 350
            implicitHeight: 200

            animationOptions: ChartView.NoAnimation
            antialiasing: true

            backgroundColor: "transparent"
            titleColor: Kirigami.Theme.textColor
            legend.color: Kirigami.Theme.textColor
            legend.labelColor: Kirigami.Theme.textColor
            legend.borderColor: Kirigami.Theme.textColor
            legend.visible: false //re-enable if/when I add other lines like set point and gui state to the graph
            dropShadowEnabled: false

            Component.onCompleted: {
                refreshTimer.running = true
            }

            ValueAxis {
                id: axisY
                min: 0
                max: 100
                color: Kirigami.Theme.textColor
                shadesVisible: false
                gridLineColor: Kirigami.Theme.disabledTextColor
                labelsColor: Kirigami.Theme.textColor
                labelsFont.weight: Font.Bold
            }

            ValueAxis {
                id: axisX
                min: dataHandler.rangeOffset
                max: graphDisplay.timeRange * 60 / (graphDisplay.refreshInterval / 1000.0) + dataHandler.rangeOffset
                color: Kirigami.Theme.textColor
                shadesVisible: false
                gridLineColor: Kirigami.Theme.disabledTextColor
                labelsVisible: false
            }

            LineSeries {
                id: graphData
                name: graphDisplay.label
                axisX: axisX
                axisY: axisY
                useOpenGL: true
            }
        }

    }

}
