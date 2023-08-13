#ifndef PNIDHANDLER_H
#define PNIDHANDLER_H

#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QObject>
#include <QPointer>
#include <QString>
#include <QUrl>
#include <QMultiMap>
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

    //TODO: have this take a list of sub IDs and not just one (maybe as an override? how does that work with QML?)
    void registerSubObject(const QString &parentId, const QString &subId);

signals:

    void pnidsUpdated();

    void userInput(const DataPacket &packet);

private:
    //TODO: this only returns one object, at some point I'd want to handle several to allow duplicate IDs?
    //Maybe I don't and require the IDs to actually be unique -> then I'd need a way to forward from one to another
    //I think.
    QObject *findSubObjectParent(const int &activePnid, const QString &id);

    QObject *pnidContainer;
    QObject *pnidTabs;

    QQmlApplicationEngine *engine;
    QString appPath;

    QObject *pnidRoot;
    QVector<Pnid*> pnids;

    QMultiMap<QString, QString> subObjects;
};

#endif // PNIDHANDLER_H
