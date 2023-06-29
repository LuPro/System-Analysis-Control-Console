#ifndef COMMON_H
#define COMMON_H

#include <QObject>
#include <QString>

enum MessageProtocol {
    undefined,
    native,
    tust
};

class DataPacket {
    Q_GADGET
    Q_PROPERTY(QString id MEMBER m_id)
    Q_PROPERTY(double value MEMBER m_value)

public:
    inline DataPacket(QString id = "", double value = 0) : m_id(id), m_value(value) {}
    QByteArray toByteArray(const MessageProtocol &protocol) const;

    QString m_id;
    double m_value;
};

#endif // COMMON_H
