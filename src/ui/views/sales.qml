import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    readonly property color bgPrimary: "#FFFFFF"
    readonly property color bgSecondary: "#F9FAFB"
    readonly property color borderLight: "#E5E7EB"
    readonly property color textDark: "#111827"
    readonly property color textMedium: "#6B7280"
    readonly property color accentPurple: "#6366F1"

    Rectangle {
        anchors.fill: parent
        color: bgSecondary

        Rectangle {
            width: Math.min(parent.width - 48, 1000)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.margins: 24
            color: bgPrimary; radius: 12
            border.color: borderLight; border.width: 1; clip: true

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 24; spacing: 24

                Label {
                    text: "Historial de Ventas"
                    font.pixelSize: 24; font.weight: Font.Bold
                    color: textDark; Layout.fillWidth: true
                }

                // Encabezados
                Rectangle {
                    Layout.fillWidth: true; height: 48; color: bgSecondary
                    Rectangle { width: parent.width; height: 1; color: borderLight; anchors.bottom: parent.bottom }

                    RowLayout {
                        anchors.fill: parent; spacing: 0
                        Label { text: "ID"; font.bold: true; color: textMedium; Layout.preferredWidth: 60; leftPadding: 16 }
                        Label { text: "CLIENTE"; font.bold: true; color: textMedium; Layout.fillWidth: true; Layout.preferredWidth: 2 }
                        Label { text: "VENDEDOR"; font.bold: true; color: textMedium; Layout.fillWidth: true; Layout.preferredWidth: 2 }
                        Label { text: "FECHA"; font.bold: true; color: textMedium; Layout.fillWidth: true; Layout.preferredWidth: 2 }
                        Label { text: "TOTAL"; font.bold: true; color: textMedium; Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight; rightPadding: 40 }
                        Item { width: 40 } 
                    }
                }

                // LISTA DE VENTAS
                ListView {
                    id: salesList
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true
                    
                    // Enlace al backend
                    model: posBackend.salesHistoryModel 
                    spacing: 8

                    delegate: Column {
                        width: parent.width
                        property bool isExpanded: false 

                        // 1. FILA PRINCIPAL (Resumen)
                        Rectangle {
                            width: parent.width; height: 56; color: bgPrimary
                            
                            Rectangle { 
                                anchors.fill: parent 
                                color: parent.parent.isExpanded ? "#F3F4F6" : (clickArea.containsMouse ? "#FAFAFA" : "transparent")
                            }

                            RowLayout {
                                anchors.fill: parent; spacing: 0
                                
                                // AQUI ESTABA EL ERROR: Usar 'modelData.clave_python'
                                
                                Label { 
                                    text: "#" + modelData.id_venta  // Clave exacta de Python
                                    font.bold: true; color: accentPurple
                                    Layout.preferredWidth: 60; leftPadding: 16 
                                }
                                
                                Label { 
                                    text: modelData.cliente // Clave exacta
                                    color: textDark
                                    Layout.fillWidth: true; Layout.preferredWidth: 2 
                                }
                                
                                Label { 
                                    text: modelData.vendedor // Clave exacta
                                    color: textDark
                                    Layout.fillWidth: true; Layout.preferredWidth: 2 
                                }

                                Label { 
                                    text: modelData.fecha // Clave exacta
                                    color: textMedium; font.pixelSize: 12
                                    Layout.fillWidth: true; Layout.preferredWidth: 2 
                                }

                                Label { 
                                    text: modelData.total // Clave exacta
                                    font.bold: true; color: "#10B981"
                                    Layout.preferredWidth: 100; horizontalAlignment: Text.AlignRight; rightPadding: 40 
                                }
                                
                                Text { 
                                    text: parent.parent.parent.isExpanded ? "▼" : "▶"
                                    color: textMedium; font.pixelSize: 12
                                    width: 40; horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: clickArea
                                anchors.fill: parent
                                hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: parent.parent.isExpanded = !parent.parent.isExpanded
                            }
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: borderLight }
                        }

                        // 2. ÁREA EXPANDIBLE (Detalles)
                        Rectangle {
                            id: detailsContainer
                            width: parent.width
                            height: parent.isExpanded ? contentCol.implicitHeight + 30 : 0 
                            color: "#F8FAFC"
                            clip: true
                            
                            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                            ColumnLayout {
                                id: contentCol
                                width: parent.width
                                spacing: 8
                                y: 15 

                                Label { 
                                    text: "Detalle de Productos:"
                                    font.pixelSize: 12; font.bold: true; color: textMedium 
                                    Layout.leftMargin: 24; Layout.bottomMargin: 4
                                }

                                Repeater {
                                    // Accedemos a la lista anidada 'detalles' dentro del objeto actual
                                    model: modelData.detalles 

                                    delegate: RowLayout {
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 24; Layout.rightMargin: 40
                                        
                                        Label { 
                                            // En el Repeater interno, modelData es el item del detalle
                                            text: "• " + modelData.producto 
                                            font.pixelSize: 13; color: textDark 
                                            Layout.fillWidth: true 
                                        }
                                        
                                        Label { 
                                            text: modelData.cantidad + " pza" 
                                            font.pixelSize: 13; color: textMedium 
                                            Layout.preferredWidth: 60; horizontalAlignment: Text.AlignRight 
                                        }
                                        
                                        Label { 
                                            text: "$" + Number(modelData.subtotal).toFixed(2) 
                                            font.pixelSize: 13; font.bold: true; color: textDark 
                                            Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight 
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}