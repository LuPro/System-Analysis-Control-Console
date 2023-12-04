set(CMAKE_AUTOMOC ON)
add_executable(sysanalysis
    main.cpp
    tcpstreamhandler.h
    tcpstreamhandler.cpp
    pnidhandler.h
    pnidhandler.cpp
    config.h
    config.cpp
    common.h
    common.cpp
    themehandler.h
    themehandler.cpp
    graphdatahandler.h
    graphdatahandler.cpp
    confighandler.h
    confighandler.cpp
    resources.qrc
)

target_link_libraries(
    sysanalysis
    Qt5::Quick
    Qt5::Qml
    Qt5::Gui
    Qt5::QuickControls2
    Qt5::Widgets
    Qt5::WebSockets
    Qt5::Charts
    KF5::Kirigami2
    KF5::I18n
    KF5::CoreAddons
    KF5::ConfigCore
    KF5::ConfigGui
    KF5::IconThemes
)

kconfig_add_kcfg_files(sysanalysis GENERATE_MOC config.kcfgc)
