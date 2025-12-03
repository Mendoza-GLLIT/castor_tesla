import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    // --- Estilos ---
    readonly property color bgPrimary: "#FFFFFF"
    readonly property color bgSecondary: "#F9FAFB"
    readonly property color borderLight: "#E5E7EB"
    readonly property color textDark: "#111827"
    readonly property color textMedium: "#6B7280"
    readonly property color accentPurple: "#6366F1"
    readonly property color dangerRed: "#EF4444"
    readonly property color successGreen: "#10B981"

    // --- NOTIFICACIONES ---
    Rectangle {
        id: notification
        width: 400; height: 48; radius: 8
        color: notifError ? dangerRed : successGreen
        anchors.top: parent.top; anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 24; z: 100; opacity: 0
        property bool notifError: false
        RowLayout {
            anchors.centerIn: parent; spacing: 8
            Label { text: notification.notifError ? "⚠️" : "✅"; font.pixelSize: 16 }
            Label { id: notifText; color: "white"; font.pixelSize: 14; font.bold: true }
        }
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Timer { id: notifTimer; interval: 3000; onTriggered: notification.opacity = 0 }
    }

    Connections {
        target: posBackend
        function onNotification(msg, isError) {
            notifText.text = msg; notification.notifError = isError
            notification.opacity = 1; notifTimer.restart()
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24

        // ============================================================
        // 🛍️ PANEL IZQUIERDO: CATÁLOGO DE PRODUCTOS
        // ============================================================
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.preferredWidth: 6
            color: bgPrimary
            radius: 12
            border.color: borderLight
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12

                Label { 
                    text: "📦 Catálogo de Productos"
                    font.pixelSize: 20; font.bold: true; color: textDark 
                }

                // --- BUSCADOR CONECTADO AL MODELO ---
                TextField {
                    placeholderText: "Filtrar productos..."
                    placeholderTextColor: textMedium
                    color: textDark
                    Layout.fillWidth: true
                    height: 40
                    font.pixelSize: 14
                    background: Rectangle { 
                        color: bgSecondary; radius: 8; border.color: borderLight; border.width: 1 
                    }
                    
                    // 👇👇👇 ESTA LÍNEA HACE LA MAGIA DEL FILTRO 👇👇👇
                    onTextChanged: productsModel.filter(text)
                }

                // Cabecera
                RowLayout {
                    Layout.fillWidth: true
                    Label { text: "PRODUCTO"; font.bold: true; color: textMedium; Layout.fillWidth: true }
                    Label { text: "PRECIO"; font.bold: true; color: textMedium; Layout.preferredWidth: 70; horizontalAlignment: Text.AlignRight }
                    Label { text: "STOCK"; font.bold: true; color: textMedium; Layout.preferredWidth: 60; horizontalAlignment: Text.AlignCenter }
                    Label { text: "CANT."; font.bold: true; color: textMedium; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignCenter }
                    Item { width: 40 }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: borderLight }

                // LISTA DE PRODUCTOS
                ListView {
                    id: inventoryList
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; spacing: 6
                    model: productsModel 

                    delegate: Rectangle {
                        width: parent.width; height: 56; color: bgSecondary; radius: 8
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12; anchors.rightMargin: 12
                            spacing: 12

                            Column {
                                Layout.fillWidth: true
                                Label { text: nombre; font.pixelSize: 14; font.bold: true; color: textDark; elide: Text.ElideRight; width: parent.width }
                                Label { text: codigo; font.pixelSize: 11; color: textMedium }
                            }
                            Label { text: precio; font.pixelSize: 14; color: textDark; Layout.preferredWidth: 70; horizontalAlignment: Text.AlignRight }
                            Label { text: stock; font.pixelSize: 14; color: textMedium; Layout.preferredWidth: 60; horizontalAlignment: Text.AlignCenter }
                            
                            // Input Cantidad (Color corregido)
                            TextField {
                                id: qtyInput; text: "1"
                                font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter
                                Layout.preferredWidth: 50; Layout.preferredHeight: 32
                                validator: IntValidator { bottom: 1; top: 999 }
                                color: textDark // <-- Importante
                                background: Rectangle { 
                                    color: "white"; radius: 4; border.color: borderLight; border.width: 1 
                                }
                            }

                            Button {
                                width: 36; height: 36
                                background: Rectangle {
                                    color: parent.down ? Qt.darker(accentPurple, 1.1) : accentPurple
                                    radius: 18
                                }
                                contentItem: Text { text: "+"; color: "white"; font.pixelSize: 20; anchors.centerIn: parent }
                                onClicked: {
                                    var qty = parseInt(qtyInput.text) || 1
                                    posBackend.addProductToCart(codigo, qty)
                                    qtyInput.text = "1"
                                }
                            }
                        }
                    }
                }
            }
        }

        // ============================================================
        // 🛒 PANEL DERECHO
        // ============================================================
        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 4
            spacing: 16

            // Tarjeta Usuario
            Rectangle {
                Layout.fillWidth: true; height: 80
                color: bgPrimary; radius: 12; border.color: borderLight; border.width: 1
                RowLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 12
                    Rectangle { width: 40; height: 40; radius: 20; color: "#E0E7FF"
                        Label { text: "👤"; anchors.centerIn: parent; font.pixelSize: 20 }
                    }
                    Column {
                        Label { text: "Cajero: " + posBackend.currentUserName; font.bold: true; color: textDark }
                        Label { text: "Sucursal: Tonalá Centro"; font.pixelSize: 12; color: textMedium }
                    }
                    Item { Layout.fillWidth: true }
                    Label { text: new Date().toLocaleDateString(); font.pixelSize: 12; color: textMedium }
                }
            }

            // Carrito y Cliente
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: bgPrimary; radius: 12; border.color: borderLight; border.width: 1

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 16; spacing: 10

                    Label { text: "Cliente del Pedido"; font.pixelSize: 12; color: textMedium }
                    
                    // --- COMBOBOX CORREGIDO (Popup Blanco) ---
                    ComboBox {
                        id: clientSelector
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        model: posBackend.clientsModel
                        textRole: "nombre"
                        
                        background: Rectangle {
                            color: bgSecondary; radius: 8; border.color: borderLight; border.width: 1
                        }
                        contentItem: Text {
                            leftPadding: 10
                            text: parent.displayText
                            font.pixelSize: 14
                            color: textDark // <-- Importante
                            verticalAlignment: Text.AlignVCenter
                        }
                        delegate: ItemDelegate {
                            width: clientSelector.width
                            contentItem: Text {
                                text: modelData.nombre
                                color: textDark
                                font.pixelSize: 14
                                verticalAlignment: Text.AlignVCenter
                            }
                            background: Rectangle { color: parent.highlighted ? "#E0E7FF" : "white" }
                        }
                        popup: Popup {
                            y: clientSelector.height - 1
                            width: clientSelector.width
                            implicitHeight: contentItem.implicitHeight
                            padding: 1
                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: clientSelector.popup.visible ? clientSelector.delegateModel : null
                                currentIndex: clientSelector.highlightedIndex
                                ScrollIndicator.vertical: ScrollIndicator { }
                            }
                            background: Rectangle { color: "white"; border.color: borderLight; radius: 8 }
                        }
                        onActivated: (index) => { posBackend.selectClient(index) }
                    }
                    
                    Rectangle { Layout.fillWidth: true; height: 1; color: borderLight; Layout.topMargin: 8 }

                    Label { text: "Items en Carrito"; font.bold: true; font.pixelSize: 14; color: textDark }

                    ListView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        clip: true; model: posBackend.cartModel; spacing: 8
                        delegate: Rectangle {
                            width: parent.width; height: 40; color: "transparent"
                            RowLayout {
                                anchors.fill: parent
                                Label { text: cantidad + "x"; color: accentPurple; font.bold: true; Layout.preferredWidth: 30 }
                                Label { text: nombre; color: textDark; Layout.fillWidth: true; elide: Text.ElideRight }
                                Label { text: total; color: textDark; font.bold: true }
                                Button {
                                    width: 24; height: 24; flat: true
                                    contentItem: Text { text: "✕"; color: dangerRed; anchors.centerIn: parent }
                                    background: Rectangle { color: "transparent" }
                                    onClicked: posBackend.removeFromCart(index)
                                }
                            }
                        }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: borderLight }

                    RowLayout {
                        Layout.fillWidth: true
                        Label { text: "Total a Pagar"; font.pixelSize: 18; font.bold: true; color: textDark }
                        Item { Layout.fillWidth: true }
                        Label { text: "$" + posBackend.total.toFixed(2); font.pixelSize: 24; font.bold: true; color: accentPurple }
                    }

                    Button {
                        Layout.fillWidth: true; Layout.preferredHeight: 50
                        background: Rectangle { color: accentPurple; radius: 8 }
                        contentItem: Text { text: "CONFIRMAR VENTA"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: posBackend.checkout()
                    }
                }
            }
        }
    }
}