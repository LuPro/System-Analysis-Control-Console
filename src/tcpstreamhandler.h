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
    inline SocketWrapper(QTcpSocket *socket, const MessageProtocol &protocol = MessageProtocol::undefined)
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
    void start(const quint16 &port = 3000, const quint16 &forwardPort = 3003);

    void connect(const QString &address, const quint16 &port);

    void sendData(const DataPacket &packet);

    inline bool isClientMode() {
        return clientSocket ? true : false;
    }

private slots:
    void handleNewBackendConnection();
    void handleNewFrontendConnection();

    void onBackendDisconnected(QTcpSocket *socket);
    void onFrontendDisconnected(QTcpSocket *socket);

    void onBackendErrored(QAbstractSocket::SocketError error);
    void onFrontendErrored(QAbstractSocket::SocketError error);

    void processBackendData(QTcpSocket *socket);
    void processFrontendData(QTcpSocket *socket);

signals:
    void incomingData(const QVector<DataPacket> &packets);
    void disconnected(quint64 remainingConnectionCount);
    void connectedBackend(); //when a new backend connects
    void connectedFrontend(); //when a new frontend connects
    void connectedClientMode(); //when own client connects as client mode

private:
    uint16_t getSocketIndex(const QTcpSocket *socket);

    QTcpServer backendServer; //server handling backend connections
    QTcpServer frontendServer; //server handling frontend connections
    QVector<SocketWrapper> backendSockets; //list of connected backends
    QVector<SocketWrapper> frontendSockets; //list of connected frontend clients
    QTcpSocket *clientSocket = 0; //socket for if this instance is in client mode itself
};

#endif // WEBSOCKETHANDLER_H
