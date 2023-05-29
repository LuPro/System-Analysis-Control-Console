#include <QApplication>
#include <QSurfaceFormat>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <KLocalizedContext>
#include <KLocalizedString>
//#include <KCoreAddons/kaboutdata.h>
#include <QQmlContext>

#include <QDebug>

#include "pnidhandler.h"
#include "tcpstreamhandler.h"
#include "common.h"

/*void addAboutInfo()
{
    KAboutData aboutData(
        QStringLiteral("PnID Viewer"),
        i18nc("@title", "PnID Viewer About"),
        QStringLiteral("0.1"),
        i18n("Application for viewing and interacting with PnIDs"),
        KAboutLicense::LGPL,
        i18n("(c) 2023"));

    aboutData.addAuthor(
        i18nc("@info:credit", "Luis Büchi"),
        i18nc("@info:credit", "Frontend & Backend"),
        QStringLiteral("some@example.com"),
        QStringLiteral("https://example.com"));

    // Set aboutData as information about the app
    KAboutData::setApplicationData(aboutData);

}*/

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    KLocalizedString::setApplicationDomain("pnid_viewer");
    QCoreApplication::setOrganizationName(QStringLiteral("KDE"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("kde.org"));
    QCoreApplication::setApplicationName(QStringLiteral("PnID Viewer"));

    //this block is for antialiasing, but ideally I'd like that to not be for the entire app,
    //only for the pnid layer. ideally ideally it should already be drawn with subpixel accuracy since it's vectors
    QSurfaceFormat format;
    format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format);

    QQmlApplicationEngine engine;

    TcpStreamHandler tcpHandler;
    engine.rootContext()->setContextProperty("tcpHandler", &tcpHandler);
    PnidHandler pnidHandler(&engine, app.applicationDirPath());
    engine.rootContext()->setContextProperty("pnidHandler", &pnidHandler);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QObject::connect(&tcpHandler, &TcpStreamHandler::incomingData, &pnidHandler, &PnidHandler::processPackets);
    QObject::connect(&pnidHandler, &PnidHandler::userInput, &tcpHandler, &TcpStreamHandler::sendData);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
