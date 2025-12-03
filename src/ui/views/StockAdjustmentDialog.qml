import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Dialog {
    id: root
    modal: true
    width: 600
    height: 650 // Un poco más alto para la nueva cabecera
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    // --- Quitamos barra de título del sistema ---
    closePolicy: Popup.NoAutoClose
    standardButtons: Dialog.NoButton

    // --- ESTILOS ---
    readonly property color bgPrimary: "#FFFFFF"
    readonly property color bgSecondary: "#F9FAFB"
    readonly property color borderLight: "#D1D5DB"
    readonly property color textDark: "#111827"
    readonly property color textMedium: "#6B7280"
    readonly property color accentPurple: "#6366F1"
    readonly property color stockGreen: "#10B981"
    readonly property color stockRed: "#EF4444"

    // --- FONDO BLANCO GARANTIZADO ---
    background: Rectangle {
        color: bgPrimary
        radius: 12
        border.color: borderLight
        border.width: 1
        layer.enabled: true
    }

    // --- COMPONENTE: BOTÓN MINI ---
    component MiniButton: Button {
        id: mBtn
        property string symbol: "+"
        property color baseColor: accentPurple
        
        width: 32; height: 32
        
        background: Rectangle {
            radius: 6
            color: mBtn.down ? Qt.darker(mBtn.baseColor, 1.1) : (mBtn.hovered ? Qt.lighter(mBtn.baseColor, 1.8) : "transparent")
            border.color: mBtn.hovered ? mBtn.baseColor : Qt.lighter(mBtn.baseColor, 1.3)
            border.width: 1
        }
        contentItem: Text {
            text: mBtn.symbol
            color: mBtn.baseColor
            font.pixelSize: 18
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea { 
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPressed: mouse.accepted = false 
        }
    }

    // --- CONTENIDO ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // 1. CABECERA PERSONALIZADA
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#EFF6FF"
            radius: 12
            // Truco para que solo redondee arriba
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 12; color: parent.color }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 15
                
                Label { text: "📦"; font.pixelSize: 22 }
                
                ColumnLayout {
                    spacing: 0
                    Label { 
                        text: "Gestión Rápida de Stock"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1E40AF" 
                    }
                    Label { 
                        text: "Ajusta cantidades en tiempo real"
                        font.pixelSize: 12
                        color: "#60A5FA" 
                    }
                }
                
                Item { Layout.fillWidth: true } // Espaciador
                
                // Botón Cerrar (X)
                Button {
                    text: "✕"
                    flat: true
                    Layout.preferredWidth: 30
                    Layout.preferredHeight: 30
                    background: Rectangle { color: parent.hovered ? "#DBEAFE" : "transparent"; radius: 15 }
                    contentItem: Text { text: parent.text; color: "#1E40AF"; font.bold: true; anchors.centerIn: parent }
                    onClicked: root.close()
                }
            }
            
            // Línea divisoria
            Rectangle {
                width: parent.width; height: 1; color: "#DBEAFE"
                anchors.bottom: parent.bottom
            }
        }

        // 2. CONTENIDO PRINCIPAL (Con márgenes)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 20
            spacing: 15

            // Aviso
            Rectangle {
                Layout.fillWidth: true
                height: 36
                color: "#F0FDFA" // Verde muy muy claro
                radius: 6
                border.color: "#CCFBF1"
                
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 12
                    Label { text: "ℹ️"; font.pixelSize: 12 }
                    Label { 
                        text: "Los cambios se guardan automáticamente al pulsar + o -"
                        font.pixelSize: 12; color: "#0F766E" // Verde azulado oscuro
                    }
                }
            }

            // Lista de Productos
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: productsModel 
                spacing: 8 

                delegate: Rectangle {
                    width: parent.width
                    height: 64
                    radius: 8
                    color: bgPrimary
                    border.color: borderLight
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 15

                        // Icono producto (opcional, placeholder)
                        Rectangle {
                            width: 36; height: 36
                            radius: 6
                            color: bgSecondary
                            border.color: borderLight
                            Label { text: "🏷️"; anchors.centerIn: parent; font.pixelSize: 16 }
                        }

                        // Info
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Label { 
                                text: model.nombre 
                                font.pixelSize: 14; font.weight: Font.DemiBold; color: textDark
                                elide: Text.ElideRight; Layout.fillWidth: true
                            }
                            Label { 
                                text: model.codigo 
                                font.pixelSize: 11; color: textMedium
                                background: Rectangle { color: bgSecondary; radius: 3 } // Estilo "tag"
                            }
                        }

                        // Control de Stock
                        Rectangle {
                            Layout.preferredWidth: 140
                            Layout.preferredHeight: 38
                            color: bgSecondary
                            radius: 19 // Pill shape perfecta
                            border.color: borderLight

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 3
                                spacing: 0

                                // Menos
                                MiniButton {
                                    symbol: "-"
                                    baseColor: stockRed
                                    Layout.alignment: Qt.AlignVCenter
                                    onClicked: {
                                        var newStock = Math.max(0, model.stock - 1)
                                        inventoryCtrl.update_stock(model.id_producto, newStock)
                                    }
                                }

                                // Input
                                TextField {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    text: model.stock
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: textDark
                                    horizontalAlignment: Text.AlignHCenter
                                    background: null 
                                    validator: IntValidator { bottom: 0; top: 99999 }
                                    selectByMouse: true
                                    
                                    onEditingFinished: {
                                        var val = parseInt(text)
                                        if (!isNaN(val)) {
                                            inventoryCtrl.update_stock(model.id_producto, val)
                                        } else {
                                            text = model.stock 
                                        }
                                    }
                                }

                                // Más
                                MiniButton {
                                    symbol: "+"
                                    baseColor: stockGreen
                                    Layout.alignment: Qt.AlignVCenter
                                    onClicked: {
                                        var newStock = model.stock + 1
                                        inventoryCtrl.update_stock(model.id_producto, newStock)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Footer / Botón Cerrar
            Button {
                text: "Hecho"
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Layout.topMargin: 10
                
                background: Rectangle {
                    color: parent.down ? Qt.darker(accentPurple, 1.1) : accentPurple
                    radius: 8
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    font.pixelSize: 14
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                MouseArea { 
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor; 
                    onPressed: mouse.accepted = false 
                }
                onClicked: root.close()
            }
        }
    }
}