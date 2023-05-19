#ifndef COMMON_H
#define COMMON_H

#include <QObject>
#include <QString>

class DataPacket {
    Q_GADGET
    Q_PROPERTY(QString id MEMBER m_id)
    Q_PROPERTY(double value MEMBER m_value)

public:
    QString m_id;
    double m_value;
};

#endif // COMMON_H
