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
    Q_GADGET

public:
    QTcpSocket *socket;
    MessageProtocol protocol;

    inline SocketWrapper(QTcpSocket *socket = 0, const MessageProtocol &protocol = MessageProtocol::undefined)
        : socket(socket), protocol(protocol) {}
};

Q_DECLARE_METATYPE(SocketWrapper)

struct ConnectionStatus {
    bool positive;
    QString message;
};

class TcpStreamHandler : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantList backendSockets MEMBER backendSocketVariants NOTIFY backendSocketsChanged)
    Q_PROPERTY(QVariantList frontendSockets MEMBER backendSocketVariants NOTIFY frontendSocketsChanged)

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

    //backend is a hardware backend that serves data and consumes user input
    //frontend connections are other fronteds that connect to the own client and need data forwarded
    //forward server is another frontend that forwards data from backends to the own client.
    //forward server is only relevant for client mode (ie: clientSocket is connected to something)

    void onBackendDisconnected(QTcpSocket *socket);
    void onForwardServerDisconnected();
    void onFrontendDisconnected(QTcpSocket *socket);

    void onBackendErrored(QAbstractSocket::SocketError error);
    void onForwardServerErrored(QAbstractSocket::SocketError error);
    void onFrontendErrored(QAbstractSocket::SocketError error);

    void processBackendData(QTcpSocket *socket);
    void processForwardServerData();
    void processFrontendData(QTcpSocket *socket);

signals:
    void incomingData(const QVector<DataPacket> &packets);
    void disconnected(quint64 remainingConnectionCount);
    void connectedBackend(); //when a new backend connects
    void connectedFrontend(); //when a new frontend connects
    void connectedClientMode(); //when own client connects as client mode

    void backendSocketsChanged();
    void frontendSocketsChanged();

private:
    void processData(const QString &msg, const MessageProtocol &protocol);
    void forwardToFrontends(const QString &msg);

    uint16_t getSocketIndex(const QTcpSocket *socket);

    QTcpServer backendServer; //server handling backend connections
    QTcpServer frontendServer; //server handling frontend connections
    QVector<SocketWrapper> backendSockets; //list of connected backends
    QList<QVariant> backendSocketVariants; //list of connected backends as variants to pass to QML
    QVector<SocketWrapper> frontendSockets; //list of connected frontend clients
    QList<QVariant> frontendSocketVariants; //list of connected backends as variants to pass to QML
    QTcpSocket *clientSocket = 0; //socket for if this instance is in client mode itself
};

#endif // WEBSOCKETHANDLER_H
