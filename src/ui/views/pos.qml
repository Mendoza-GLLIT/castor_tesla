import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    Rectangle {
        id: notification
        width: 400; height: 50; radius: 8
        color: notifError ? "#ef4444" : "#10b981" // Rojo o Verde
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 20
        z: 100
        opacity: 0
        property bool notifError: false

        Label {
            id: notifText
            anchors.centerIn: parent
            color: "white"
            font.pixelSize: 16
            font.bold: true
        }

        Behavior on opacity { NumberAnimation { duration: 300 } }
        Timer {
            id: notifTimer
            interval: 3000
            onTriggered: notification.opacity = 0
        }
    }

    Connections {
        target: posBackend
        function onNotification(msg, isError) {
            notifText.text = msg
            notification.notifError = isError
            notification.opacity = 1
            notifTimer.restart()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        // -- LISTA DE PRODUCTOS --
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 7
            color: "white"
            radius: 12
            border.color: "#E5E7EB"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Label {
                    text: "🛒 Carrito de Compra"
                    font.pixelSize: 22
                    font.bold: true
                    color: "#111827"
                }

                // Encabezados
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "Producto"; font.bold: true; color: "#6B7280"; Layout.fillWidth: true }
                    Label { text: "Cant."; font.bold: true; color: "#6B7280"; Layout.preferredWidth: 60 }
                    Label { text: "Precio"; font.bold: true; color: "#6B7280"; Layout.preferredWidth: 80 }
                    Label { text: "Total"; font.bold: true; color: "#6B7280"; Layout.preferredWidth: 80 }
                    Item { width: 40 }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: "#E5E7EB" }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: posBackend.cartModel 
                    spacing: 8

                    delegate: Rectangle {
                        width: parent.width
                        height: 50
                        color: "#F9FAFB"
                        radius: 6

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12; anchors.rightMargin: 12
                            
                            Column {
                                Layout.fillWidth: true
                                Label { text: nombre; font.pixelSize: 14; font.bold: true; color: "#333" }
                                Label { text: codigo; font.pixelSize: 12; color: "#888" }
                            }
                            
                            Label { text: cantidad; font.pixelSize: 14; Layout.preferredWidth: 60 }
                            Label { text: precio; font.pixelSize: 14; Layout.preferredWidth: 80 }
                            Label { text: total; font.pixelSize: 14; font.bold: true; color: "#4CAF50"; Layout.preferredWidth: 80 }

                            // Botón Eliminar
                            Button {
                                text: "X"
                                width: 30; height: 30
                                background: Rectangle { color: "#fee2e2"; radius: 4 }
                                contentItem: Text { text: "✕"; color: "#ef4444"; anchors.centerIn: parent }
                                onClicked: posBackend.removeFromCart(index)
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 4
            spacing: 16

            // Tarjeta de Buscador
            Rectangle {
                Layout.fillWidth: true
                height: 150
                color: "white"
                radius: 12
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12

                    Label { text: "🔍 Agregar Producto"; font.bold: true; font.pixelSize: 16; color: "#374151" }
                    
                    TextField {
                        id: codeInput
                        Layout.fillWidth: true
                        height: 45
                        placeholderText: "Escanea o escribe código..."
                        font.pixelSize: 16
                        background: Rectangle {
                            color: "#F3F4F6"; radius: 8; border.color: codeInput.activeFocus ? "#6366F1" : "transparent"; border.width: 2
                        }
                        onAccepted: {
                            if(text !== "") {
                                posBackend.addToCart(text)
                                text = "" // Limpiar
                                forceActiveFocus() // Mantener foco para seguir escaneando
                            }
                        }
                    }
                    Label { text: "Presiona Enter para agregar"; font.pixelSize: 12; color: "#9CA3AF" }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 12
                border.color: "#E5E7EB"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 20

                    Item { Layout.fillHeight: true } 

                    RowLayout {
                        Layout.fillWidth: true
                        Label { text: "Subtotal"; font.pixelSize: 16; color: "#6B7280" }
                        Item { Layout.fillWidth: true }
                        Label { text: "$" + posBackend.total.toFixed(2); font.pixelSize: 16; font.bold: true; color: "#374151" }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#E5E7EB" }

                    RowLayout {
                        Layout.fillWidth: true
                        Label { text: "TOTAL"; font.pixelSize: 24; font.bold: true; color: "#111827" }
                        Item { Layout.fillWidth: true }
                        Label { 
                            text: "$" + posBackend.total.toFixed(2)
                            font.pixelSize: 32; font.bold: true; color: "#6366F1" 
                        }
                    }

                    Button {
                        text: "COBRAR"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        background: Rectangle {
                            color: parent.down ? "#4338ca" : "#6366F1"
                            radius: 8
                        }
                        contentItem: Text {
                            text: parent.text
                            font.bold: true
                            font.pixelSize: 18
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: posBackend.checkout()
                    }
                }
            }
        }
    }
}