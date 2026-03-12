#include "CounterClient.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>

static constexpr int kReconnectIntervalMs = 3000;

CounterClient::CounterClient(QObject *parent)
    : QObject(parent)
{
    connect(&m_socket, &QWebSocket::connected,    this, &CounterClient::onConnected);
    connect(&m_socket, &QWebSocket::disconnected, this, &CounterClient::onDisconnected);
    connect(&m_socket, &QWebSocket::textMessageReceived,
            this, &CounterClient::onTextMessageReceived);
    connect(&m_socket, &QWebSocket::errorOccurred, this, &CounterClient::onError);

    m_reconnectTimer.setSingleShot(true);
    m_reconnectTimer.setInterval(kReconnectIntervalMs);
    connect(&m_reconnectTimer, &QTimer::timeout, this, &CounterClient::connectToServer);
}

// ---------------------------------------------------------------------------

void CounterClient::setServerUrl(const QString &url)
{
    if (m_serverUrl == url) return;
    m_serverUrl = url;
    emit serverUrlChanged();
}

void CounterClient::connectToServer()
{
    if (m_serverUrl.isEmpty()) return;
    m_socket.open(QUrl(m_serverUrl));
}

void CounterClient::increment()
{
    if (!m_connected) return;
    const QJsonObject msg{ { "type", "increment" } };
    m_socket.sendTextMessage(QString::fromUtf8(QJsonDocument(msg).toJson(QJsonDocument::Compact)));
}

// ---------------------------------------------------------------------------

void CounterClient::onConnected()
{
    m_connected = true;
    emit connectedChanged();
    qDebug() << "[CounterClient] Connected to" << m_serverUrl;
}

void CounterClient::onDisconnected()
{
    m_connected = false;
    emit connectedChanged();
    qDebug() << "[CounterClient] Disconnected — reconnecting in" << kReconnectIntervalMs << "ms";
    scheduleReconnect();
}

void CounterClient::onTextMessageReceived(const QString &message)
{
    const QJsonObject obj = QJsonDocument::fromJson(message.toUtf8()).object();
    if (obj.value("type").toString() == "counter") {
        m_counter = obj.value("value").toInt();
        emit counterChanged();
    }
}

void CounterClient::onError(QAbstractSocket::SocketError error)
{
    qWarning() << "[CounterClient] Socket error:" << error << m_socket.errorString();
    scheduleReconnect();
}

void CounterClient::scheduleReconnect()
{
    if (!m_reconnectTimer.isActive())
        m_reconnectTimer.start();
}
