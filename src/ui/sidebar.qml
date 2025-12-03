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
    
    // Obtenemos el rol actual desde el controlador 'auth'
    property string userRole: auth.userRole
    property string userName: auth.fullName

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // --- ENCABEZADO ---
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

        // --- MENÚ DE NAVEGACIÓN ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // 1. PUNTO DE VENTA (Admin y Vendedor)
            SidebarButton {
                icon: "delivery_truck"
                text: "Punto de Venta"
                isActive: sidebar.currentView === "views/pos.qml"
                visible: userRole === "Administrador" || userRole === "Vendedor"
                onClicked: {
                    sidebar.currentView = "views/pos.qml"
                    viewLoader.source = "views/pos.qml"
                }
            }

            // 2. HISTORIAL DE VENTAS (Admin, Contador, Vendedor)
            SidebarButton {
                icon: "dollar"
                text: "Historial Ventas"
                isActive: sidebar.currentView === "views/sales.qml"
                visible: userRole === "Administrador" || userRole === "Contador" || userRole === "Vendedor"
                onClicked: {
                    sidebar.currentView = "views/sales.qml"
                    viewLoader.source = "views/sales.qml"
                }
            }

            // 3. INVENTARIO (Admin, Almacenista, Contador, Vendedor)
            SidebarButton {
                icon: "boxes"
                text: "Inventario"
                isActive: sidebar.currentView === "views/inventory.qml"
                visible: userRole === "Administrador" || userRole === "Almacenista" || userRole === "Contador" || userRole === "Vendedor"
                onClicked: {
                    sidebar.currentView = "views/inventory.qml"
                    viewLoader.source = "views/inventory.qml"
                }
            }

            // --- ESPACIADOR ---
            // AQUÍ ESTABA EL ERROR (te faltaba 'Item')
            Item { height: 10 } 


            // 4. CLIENTES
            SidebarButton {
                icon: "clients"
                text: "Clientes"
                isActive: sidebar.currentView === "views/clients.qml" // Asegúrate de tener esta vista o cámbiala
                visible: userRole === "Administrador" || userRole === "Almacenista" || userRole === "Contador" || userRole === "Vendedor"
                onClicked: {
                    sidebar.currentView = "views/clients.qml"
                    viewLoader.source = "views/clients.qml" 
                }
            }

            // 5. EMPLEADOS (Solo Admin)
            SidebarButton {
                icon: "user" 
                text: "Empleados"
                isActive: sidebar.currentView === "views/employers.qml"
                visible: userRole === "Administrador" 
                onClicked: {
                    sidebar.currentView = "views/employers.qml"
                    viewLoader.source = "views/employers.qml"
                }
            }

            // 6. Activos
            SidebarButton {
                icon: "assets"
                text: "Activos"
                isActive: sidebar.currentView === "views/assets.qml"
                visible: userRole === "Administrador" || userRole === "Almacenista" || userRole === "Contador" || userRole === "Vendedor"
                onClicked: {
                    sidebar.currentView = "views/assets.qml"
                    viewLoader.source = "views/assets.qml"
                }
            }

            // 6. ESTADÍSTICAS
            SidebarButton {
                icon: "stats"
                text: "Estadisticas"
                isActive: sidebar.currentView === "views/statistics.qml"
                visible: userRole === "Administrador" || userRole === "Almacenista" || userRole === "Contador" || userRole === "Vendedor"
                onClicked: {
                    sidebar.currentView = "views/statistics.qml"
                    viewLoader.source = "views/statistics.qml"
                }
            }
            
            // Espaciador flexible para empujar Configuración abajo
            Item { Layout.fillHeight: true }

            // 7. CONFIGURACIÓN
            SidebarButton {
                icon: "settings"
                text: "Configuración"
                isActive: sidebar.currentView === "views/settings.qml"
                visible: userRole === "Administrador"
                onClicked: {
                    sidebar.currentView = "views/settings.qml"
                    // viewLoader.source = "views/settings.qml"
                }
            }
        }

        // --- TARJETA DE USUARIO (PERFIL) ---
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

                // Avatar con iniciales
                Rectangle {
                    width: 42
                    height: 42
                    radius: 21
                    color: "#2C3454"
                    clip: true

                    Label {
                        anchors.centerIn: parent
                        text: userName ? userName.charAt(0).toUpperCase() : "?"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 18
                    }
                }

                // Información del Usuario
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        text: sidebar.userName 
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                    Label {
                        text: sidebar.userRole 
                        font.pixelSize: 11
                        color: "#9CA3AF"
                    }
                }

                // Botón Cerrar Sesión
                MouseArea {
                    width: 24; height: 24
                    cursorShape: Qt.PointingHandCursor
                    
                    Label { 
                        text: "⏻" // Símbolo de Power
                        color: "#EF4444"
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }
                    
                    onClicked: {
                        console.log("Cerrando sesión...")
                        auth.logout() 
                    }
                }
            }
        }
    }
}