#ifndef THEMEHANDLER_H
#define THEMEHANDLER_H

#include <QObject>

class ThemeHandler : public QObject
{
    Q_OBJECT
public:
    explicit ThemeHandler(QObject *parent = nullptr);

public slots:
    void processThemeChange();

signals:
    void themeTypeChanged(const bool &isDark);
};

#endif // THEMEHANDLER_H
