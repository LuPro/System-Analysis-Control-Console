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

enum SocketType {
    backendSocket,
    frontendSocket
};

class SocketWrapper {
    Q_GADGET
    Q_PROPERTY (QString name MEMBER name)

public:
    QTcpSocket *socket;
    MessageProtocol protocol;
    QString name;

    inline SocketWrapper(QTcpSocket *socket = 0,
                         const MessageProtocol &protocol = MessageProtocol::undefined,
                         const QString &name = "name_unknown")
        : socket(socket), protocol(protocol), name(name) {}

    inline bool operator=(const SocketWrapper &socketWrapper) {
        if (socket == socketWrapper.socket && protocol == socketWrapper.protocol && name == socketWrapper.name)
        {
            return true;
        }
        return false;
    };
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
    Q_PROPERTY(QVariantList frontendSockets MEMBER frontendSocketVariants NOTIFY frontendSocketsChanged)
    Q_PROPERTY(bool exclusiveControl MEMBER exclusiveControl NOTIFY exclusiveControlChanged)

public:
    explicit TcpStreamHandler(QObject *parent = nullptr);

public slots:
    void start(const quint16 &port = 3000, const quint16 &forwardPort = 3003);

    void connect(const QString &address, const quint16 &port);

    //TODO: Consider renaming to sendDataToBackends()
    void sendData(const DataPacket &packet);

    inline bool isClientMode() {
        return clientSocket ? true : false;
    }

    inline void setExclusiveControl(const bool &exclusiveControl) {
        this->exclusiveControl = exclusiveControl;
        forwardExclusiveControl();
        emit exclusiveControlChanged();
        std::cout << "exclusive control changed" << exclusiveControl << std::endl;
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

    /*void onBackendErrored(QAbstractSocket::SocketError error);
    void onForwardServerErrored(QAbstractSocket::SocketError error);
    void onFrontendErrored(QAbstractSocket::SocketError error);*/

    //backend -> [frontend]
    void processBackendData(QTcpSocket *socket);
    //forward server -> [frontend]
    void processForwardServerData();
    //frontend -> [forward server]
    void processFrontendData(QTcpSocket *socket);

signals:
    void incomingData(const QVector<DataPacket> &packets);
    void frontendDisconnected(quint64 remainingConnectionCount);
    void backendDisconnected(quint64 remainingConnectionCount);
    void connectedBackend(); //when a new backend connects
    void connectedFrontend(); //when a new frontend connects
    void connectedClientMode(); //when own client connects as client mode

    void backendSocketsChanged();
    void frontendSocketsChanged();

    void exclusiveControlChanged();

private:
    //parse byte array to packet
    QVector<DataPacket> parseData(const QString &msg, const MessageProtocol &protocol);
    //parse packet type field from json into enum
    PacketType parsePacketType(const QString &packetTypeStr);

    //whether or not the main client has exclusive control or others can also send inputs
    //if clientSocket != 0 and exclusiveControl == true -> no pnid inputs allowed
    bool exclusiveControl = false;
    //notifies other connected frontends if exlusive control setting changed
    void forwardExclusiveControl(const SocketWrapper *socket = 0);
    void forwardToFrontends(const QString &msg);

    uint16_t getSocketIndex(const SocketType &socketType, const QTcpSocket *socket);

    QTcpServer backendServer; //server handling backend connections
    QTcpServer frontendServer; //server handling frontend connections
    QVector<SocketWrapper> backendSockets; //list of connected backends
    QVariantList backendSocketVariants; //list of connected backends as variants to pass to QML
    QVector<SocketWrapper> frontendSockets; //list of connected frontend clients
    QVariantList frontendSocketVariants; //list of connected backends as variants to pass to QML
    QTcpSocket *clientSocket = 0; //socket for if this instance is in client mode itself
};

#endif // WEBSOCKETHANDLER_H
