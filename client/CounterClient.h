#pragma once

#include <QObject>
#include <QWebSocket>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

class CounterClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(int     counter   READ counter   NOTIFY counterChanged)
    Q_PROPERTY(bool    connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(QString serverUrl READ serverUrl WRITE setServerUrl NOTIFY serverUrlChanged)
    Q_PROPERTY(QString leader    READ leader    NOTIFY leaderChanged)
    Q_PROPERTY(QString initials  READ initials  WRITE setInitials   NOTIFY initialsChanged)

public:
    explicit CounterClient(QObject *parent = nullptr);

    int     counter()   const { return m_counter; }
    bool    connected() const { return m_connected; }
    QString serverUrl() const { return m_serverUrl; }
    void    setServerUrl(const QString &url);
    QString initials()  const { return m_initials; }
    void    setInitials(const QString &s);
    QString leader()    const { return m_leader; }

    Q_INVOKABLE void increment();
    Q_INVOKABLE void connectToServer();

signals:
    void counterChanged();
    void connectedChanged();
    void serverUrlChanged();
    void leaderChanged();
    void initialsChanged();

private slots:
    void onConnected();
    void onDisconnected();
    void onTextMessageReceived(const QString &message);
    void onError(QAbstractSocket::SocketError error);

private:
    void scheduleReconnect();

    QWebSocket m_socket;
    QTimer     m_reconnectTimer;
    QString    m_serverUrl;
    QString    m_initials;
    QString    m_leader;
    int        m_counter   = 0;
    bool       m_connected = false;
};
