#include <QApplication>
#include <QSurfaceFormat>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QUrl>
#include <KLocalizedContext>
#include <KLocalizedString>
#include <QQmlContext>

#include <QDebug>

#include "pnidhandler.h"
#include "tcpstreamhandler.h"

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
    PnidHandler pnidHandler;
    engine.rootContext()->setContextProperty("pnidHandler", &pnidHandler);

    engine.rootContext()->setContextObject(new KLocalizedContext(&engine));
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
