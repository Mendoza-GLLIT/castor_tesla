import QtQuick
import QtQuick.Controls

ApplicationWindow {
    id: dashboard
    width: 1280
    height: 720
    visible: true
    visibility: Window.Maximized
    title: qsTr("Dashboard")
    color: "#0a0f24"

    Loader {
        id: sidebarLoader
        source: "sidebar.qml"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 240 // Ancho fijo para la sidebar
        
        onLoaded: {
            if (sidebarLoader.item) {
                // 1. Pasamos la referencia del Loader principal a la Sidebar
                sidebarLoader.item.viewLoader = viewLoader
                
                // 2. [IMPORTANTE] Le avisamos a la Sidebar que estamos en POS
                // Esto hace que el botón se ilumine al iniciar
                sidebarLoader.item.currentView = "views/pos.qml"
            }
        }
    }

    Loader {
        id: viewLoader
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: sidebarLoader.right
        anchors.right: parent.right
        
        // --- CAMBIO AQUÍ ---
        // Antes decía "views/home.qml", por eso salía vacío.
        source: "views/pos.qml" 
    }
}