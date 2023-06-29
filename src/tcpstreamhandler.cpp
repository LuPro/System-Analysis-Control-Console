#include "tcpstreamhandler.h"

TcpStreamHandler::TcpStreamHandler()
{
    QObject::connect(&backendServer, SIGNAL(newConnection()), this, SLOT(handleNewBackendConnection()));
    QObject::connect(&frontendServer, SIGNAL(newConnection()), this, SLOT(handleNewFrontendConnection()));
}

void TcpStreamHandler::start(const quint16 &port, const quint16 &forwardPort)
{
    if (!backendServer.listen(QHostAddress::Any, port))
    {
        std::cerr << "Couldn't start TCP Stream Server for backends" << std::endl;
    }
    if (!frontendServer.listen(QHostAddress::Any, forwardPort))
    {
        std::cerr << "Couldn't start TCP Stream Server for frontends" << std::endl;
    }
}

void TcpStreamHandler::connect(const QString &address, const quint16 &port)
{
    std::cout << "Connecting to server at address" << address.toStdString() << std::endl;
    clientSocket = new QTcpSocket();
    clientSocket->connectToHost(address, port);
    QObject::connect(clientSocket, &QTcpSocket::disconnected, this, &TcpStreamHandler::onForwardServerDisconnected);
    QObject::connect(clientSocket, &QTcpSocket::readyRead, this, &TcpStreamHandler::processForwardServerData);
    QByteArray protocolMessage("{\"protocol\": \"native\", \"version\": 0, \"name\": \"PnID Viewer Frontend\"}");
    //TODO: Replace this hardcoded name with something unique to the machine? kconfig?
    protocolMessage.append('\0');
    clientSocket->write(protocolMessage);
    clientSocket->waitForBytesWritten(3000);
}

void TcpStreamHandler::handleNewBackendConnection()
{
    QTcpSocket *socket = backendServer.nextPendingConnection();
    SocketWrapper wrappedSocket = SocketWrapper(socket);
    backendSockets.append(wrappedSocket);
    backendSocketVariants.append(QVariant::fromValue(wrappedSocket));
    if (!socket->isOpen())
    {
        //TODO: I have no idea if isOpen is the right check here
        std::cerr << "Couldn't open backend TCP Socket" << std::endl << std::flush;
        return;
    }
    emit connectedBackend();
    emit backendSocketsChanged();
    QObject::connect(socket, &QTcpSocket::disconnected, this, [this, socket](){ onBackendDisconnected(socket); });
    //QWebSocket::connect(&socket, &QWebSocket::error, this, &WebSocketHandler::onErrored);
    //error signal seems to be special, figure out later
    QObject::connect(socket, &QTcpSocket::readyRead, this, [this, socket](){ processBackendData(socket); });
}

void TcpStreamHandler::handleNewFrontendConnection()
{
    std::cout << "got new frontend connection" << std::endl;
    QTcpSocket *socket = frontendServer.nextPendingConnection();
    SocketWrapper wrappedSocket = SocketWrapper(socket);
    frontendSockets.append(wrappedSocket);
    frontendSocketVariants.append(QVariant::fromValue(wrappedSocket));
    if (!socket->isOpen())
    {
        //TODO: I have no idea if isOpen is the right check here
        std::cerr << "Couldn't open frontend TCP Socket" << std::endl << std::flush;
        return;
    }
    emit connectedFrontend();
    emit frontendSocketsChanged();
    QObject::connect(socket, &QTcpSocket::readyRead, this, [this, socket](){ processFrontendData(socket); });
}

void TcpStreamHandler::sendData(const DataPacket &packet)
{
    //std::cout << "sending data id: " << packet.m_id.toStdString() << " value: " << packet.m_value << std::endl << std::flush;
    for (uint16_t i = 0; i < backendSockets.length(); i++)
    {
        backendSockets[i].socket->write(packet.toByteArray(backendSockets[i].protocol));
    }

    for (uint16_t i = 0; i < backendSockets.length(); i++)
    {
        //I don't like having to iterate through the sockets twice, but I rather write all to buffer and then wait
        //then do so one after another
        backendSockets[i].socket->waitForBytesWritten(1000);
    }
}

