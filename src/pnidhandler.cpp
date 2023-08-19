#include "pnidhandler.h"

Pnid::Pnid(const QString &name, const QUrl &filePath)
    : name(name), filePath(filePath)
{
    //TODO: This shouldn't be hardcoded, but set by the default in UI
    //maybe default to some value like -1 that tells the UI to set the actual default
    //in case many pnids get loaded at once
    zoomScale = 5;
}

PnidHandler::PnidHandler(QQmlApplicationEngine *engine, QString appPath)
    : engine(engine), appPath(appPath)
{
    /*this->pnidRoot = rootObject->findChild<QObject *>("pnidTabsContainer");
    if (!pnidRoot)
    {
        std::cout << "could not find pnid root" << std::endl;
    }*/
    std::cout << this->appPath.toStdString() << std::endl << std::flush;
}

void iterateQmlObjectChildren(QObject *object)
{
    const QObjectList children = object->children();
    for (QObject *child : children) {
        if (object->objectName().length() > 0 || true)
        {
            std::cout << "Object Name: " << object->objectName().toStdString() << std::endl;
            std::cout << "Object Class: " << object->metaObject()->className() << std::endl << std::endl << std::flush;
        }
        iterateQmlObjectChildren(child);
    }
}

void printQmlEngineChildren(QQmlApplicationEngine *engine)
{
    QList<QObject*> rootObjects = engine->rootObjects();
    std::cout << "root objects: " << rootObjects.size() << std::endl << std::flush;
    iterateQmlObjectChildren(rootObjects.at(0));
}

void PnidHandler::loadPnids(QVariant pnidContainerVariant)
{
    pnidContainer = pnidContainerVariant.value<QObject*>();
    QString pnidBasePath = this->appPath + "/contents/ui/pnids/";
    QFileInfo pnidTest(pnidBasePath + "pnidTest.qml");
    Pnid *pnid = new Pnid(pnidTest.completeBaseName(), QUrl::fromLocalFile(pnidTest.filePath()));
    pnids.append(pnid);
    QFileInfo pnidTest2(pnidBasePath + "other_pnid.qml");
    Pnid *pnid2 = new Pnid(pnidTest2.completeBaseName(), QUrl::fromLocalFile(pnidTest2.filePath()));
    pnids.append(pnid2);
    //TODO: file discovery and loading the number of found files. just append more to pnids vector to load more tabs

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
        std::cout << "packet! id: " << packet.m_id.toStdString() << ", value: " << packet.m_value << std::endl;
        int activePnid = pnidContainer->property("currentIndex").toInt();
        //right now I'm only updating the currently visible pnid, this should be a setting somewhere I think
        QObject *pnidElement = pnids.at(activePnid)->pnid->findChild<QObject*>(packet.m_id);
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
    return pnids.at(activePnid)->zoomScale;
}

void PnidHandler::setCurrentZoom(const int &zoom)
{
    pnids.at(activePnid)->zoomScale = zoom;
    emit currentZoomChanged();
}

/*void PnidHandler::pnidZoomStep(const int &direction)
{
    std::cout << "zoom: " << direction << std::endl;
    //TODO: The length of the combo box list should not be hardcoded here
    int newZoom = 0;
    if (direction)
    {
        newZoom = pnids.at(activePnid)->zoomScale + 1;
    }
    else
    {
        newZoom = pnids.at(activePnid)->zoomScale - 1;
    }
    newZoom = qBound(0, newZoom, 11);
    pnids.at(activePnid)->zoomScale = newZoom;
    currentZoom = newZoom;
    std::cout << "current zoom: " << currentZoom << std::endl;
    emit currentZoomChanged(currentZoom);
}*/

/*void PnidHandler::pnidSetZoom(const int &zoomStep)
{
    int boundZoomStep = qBound(0, zoomStep, 11);
    pnids.at(activePnid)->zoomScale = boundZoomStep;
    currentZoom = boundZoomStep;
    std::cout << "current zoom: " << currentZoom << std::endl;
    emit currentZoomChanged(currentZoom);
}*/

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
