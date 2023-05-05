#ifndef PNIDHANDLER_H
#define PNIDHANDLER_H

#include <QQmlApplicationEngine>
#include <QObject>

class PnidHandler : public QObject
{
    Q_OBJECT

public:
    PnidHandler();

signals:

private:
    QQmlApplicationEngine *engine;
};

#endif // PNIDHANDLER_H
