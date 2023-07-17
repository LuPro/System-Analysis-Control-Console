#ifndef COMMON_H
#define COMMON_H

#include <QObject>
#include <QString>

enum MessageProtocol {
    undefined,
    native,
    tust
};

enum PacketType {
    feedback,
    guiState,
    hardwareState
};

class DataPacket {
    Q_GADGET

    Q_ENUM(PacketType)

    Q_PROPERTY(QString id MEMBER m_id)
    Q_PROPERTY(double value MEMBER m_value)
    Q_PROPERTY(PacketType packetType MEMBER m_packetType)

public:
    inline DataPacket(QString id = "", double value = 0, PacketType packetType = PacketType::feedback)
        : m_id(id), m_value(value), m_packetType(packetType) {}
    QByteArray toByteArray(const MessageProtocol &protocol) const;

    QString m_id;
    double m_value;
    PacketType m_packetType;
};

#endif // COMMON_H
