import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: sidebar
    width: 260
    height: parent.height
    color: "#1b2241"

    property Loader viewLoader
    property string currentView: "views/pos.qml"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // CABECERA
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 10

            Label {
                text: "CASTOR TESLA"
                font.pixelSize: 22
                font.weight: Font.ExtraBold
                font.letterSpacing: 2
                color: "white"
                Layout.alignment: Qt.AlignLeft
            }
            
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: "#2C3454"
            }
        }

        // MENÚ DE NAVEGACIÓN
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            SidebarButton {
                icon: "dashboard"
                text: "Punto de Venta"
                isActive: sidebar.currentView === "views/pos.qml"
                onClicked: {
                    sidebar.currentView = "views/pos.qml"
                    viewLoader.source = "views/pos.qml"
                }
            }

            SidebarButton {
                icon: "shopping-cart"
                text: "Historial Ventas"
                isActive: sidebar.currentView === "views/sales.qml"
                onClicked: {
                    sidebar.currentView = "views/sales.qml"
                    viewLoader.source = "views/sales.qml"
                }
            }

            SidebarButton {
                icon: "box"
                text: "Inventario"
                isActive: sidebar.currentView === "views/inventory.qml"
                onClicked: {
                    sidebar.currentView = "views/inventory.qml"
                    viewLoader.source = "views/inventory.qml"
                }
            }

            Item { height: 10 } 

            SidebarButton {
                icon: "schedule"
                text: "Agenda"
                isActive: sidebar.currentView === "views/schedule.qml"
                onClicked: {
                    sidebar.currentView = "views/schedule.qml"
                    viewLoader.source = "views/schedule.qml"
                }
            }

            SidebarButton {
                icon: "message"
                text: "Mensajes"
                isActive: sidebar.currentView === "views/messages.qml"
                onClicked: {
                    sidebar.currentView = "views/messages.qml"
                    viewLoader.source = "views/messages.qml"
                }
            }

            Item { Layout.fillHeight: true }

            SidebarButton {
                icon: "settings"
                text: "Configuración"
                isActive: sidebar.currentView === "views/settings.qml"
                onClicked: {
                    sidebar.currentView = "views/settings.qml"
                    viewLoader.source = "views/settings.qml"
                }
            }
        }

        // SECCIÓN DE PERFIL (PIE DE PÁGINA)
        Rectangle {
            Layout.fillWidth: true
            height: 70
            radius: 12
            color: "#0f1429"
            border.color: "#2C3454"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Avatar / Iniciales
                Rectangle {
                    width: 42
                    height: 42
                    radius: 21
                    color: "#2C3454"
                    clip: true

                    Image {
                        id: profileImg
                        anchors.fill: parent
                        source: "../../resources/profile.png"
                        fillMode: Image.PreserveAspectCrop
                        // Si falla la carga, limpiamos source para mostrar texto
                        onStatusChanged: if (status === Image.Error) source = "" 
                    }
                    
                    Label {
                        anchors.centerIn: parent
                        // Lógica para obtener iniciales: "Emmanuel Mendoza" -> "EM"
                        text: {
                            var name = auth.fullName ? auth.fullName : auth.username
                            if (!name) return "??"
                            var parts = name.split(" ")
                            if (parts.length >= 2) {
                                return (parts[0][0] + parts[1][0]).toUpperCase()
                            } else {
                                return name.substring(0, 2).toUpperCase()
                            }
                        }
                        color: "white"
                        font.bold: true
                        visible: profileImg.status !== Image.Ready
                    }
                }

                // Info del Usuario
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    Label {
                        text: auth.fullName !== "" ? auth.fullName : auth.username
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    
                    Label {
                        text: auth.userRole
                        font.pixelSize: 11
                        color: "#9CA3AF"
                    }
                }

                // Botón Salir
                MouseArea {
                    width: 24; height: 24
                    cursorShape: Qt.PointingHandCursor
                    
                    Image {
                        anchors.fill: parent
                        source: "../../resources/icons/logout.png"
                        opacity: 0.6
                        fillMode: Image.PreserveAspectFit
                    }
                    
                    // Icono de respaldo (texto)
                    Label { 
                        text: "⏻"
                        color: "#EF4444"
                        font.pixelSize: 18
                        anchors.centerIn: parent
                        visible: parent.children[0].status !== Image.Ready
                    }
                    
                    onClicked: {
                        console.log("Cerrando sesión...")
                        auth.logout() // Llamada al nuevo controlador
                    }
                }
            }
        }
    }
}