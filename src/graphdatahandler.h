#ifndef GRAPHDATAHANDLER_H
#define GRAPHDATAHANDLER_H

#include <QObject>
#include <QtCharts/QAbstractSeries>
#include <QQueue>
#include <QPointF>
#include <iostream>

class GraphDataHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int maxQueueSize MEMBER maxQueueSize)
    Q_PROPERTY(int rangeOffset MEMBER rangeOffset NOTIFY rangeOffsetChanged)
    Q_PROPERTY(QString name MEMBER name)

public:
    explicit GraphDataHandler(QObject *parent = nullptr);

signals:
    void rangeOffsetChanged();

public slots:
    void update(QtCharts::QAbstractSeries *series, const double &data);

private:
    QQueue<QPointF> dataQueue;
    int maxQueueSize;
    int packetNumber = 0;
    int rangeOffset = 0;
    QString name;
};

#endif // GRAPHDATAHANDLER_H
