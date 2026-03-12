#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCoreApplication>

using namespace Qt::StringLiterals;

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("QtMultiplayerDemo");
    app.setApplicationVersion("0.1");

    QQmlApplicationEngine engine;

    // Fallback server URL — override via QML or environment variable
    const QString defaultUrl =
#ifdef DESKTOP_BUILD
        QStringLiteral("ws://localhost:8787");
#else
        // WASM: replace with your deployed worker URL before building
        QStringLiteral("wss://qt-multiplayer-demo.mesw.workers.dev");
#endif

    engine.rootContext()->setContextProperty("defaultServerUrl", defaultUrl);

    const QUrl qmlEntry(u"qrc:/qt/qml/QtMultiplayerClient/main.qml"_qs);
    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed,
        &app,    [](){ QCoreApplication::exit(1); },
        Qt::QueuedConnection
    );
    engine.load(qmlEntry);

    return app.exec();
}
