#ifndef PNIDHANDLER_H
#define PNIDHANDLER_H

#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QObject>
#include <QPointer>
#include <QString>
#include <QUrl>
#include <QFileInfo>
#include <QQuickItem>
#include <iostream>

#include "common.h"

class Pnid : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString name MEMBER name NOTIFY nameChanged)
    Q_PROPERTY(QUrl filePath MEMBER filePath NOTIFY filePathChanged)

public:
    Pnid(const QString &name, const QUrl &filePath);

    QString name;
    QUrl filePath;
    QObject *pnid;

signals:
    //these signals are not intended to ever be used as these properties are meant to
    //be static, but otherwise I'm getting warnings
    void nameChanged();
    void filePathChanged();
};

class PnidHandler : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVector<Pnid*> pnids MEMBER pnids NOTIFY pnidsUpdated)

public:
    PnidHandler(QQmlApplicationEngine *engine, QString appPath);


public slots:
    void loadPnids(QVariant pnidContainerVariant);

    void registerPnid(QVariant pnidVariant);

    void processPackets(const QVector<DataPacket> &packets);

    void handleUserInput(const QString &id, const double &value);

signals:

    void pnidsUpdated();

    void userInput(const DataPacket &packet);

private:
    QObject *pnidContainer;
    QObject *pnidTabs;

    QQmlApplicationEngine *engine;
    QString appPath;

    QObject *pnidRoot;
    QVector<Pnid*> pnids;
};

#endif // PNIDHANDLER_H
