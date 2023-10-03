#include "tcpstreamhandler.h"

#include "config.h"

TcpStreamHandler::TcpStreamHandler(QObject *parent)
    : QObject{parent}
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
    std::cout << "Connecting to server at address: " << address.toStdString() << std::endl;
    clientSocket = new QTcpSocket();
    clientSocket->connectToHost(address, port);
    //TODO: check whether connection succeeded
    QObject::connect(clientSocket, &QTcpSocket::disconnected, this, &TcpStreamHandler::onForwardServerDisconnected);
    QObject::connect(clientSocket, &QTcpSocket::readyRead, this, &TcpStreamHandler::processForwardServerData);

    Config *config = Config::self();
    QString messageStr = "{\"protocol\": \"native\", \"version\": 0, \"name\": \"" + config->clientName() + "\"}";
    QByteArray protocolMessage(messageStr.toStdString().c_str());
    protocolMessage.append('\0');
    clientSocket->write(protocolMessage);
    clientSocket->waitForBytesWritten(3000);
    isPrimary = false;
    emit isPrimaryChanged();
}

void TcpStreamHandler::handleNewBackendConnection()
{
    QTcpSocket *socket = backendServer.nextPendingConnection();
    SocketWrapper wrappedSocket(socket);
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
    SocketWrapper wrappedSocket(socket);
    frontendSockets.append(wrappedSocket);
    frontendSocketVariants.append(QVariant::fromValue(wrappedSocket));
    if (!socket->isOpen())
    {
        //TODO: I have no idea if isOpen is the right check here
        std::cerr << "Couldn't open frontend TCP Socket" << std::endl << std::flush;
        return;
    }
    forwardExclusiveControl(&wrappedSocket);
    emit connectedFrontend();
    emit frontendSocketsChanged();
    std::cout << "frontend socket number: " << frontendSocketVariants.length() << std::endl;
    QObject::connect(socket, &QTcpSocket::disconnected, this, [this, socket](){ onFrontendDisconnected(socket); });
    QObject::connect(socket, &QTcpSocket::readyRead, this, [this, socket](){ processFrontendData(socket); });
}

void TcpStreamHandler::sendData(const DataPacket &packet)
{
    if (clientSocket)
    {
        std::cout << "sending to forward server" << packet.toByteArray(MessageProtocol::native).toStdString() << std::endl;
        //if we're in client mode, send it over the client socket
        clientSocket->write(packet.toByteArray(MessageProtocol::native));
        clientSocket->waitForBytesWritten(1000);
    }
    else
    {
        //if we're the main client, send it to all backends
        std::cout << "sending data id: " << packet.m_id.toStdString() << " value: " << packet.m_value << " type: " << packet.m_packetType << std::endl << std::flush;
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

        //and also to all connected frontends so they can mimic the gui state
        for (uint16_t i = 0; i < frontendSockets.length(); i++)
        {
            std::cout << "forwarding user input: " << packet.toByteArray(frontendSockets[i].protocol).toStdString() << std::endl;
            frontendSockets[i].socket->write(packet.toByteArray(frontendSockets[i].protocol));
        }

        for (uint16_t i = 0; i < frontendSockets.length(); i++)
        {
            //I don't like having to iterate through the sockets twice, but I rather write all to buffer and then wait
            //then do so one after another
            frontendSockets[i].socket->waitForBytesWritten(1000);
        }
    }
}

void TcpStreamHandler::onBackendDisconnected(QTcpSocket *socket)
{
    uint16_t socketIndex = getSocketIndex(SocketType::backendSocket, socket);
    backendSockets.removeAt(socketIndex);
    backendSocketVariants.removeAt(socketIndex);
    emit backendDisconnected(backendSockets.count());
    emit backendSocketsChanged();
    std::cout << "Disconnected" << std::endl << std::flush;
}

void TcpStreamHandler::onForwardServerDisconnected()
{

}

void TcpStreamHandler::onFrontendDisconnected(QTcpSocket *socket)
{
    uint16_t socketIndex = getSocketIndex(SocketType::frontendSocket, socket);
    frontendSockets.removeAt(socketIndex);
    frontendSocketVariants.removeAt(socketIndex);
    emit frontendDisconnected(frontendSockets.count());
    emit frontendSocketsChanged();
    std::cout << "Disconnected" << std::endl << std::flush;
}

/*void TcpStreamHandler::onBackendErrored(QAbstractSocket::SocketError error)
{

}

void TcpStreamHandler::onForwardServerErrored(QAbstractSocket::SocketError error)
{

}

void TcpStreamHandler::onFrontendErrored(QAbstractSocket::SocketError error)
{

}*/

