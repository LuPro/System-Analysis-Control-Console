#include "pnidhandler.h"

Pnid::Pnid(const QString &name, const QUrl &filePath)
    : name(name), filePath(filePath)
{
    //TODO: This shouldn't be hardcoded, but set by the default in UI
    //maybe default to some value like -1 that tells the UI to set the actual default
    //in case many pnids get loaded at once
    zoomScale = 5;
}

PnidHandler::PnidHandler(QQmlApplicationEngine *engine, QString pnidPath)
    : engine(engine), pnidPath(pnidPath)
{

}

void PnidHandler::loadPnids(QVariant pnidContainerVariant)
{
    pnidContainer = pnidContainerVariant.value<QObject*>();
    QFileInfoList pnidFiles = findPnidFiles(pnidPath);

    for (int i = 0; i < pnidFiles.length(); i++)
    {
        Pnid *pnid = new Pnid(pnidFiles.at(i).completeBaseName(), QUrl::fromLocalFile(pnidFiles.at(i).filePath()));
        pnids.append(pnid);
    }

    emit pnidsUpdated();
}

void PnidHandler::registerPnid(QVariant pnidVariant)
{
    //TODO: still needs a "deregister" for when a pnid gets closed (more likely: all pnids get closed)
    QObject *pnidObject = pnidVariant.value<QObject*>();
    QQmlEngine::setObjectOwnership(pnidObject, QQmlEngine::CppOwnership);

    QString pnidName = pnidObject->objectName();
    for (uint16_t i = 0; i < pnids.length(); i++)
    {
        if (pnids.at(i)->name == pnidName)
        {
            pnids[i]->pnid = pnidObject;
        }
    }
}

void PnidHandler::setActivePnid(const int &newActivePnid)
{
    activePnid = newActivePnid;
    currentZoom = pnids.at(newActivePnid)->zoomScale;
    emit currentZoomChanged();
}

void PnidHandler::processPackets(const QVector<DataPacket> &packets)
{
    for (const DataPacket &packet : packets)
    {
        //std::cout << "packet! id: " << packet.m_id.toStdString() << ", value: " << packet.m_value << std::endl;
        int activePnid = pnidContainer->property("currentIndex").toInt();
        //right now I'm only updating the currently visible pnid, this should be a setting somewhere I think
        QObject *pnidElement = pnids.at(activePnid)->pnid->findChild<QObject*>(packet.m_id);
        //std::cout << "trying to find packet in pnid: " << activePnid << std::endl;
        bool isSubObject = false;
        if (!pnidElement)
        {
            pnidElement = findSubObjectParent(activePnid, packet.m_id);
            isSubObject = true;
            if (!pnidElement)
            {
                //todo: this is a somewhat expected occurence, we don't need a message for this forever
                std::cout << "Couldn't find PnID element with id: " << packet.m_id.toStdString() << std::endl << std::flush;
                continue;
            }
        }
        switch(packet.m_packetType)
        {
            case PacketType::feedback:
                std::cout << "sending a feedback value" << std::endl;
                if (!isSubObject)
                {
                    pnidElement->setProperty("value", packet.m_value);
                }
                else
                {
                    QMetaObject::invokeMethod(pnidElement, "setSubObjectValue",
                                              Q_ARG(QString, packet.m_id),
                                              Q_ARG(double, packet.m_value));
                }
                break;
            case PacketType::guiState:
                std::cout << "sending a gui state" << std::endl;
                if (!isSubObject)
                {
                    pnidElement->setProperty("guiState", packet.m_value);
                }
                else
                {
                    QMetaObject::invokeMethod(pnidElement, "setSubObjectGuiState",
                                              Q_ARG(QString, packet.m_id),
                                              Q_ARG(double, packet.m_value));
                }
                break;
            case PacketType::hardwareState:
                std::cout << "sending a hardware state" << std::endl;
                if (!isSubObject)
                {
                    pnidElement->setProperty("setState", packet.m_value);
                }
                else
                {
                    QMetaObject::invokeMethod(pnidElement, "setSubObjectSetState",
                                              Q_ARG(QString, packet.m_id),
                                              Q_ARG(double, packet.m_value));
                }
                break;
            default:
                std::cerr << "Encountered unknown packet type: " << packet.m_packetType << std::endl;
                break;
        }
    }
}

void PnidHandler::handleUserInput(const QString &id, const double &value)
{
    std::cout << "Got user input" << std::endl;
    emit userInput(DataPacket(id, value, PacketType::guiState));
}

void PnidHandler::registerSubObject(const QString &parentId, const QString &subId)
{
    if (subObjects.contains(subId))
    {
        QList<QString> parentIds = subObjects.values();
        if (!parentIds.contains(parentId)) {
            subObjects.insert(subId, parentId);
        }
    }
    else
    {
        subObjects.insert(subId, parentId);
    }
}

int PnidHandler::getCurrentZoom()
{
    std::cout << "getting zoom: " << activePnid << std::endl;
    return pnids.at(activePnid)->zoomScale;
}

void PnidHandler::setCurrentZoom(const int &zoom)
{
    //TODO: Theoretically this could be called from UI before the pnids are instantiated
    //leading to an index out of range error and crash. Not sure if I should catch this here
    //or leave it "broken" because otherwise the UI would need more complex code to "retry" setting
    //and no user should be able to interact this quickly anyways. leaving it broken shows better
    //if the UI is doing something wrong.
    //TODO: Maybe this is properly fixed now? It seems it was an issue of the active pnid being set after
    //the zoom level, not the zoom level being set/queried before pnid were added to the pnid list
    std::cout << "setting zoom: " << activePnid << std::endl;
    pnids.at(activePnid)->zoomScale = zoom;
    emit currentZoomChanged();
}

QFileInfoList PnidHandler::findPnidFiles(const QString &basePath)
{
    QDir directory(basePath);
    QFileInfoList pnids = directory.entryInfoList(QStringList() << "*.qml", QDir::Files | QDir::NoDotAndDotDot);
    return pnids;
}

QObject *PnidHandler::findSubObjectParent(const int &activePnid, const QString &id)
{
    QList parentIds = subObjects.values(id);
    if (parentIds.length() == 0)
    {
        return nullptr;
    }
    QString parentId = subObjects.values(id).at(0);
    return pnids.at(activePnid)->pnid->findChild<QObject*>(parentId);
}
