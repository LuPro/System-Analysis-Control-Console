#include "common.h"

QByteArray DataPacket::toString(const MessageProtocol &protocol) const
{
    switch (protocol)
    {
    case MessageProtocol::undefined:
        return QByteArray("Protocol not yet determined").append('\0');
    case MessageProtocol::native:
        return QByteArray(QString("{\"packets\": [{\"id\":\"%1\", \"value\":\"%2\"}]}")
                              .arg(m_id).arg(m_value).toUtf8()).append('\0');
    case MessageProtocol::tust:
        return QByteArray("TUST Protocol not implemented").append('\0');
    }
    return QByteArray("Unknown Protocol").append('\0');
}
