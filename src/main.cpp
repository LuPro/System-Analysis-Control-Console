#include <QApplication>
#include <QSurfaceFormat>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <KAboutData>
#include <QQmlContext>
#include <QQmlEngine>
#include <KConfig>

#include <QDebug>

#include "pnidhandler.h"
#include "tcpstreamhandler.h"
#include "common.h"
#include "graphdatahandler.h"

#define VERSION_STRING "0.1"
#define APP_URI "com.tust.pnidviewer"

void addAboutInfo()
{
    KAboutData about(
        QStringLiteral("pnidviewer"),
        i18nc("@title", "PnID Viewer"),
        QStringLiteral(VERSION_STRING),
        i18n("Application for viewing and interacting with PnIDs"),
        KAboutLicense::LGPL,
        i18n("© 2023 Luis Büchi")
    );

    about.addAuthor(
        i18nc("@info:credit", "Luis Büchi"),
        i18nc("@info:credit", "Frontend & Backend"),
        QStringLiteral("some@example.com")
    );

    about.setBugAddress("https://github.com/LuPro/PnID-Viewer/issues");

    // Set aboutData as information about the app
    KAboutData::setApplicationData(about);

    qmlRegisterSingletonType(
        APP_URI,
        0, 1,
        "About",
        [](QQmlEngine* engine, QJSEngine *) -> QJSValue {
            return engine->toScriptValue(KAboutData::applicationData());
        }
    );
}

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    KLocalizedString::setApplicationDomain("pnid_viewer");
    QCoreApplication::setOrganizationName(QStringLiteral("TUST"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("tust.at"));
    QCoreApplication::setApplicationName(QStringLiteral("PnID Viewer"));

    addAboutInfo();


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
    qmlRegisterType<GraphDataHandler>("com.tust.graphs", 1, 0, "GraphDataHandler"); // TODO: think of a better name

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    QObject::connect(&tcpHandler, &TcpStreamHandler::incomingData, &pnidHandler, &PnidHandler::processPackets);
    QObject::connect(&pnidHandler, &PnidHandler::userInput, &tcpHandler, &TcpStreamHandler::sendData);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
