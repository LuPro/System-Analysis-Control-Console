#include "tcpstreamhandler.h"

TcpStreamHandler::TcpStreamHandler()
{
    connect(&server, SIGNAL(newConnection()), this, SLOT(handleNewConnection()));
}

void TcpStreamHandler::start(quint16 port)
{
    if (!server.listen(QHostAddress::Any, port))
    {
        std::cerr << "Couldn't start TCP Stream Server" << std::endl << std::flush;
    }
}

void TcpStreamHandler::handleNewConnection()
{
    //this currently only supports one connection and doesn't properly handle another second connection coming in
    QTcpSocket *socket = server.nextPendingConnection();
    sockets.append(socket);
    //std::cout << "got connection" << std::endl << std::flush;
    if (!socket->isOpen())
    {
        //TODO: I have no idea if isOpen is the right check here
        std::cerr << "Couldn't open TCP Socket" << std::endl << std::flush;
        return;
    }
    //socket->write("Hello backend\n");
    //socket->waitForBytesWritten(3000);

    //connect(socket, SIGNAL(connected()), this, SLOT(onConnected()));
    emit connected();
    connect(socket, &QTcpSocket::disconnected, this, [this, socket](){ onDisconnected(socket); });
    //QWebSocket::connect(&socket, &QWebSocket::error, this, &WebSocketHandler::onErrored);
    //error signal seems to be special, figure out later
    connect(socket, &QTcpSocket::readyRead, this, [this, socket](){ processData(socket); });
    //TODO: this feels sketchy. I'm passing the socket by value to the lambda, but are they still connected then?
    //like, is the socket in the QVector sockets still the same socket as the one passed to the lambda?
}

void TcpStreamHandler::sendData(const QString &id, const double &value)
{
    std::cout << "id: " << id.toStdString() << " value: " << value << std::endl << std::flush;
}

void TcpStreamHandler::onDisconnected(QTcpSocket *socket)
{
    sockets.removeAt(sockets.indexOf(socket));
    emit disconnected(sockets.count());
    std::cout << "Disconnected" << std::endl << std::flush;

}

void TcpStreamHandler::onErrored(QAbstractSocket::SocketError error)
{

}

void TcpStreamHandler::processData(QTcpSocket *socket)
{
    QString messageStr = socket->readAll();
    std::cout << "Got message: " << messageStr.toStdString() << std::endl << std::flush;
    QByteArray bArray("Got message");
    bArray.append('\0');
    socket->write(bArray);
    socket->waitForBytesWritten(3000);
    //std::cout << "got message string: " << messageStr.toStdString() << std::endl << std::flush;
    QJsonDocument message = QJsonDocument::fromJson(messageStr.toUtf8());
    QJsonArray packetsJsonArray = message.object().value("packets").toArray();
    //qDebug() << packetsJsonArray.count();

    QVector<DataPacket> packets;
    for (QJsonValueRef packetJson : packetsJsonArray)
    {
        DataPacket packet;
        QJsonObject object = packetJson.toObject();
        packet.m_id = object.value("name").toString();
        packet.m_value = object.value("value").toDouble();
        //std::cout << "packet: " << packet.m_id.toStdString() << ": " << packet.m_value << std::endl << std::flush;
        packets.append(packet);
    }

    std::cout << "emitting packets" << std::endl << std::flush;
    emit incomingData(packets);
}
