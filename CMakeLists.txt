cmake_minimum_required(VERSION 3.16)
project(pnid_viewer)

set(CMAKE_AUTOMOC ON)

set(KF_MIN_VERSION "5.68.0")
set(QT_MIN_VERSION "5.12.0")

add_compile_definitions(QT_DEBUG)

find_package(ECM ${KF_MIN_VERSION} REQUIRED NO_MODULE)

set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDECompilerSettings NO_POLICY_SCOPE)

find_package(Qt5 ${QT_MIN_VERSION} REQUIRED NO_MODULE COMPONENTS Core Quick Test Gui QuickControls2 Widgets WebSockets)
find_package(KF5 ${KF_MIN_VERSION} REQUIRED COMPONENTS Kirigami2 I18n CoreAddons)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(src)

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
