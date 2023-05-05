#ifndef WEBSOCKETHANDLER_H
#define WEBSOCKETHANDLER_H

#include "QtWebSockets/QWebSocket"
#include "QTcpServer"
#include "QUrl"
#include "QDebug"
#include "QObject"
#include "QString"
#include "QVariantList"
#include "QVariant"
#include "iostream"

#include "QJsonDocument"
#include "QJsonObject"
#include "QJsonValue"
#include "QJsonArray"
#include "QJsonParseError"

struct ConnectionStatus {
    bool positive;
    QString message;
};

struct DataPacket {
    Q_GADGET

public:
    QString m_id;
    double m_value;

    Q_PROPERTY(QString id MEMBER m_id)
    Q_PROPERTY(double value MEMBER m_value)
};

Q_DECLARE_METATYPE(DataPacket)

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
    void incomingData(const QVariantList &packets);
    void disconnected(quint64 remainingConnectionCount);
    void connected();

private:
    QTcpServer server;
    QVector<QTcpSocket*> sockets;
};

#endif // WEBSOCKETHANDLER_H