void TcpStreamHandler::processBackendData(QTcpSocket *socket)
{
    QString messageStr = socket->readAll();
    std::cout << "Got message: " << messageStr.toStdString() << std::endl << std::flush;
    //std::cout << "got message string: " << messageStr.toStdString() << std::endl << std::flush;
    //right now creating a JsonDocument object happens twice, once here and once in processData()
    //I'd like to not do that
    QJsonDocument message = QJsonDocument::fromJson(messageStr.toUtf8());
    uint16_t socketIndex = getSocketIndex(SocketType::backendSocket, socket);

    //protocol detection
    if (message.object().value("protocol").toString() == "native")
    {
        backendSockets[socketIndex].protocol = MessageProtocol::native;
        backendSockets[socketIndex].name = message.object().value("name").toString();
        backendSocketVariants[socketIndex] = QVariant::fromValue(backendSockets[socketIndex]);
        emit backendSocketsChanged();
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

    QVector<DataPacket> packets = parseData(messageStr, backendSockets[socketIndex].protocol);
    emit incomingData(packets);
    forwardToFrontends(messageStr);
}

void TcpStreamHandler::processForwardServerData()
{
    QString messageStr = clientSocket->readAll();
    std::cout << "Got forwarded message: " << messageStr.toStdString() << std::endl;
    //right now it's hardcoded that only native msg protocol can forward

    QJsonDocument message = QJsonDocument::fromJson(messageStr.toUtf8());
    if (message.object().value("exclusiveControl").isUndefined() == false)
    {
        exclusiveControl = message.object().value("exclusiveControl").toBool();
        emit exclusiveControlChanged();
        std::cout << "Changed exclusive control mode to: " << exclusiveControl << std::endl;
        return;
    }

    QVector<DataPacket> packets = parseData(messageStr, MessageProtocol::native);
    emit incomingData(packets);
}

void TcpStreamHandler::processFrontendData(QTcpSocket *socket)
{
    std::cout << "got data from frontend: ";
    QString messageStr = socket->readAll();
    std::cout << messageStr.toStdString() << std::endl;

    QJsonDocument message = QJsonDocument::fromJson(messageStr.toUtf8());
    uint16_t socketIndex = getSocketIndex(SocketType::frontendSocket, socket);
    if (message.object().value("protocol").toString() == "native")
    {
        //TODO: frontend data connection only supports native protocol for now
        frontendSockets[socketIndex].protocol = MessageProtocol::native;
        frontendSockets[socketIndex].name = message.object().value("name").toString();
        frontendSocketVariants[socketIndex] = QVariant::fromValue(frontendSockets[socketIndex]);
        emit frontendSocketsChanged();
        std::cout << "Detected frontend client with native messaging protocol" << std::endl;
        return;
    }

    if (exclusiveControl == false)
    {
        QVector<DataPacket> packets = parseData(messageStr, MessageProtocol::native);
        //right now it's hardcoded that only native msg protocol can be received from forward
        for (int i = 0; i < packets.length(); i++)
        {
            //TODO: having a variant of sendData that can send more than one packet would be beneficial
            //for now in this direction there's only one packet sent anyways
            sendData(packets.at(i));
        }
        emit incomingData(packets);
    }
}

QVector<DataPacket> TcpStreamHandler::parseData(const QString &msg, const MessageProtocol &protocol)
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
        packet.m_packetType = object.value("packetType").isUndefined() ?
                                  PacketType::feedback :
                                  PacketType(object.value("packetType").toInt());
        std::cout << "packet type: " << packet.m_packetType << std::endl;
        //std::cout << "packet: " << packet.m_id.toStdString() << ": " << packet.m_value << std::endl << std::flush;
        packets.append(packet);
    }

    //std::cout << "emitting packets" << std::endl << std::flush;
    return packets;
}

PacketType TcpStreamHandler::parsePacketType(const QString &packetTypeStr)
{
    if (packetTypeStr == "feedback")
    {
        return PacketType::feedback;
    }
    else if (packetTypeStr == "guiState")
    {
        return PacketType::guiState;
    }
    else if (packetTypeStr == "hardwareState")
    {
        return PacketType::hardwareState;
    }
    //default to feedback/sensor value as that will be most of the data
    return PacketType::feedback;
}

void TcpStreamHandler::forwardExclusiveControl(const SocketWrapper *socket)
{
    if (socket)
    {
        //only send to a specific connected frontend
        if (socket->protocol == MessageProtocol::native)
        {
            QByteArray exclusiveControlMsg(
                QString("{\"exclusiveControl\": %1}").arg(exclusiveControl ? "true" : "false").toUtf8()
            );
            exclusiveControlMsg.append('\0');
            socket->socket->write(exclusiveControlMsg);
            socket->socket->waitForBytesWritten(1000);
        }
    }
    else
    {
        //send to all frontends
        for (uint16_t i = 0; i < frontendSockets.length(); i++)
        {
            if (frontendSockets.at(i).protocol == MessageProtocol::native)
            {
                QByteArray exclusiveControlMsg(
                    QString("{\"exclusiveControl\": %1}").arg(exclusiveControl ? "true" : "false").toUtf8()
                );
                exclusiveControlMsg.append('\0');
                frontendSockets.at(i).socket->write(exclusiveControlMsg);
                frontendSockets.at(i).socket->waitForBytesWritten(1000);
            }
        }
    }
}

void TcpStreamHandler::forwardToFrontends(const QString &msg)
{
    if (clientSocket == 0)
    {
        //only allow forwarding to other frontends if you are not already receiving forwarded data yourself
        //I don't want arbitrarily long "forward chains"
        for (uint16_t i = 0; i < frontendSockets.length(); i++)
        {
            std::cout << "forwarding to socket: " << msg.toStdString() << std::endl;
            frontendSockets.at(i).socket->write(QByteArray(msg.toUtf8()).append('\0'));
            frontendSockets.at(i).socket->waitForBytesWritten(1000);
            //TODO: Ideally the waiting for written should happen after going through all sockets
        }
    }
}

uint16_t TcpStreamHandler::getSocketIndex(const SocketType &socketType, const QTcpSocket *socket)
{
    switch (socketType)
    {
        case SocketType::backendSocket:
            for (uint16_t i = 0; i < backendSockets.length(); i++)
            {
                if (backendSockets.at(i).socket == socket)
                {
                    return i;
                }
            }
            break;
        case SocketType::frontendSocket:
            for (uint16_t i = 0; i < frontendSockets.length(); i++)
            {
                if (frontendSockets.at(i).socket == socket)
                {
                    return i;
                }
            }
            break;
    }
    return -1;
}
