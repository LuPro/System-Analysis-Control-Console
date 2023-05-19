#ifndef WEBSOCKETHANDLER_H
#define WEBSOCKETHANDLER_H

#include <QtWebSockets/QWebSocket>
#include <QTcpServer>
#include <QUrl>
#include <QDebug>
#include <QObject>
#include <QString>
#include <iostream>

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonParseError>

#include "common.h"

struct ConnectionStatus {
    bool positive;
    QString message;
};

class TcpStreamHandler : public QObject
{
    Q_OBJECT

public:
    TcpStreamHandler();

public slots:
    void start(quint16 port = 3000);

    void sendData(const QString &id, const double &value);

private slots:
    void handleNewConnection();

    void onDisconnected(QTcpSocket *socket);
    void onErrored(QAbstractSocket::SocketError error);
    void processData(QTcpSocket *socket);

signals:
    void incomingData(const QVector<DataPacket> &packets);
    void disconnected(quint64 remainingConnectionCount);
    void connected();

private:
    QTcpServer server;
    QVector<QTcpSocket*> sockets;
};

#endif // WEBSOCKETHANDLER_H