void TcpStreamHandler::onBackendDisconnected(QTcpSocket *socket)
{
    uint16_t socketIndex = getSocketIndex(socket);
    backendSockets.removeAt(socketIndex);
    backendSocketVariants.removeAt(socketIndex);
    emit disconnected(backendSockets.count());
    emit backendSocketsChanged();
    std::cout << "Disconnected" << std::endl << std::flush;
}

void TcpStreamHandler::onForwardServerDisconnected()
{

}

void TcpStreamHandler::onFrontendDisconnected(QTcpSocket *socket)
{
    uint16_t socketIndex = getSocketIndex(socket);
    frontendSockets.removeAt(socketIndex);
    frontendSocketVariants.removeAt(socketIndex);
    emit disconnected(frontendSockets.count());
    emit frontendSocketsChanged();
    std::cout << "Disconnected" << std::endl << std::flush;
}

void TcpStreamHandler::onBackendErrored(QAbstractSocket::SocketError error)
{

}

void TcpStreamHandler::onForwardServerErrored(QAbstractSocket::SocketError error)
{

}

void TcpStreamHandler::onFrontendErrored(QAbstractSocket::SocketError error)
{

}

void TcpStreamHandler::processBackendData(QTcpSocket *socket)
{
    QString messageStr = socket->readAll();
    std::cout << "Got message: " << messageStr.toStdString() << std::endl << std::flush;
    //std::cout << "got message string: " << messageStr.toStdString() << std::endl << std::flush;
    //right now creating a JsonDocument object happens twice, once here and once in processData()
    //I'd like to not do that
    QJsonDocument message = QJsonDocument::fromJson(messageStr.toUtf8());
    uint16_t socketIndex = getSocketIndex(socket);

    //protocol detection
    if (message.object().value("protocol").toString() == "native")
    {
        backendSockets[socketIndex].protocol = MessageProtocol::native;
        std::cout << "Detected client with native messaging protocol" << std::endl;
        return;
    }
    else if (backendSockets.at(socketIndex).protocol == MessageProtocol::undefined)
    {
        //if we get a message in that has no defined protocol but didn't init with a header
        //assume it's a TUST backend. This is not very robust, but until we add a protocol
        //indicator to the TUST backends, this is the best I can do quickly.
        backendSockets[socketIndex].protocol = MessageProtocol::tust;
    }

    processData(messageStr, backendSockets[socketIndex].protocol);
}

void TcpStreamHandler::processForwardServerData()
{
    QString messageStr = clientSocket->readAll();
    std::cout << "Got forwarded message: " << messageStr.toStdString() << std::endl;
    processData(messageStr, MessageProtocol::native); //right now it's hardcoded that only native msg protocol can forward
}

void TcpStreamHandler::processFrontendData(QTcpSocket *socket)
{
    //just forward whatever was sent to this.sendData to treat it like a gui interaction of the own client
}

void TcpStreamHandler::processData(const QString &msg, const MessageProtocol &protocol)
{
    QJsonDocument message = QJsonDocument::fromJson(msg.toUtf8());

    //extracting data
    QJsonArray packetsJsonArray;
    if (protocol == MessageProtocol::native)
    {
        packetsJsonArray = message.object().value("packets").toArray();
    }
    else if (protocol == MessageProtocol::tust)
    {
        packetsJsonArray = message.object().value("states").toArray(); //I'm fairly sure this is not right
    }

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
    //todo: forward data to other connected frontends
    emit incomingData(packets);
    if (clientSocket == 0)
    {
        //only allow forwarding to other frontends if you are not already receiving forwarded data yourself
        //I don't want arbitrarily long "forward chains"
        forwardToFrontends(msg);
    }
}

void TcpStreamHandler::forwardToFrontends(const QString &msg)
{
    for (uint16_t i = 0; i < frontendSockets.length(); i++)
    {
        std::cout << "forwarding to socket: " << msg.toStdString() << std::endl;
        frontendSockets.at(i).socket->write(QByteArray(msg.toUtf8()).append('\0'));
        frontendSockets.at(i).socket->waitForBytesWritten(1000);
        //TODO: Ideally the waiting for written should happen after going through all sockets
    }
}

uint16_t TcpStreamHandler::getSocketIndex(const QTcpSocket *socket)
{
    for (uint16_t i = 0; i < backendSockets.length(); i++)
    {
        if (backendSockets.at(i).socket == socket)
        {
            return i;
        }
    }
    return -1;
}
