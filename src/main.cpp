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
#include <QQuickStyle>
#include <KIconThemes/kicontheme.h>

#include "config.h"
#include <KConfig>
#include <KSharedConfig>
#include <KConfigGroup>

#include <QDebug>

#include "pnidhandler.h"
#include "tcpstreamhandler.h"
#include "common.h"
#include "graphdatahandler.h"

#define VERSION_STRING "0.1"
#define VERSION_MAJOR 0
#define VERSION_MINOR 1
#define APP_URI "at.tust.sysanalysis"
#define APP_CONFIG_NAME "sysanalysisrc"

void addAboutInfo()
{
    KAboutData about(
        QStringLiteral("sysanalysis"),
        i18nc("@title", "System Analysis & Control Console"),
        QStringLiteral(VERSION_STRING),
        i18n("Application for viewing and interacting with Systems"),
        KAboutLicense::LGPL,
        i18n("© 2023 Luis Büchi")
    );

    about.setDesktopFileName(APP_URI);

    about.addAuthor(
        i18nc("@info:credit", "Luis Büchi"),
        i18nc("@info:credit", "Frontend & Backend"),
        QStringLiteral("buechi.luis.contact@gmail.com")
    );

    about.setBugAddress("https://github.com/LuPro/System-Analysis-Control-Console/issues");

    // Set aboutData as information about the app
    KAboutData::setApplicationData(about);

    qmlRegisterSingletonType(
        APP_URI,
        VERSION_MAJOR, VERSION_MINOR,
        "About",
        [](QQmlEngine* engine, QJSEngine *) -> QJSValue {
            return engine->toScriptValue(KAboutData::applicationData());
        }
    );
}

int main(int argc, char *argv[])
{
    KIconTheme::current(); //workaround for Windows, otherwise no icons will load
    if (qEnvironmentVariableIsEmpty("QT_QUICK_CONTROLS_STYLE")) {
        QQuickStyle::setStyle(QStringLiteral("org.kde.desktop"));
    }

    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    KLocalizedString::setApplicationDomain("sysanalysis");
    QCoreApplication::setOrganizationName(QStringLiteral("TUST"));
    QCoreApplication::setOrganizationDomain(QStringLiteral("tust.at"));
    QCoreApplication::setApplicationName(QStringLiteral("System Analysis & Control Console"));

    addAboutInfo();

    Config *config = Config::self();

    //this block is for antialiasing, but ideally I'd like that to not be for the entire app,
    //only for the pnid layer. ideally ideally it should already be drawn with subpixel accuracy since it's vectors
    QSurfaceFormat format;
    format.setSamples(4);
    QSurfaceFormat::setDefaultFormat(format);

    QQmlApplicationEngine engine;
    qmlRegisterSingletonInstance(APP_URI, VERSION_MAJOR, VERSION_MINOR, "Config", config);

    TcpStreamHandler tcpHandler;
    engine.rootContext()->setContextProperty("tcpHandler", &tcpHandler);
    PnidHandler pnidHandler(&engine, config->readPnidPath());
    engine.rootContext()->setContextProperty("pnidHandler", &pnidHandler);
    qmlRegisterType<GraphDataHandler>("at.tust.graphs", 1, 0, "GraphDataHandler"); // TODO: think of a better name

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
