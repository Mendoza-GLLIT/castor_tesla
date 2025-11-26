import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: dashboard
    width: 1280
    height: 720
    visible: true
    visibility: Window.Maximized   // 👈 se abre maximizado, con barra y botones
    title: qsTr("Dashboard")
    color: "#0a0f24"

    Loader {
        id: sidebarLoader
        source: "sidebar.qml"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 240
        onLoaded: {
            if (sidebarLoader.item) {
                sidebarLoader.item.viewLoader = viewLoader
            }
        }
    }

    Loader {
        id: viewLoader
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: sidebarLoader.right
        anchors.right: parent.right
        source: "views/home.qml"
    }
}
