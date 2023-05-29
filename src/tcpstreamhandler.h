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

struct SocketWrapper {
    QTcpSocket *socket;
    MessageProtocol protocol;

public:
    inline SocketWrapper(QTcpSocket *socket, const MessageProtocol &protocol)
        : socket(socket), protocol(protocol) {}
};

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

    void sendData(const DataPacket &packet);

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
    QVector<SocketWrapper> sockets;
};

#endif // WEBSOCKETHANDLER_H
