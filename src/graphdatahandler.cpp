#include "graphdatahandler.h"

#include <QtCharts/QLineSeries>
#include <QtCharts/QSplineSeries>
#include <QDebug>

Q_DECLARE_METATYPE(QtCharts::QAbstractSeries *)

GraphDataHandler::GraphDataHandler(QObject *parent)
    : QObject{parent}
{
    qRegisterMetaType<QtCharts::QAbstractSeries*>();
}

void GraphDataHandler::update(QtCharts::QAbstractSeries *series, const double &data)
{
    if (series)
    {
        QtCharts::QLineSeries *lineSeries = static_cast<QtCharts::QLineSeries *>(series);

        int currentQueueSize = dataQueue.size();
        //std::cout << "queue size before: " << currentQueueSize << std::endl << std::flush;
        dataQueue.enqueue(QPointF(packetNumber, data)); //enqueues to tail
        packetNumber++;
        //std::cout << "queue size after: " << currentQueueSize << std::endl << std::flush;
        //if (name == "Mock Server MyVar")
        //    qDebug() << dataQueue;
        if (currentQueueSize > maxQueueSize)
        {
            //this assumes it is only ever 1 above queue size
            dataQueue.dequeue(); //dequeues from head
            rangeOffset++;
            emit rangeOffsetChanged();
        }

        lineSeries->replace(dataQueue);
    }
}
