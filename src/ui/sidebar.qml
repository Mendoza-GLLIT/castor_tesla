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

                Rectangle {
                    width: 42
                    height: 42
                    radius: 21
                    color: "#2C3454"
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: "../../resources/profile.png"
                        fillMode: Image.PreserveAspectCrop
                        onStatusChanged: if (status === Image.Error) source = "" 
                    }
                    
                    Label {
                        anchors.centerIn: parent
                        text: "EM"
                        color: "white"
                        visible: parent.children[0].status !== Image.Ready
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Label {
                        text: "Emmanuel M."
                        font.pixelSize: 14
                        font.bold: true
                        color: "white"
                    }
                    Label {
                        text: "Administrador"
                        font.pixelSize: 11
                        color: "#9CA3AF"
                    }
                }

                MouseArea {
                    width: 24; height: 24
                    cursorShape: Qt.PointingHandCursor
                    Image {
                        anchors.fill: parent
                        source: "../../resources/icons/logout.png"
                        opacity: 0.6
                        fillMode: Image.PreserveAspectFit
                    }
                    Label { 
                        text: "⏻"
                        color: "#EF4444"
                        font.pixelSize: 18
                        anchors.centerIn: parent
                        visible: parent.children[0].status !== Image.Ready
                    }
                    onClicked: console.log("Cerrar sesión")
                }
            }
        }
    }
}