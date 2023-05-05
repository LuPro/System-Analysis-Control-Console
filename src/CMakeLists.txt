set(CMAKE_AUTOMOC ON)
add_executable(pnid_viewer
    main.cpp
    tcpstreamhandler.h
    tcpstreamhandler.cpp
    pnidhandler.h
    pnidhandler.cpp
    resources.qrc
)

target_link_libraries(pnid_viewer Qt5::Quick Qt5::Qml Qt5::Gui Qt5::QuickControls2 Qt5::Widgets Qt5::WebSockets KF5::Kirigami2 KF5::I18n)
