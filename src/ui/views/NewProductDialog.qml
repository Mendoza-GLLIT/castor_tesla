import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Dialog {
    id: root
    modal: true
    width: 450
    height: 600 // Un poco más alto para la nueva cabecera personalizada
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    // --- TRUCO MAGIA: Quitamos la barra de título de Windows ---
    // Esto elimina la barra negra/fea del sistema
    closePolicy: Popup.NoAutoClose // Controlamos el cierre manualmente
    
    // Quitamos botones nativos
    standardButtons: Dialog.NoButton

    // --- ESTILOS ---
    readonly property color bgPrimary: "#FFFFFF"
    readonly property color bgSecondary: "#F9FAFB"
    readonly property color borderLight: "#D1D5DB" // Gris un poco más oscuro para mejor definición
    readonly property color textDark: "#111827"
    readonly property color textMedium: "#6B7280"
    readonly property color accentPurple: "#6366F1"

    // --- FONDO PRINCIPAL ---
    background: Rectangle {
        color: bgPrimary
        radius: 12
        border.color: borderLight
        border.width: 1
        // Sombra suave para dar profundidad
        layer.enabled: true
    }

    // --- LÓGICA DE GUARDADO ---
    function saveProduct() {
        if (nameField.text === "" || priceField.text === "") {
            console.log("⚠️ Faltan datos")
            nameField.forceActiveFocus()
            return
        }
        inventoryCtrl.create_product(nameField.text, descField.text, priceField.text, stockField.value)
        
        // Limpiar y cerrar
        nameField.text = ""; descField.text = ""; priceField.text = ""; stockField.value = 0
        root.close()
    }

    // --- CONTENIDO ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0 // Sin márgenes globales para que la cabecera toque los bordes
        spacing: 0

        // 1. CABECERA PERSONALIZADA (Reemplaza la barra negra)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#EFF6FF"
            
            // Solo redondeamos las esquinas de arriba
            radius: 12
            Rectangle { 
                anchors.bottom: parent.bottom; width: parent.width; height: 12; color: parent.color 
            } // Parche para que abajo sea recto
            
            border.color: borderLight
            border.width: 0 // El borde lo maneja el padre

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 15
                
                Label { text: "✨"; font.pixelSize: 22 }
                
                ColumnLayout {
                    spacing: 0
                    Label { 
                        text: "Nuevo Producto"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#1E40AF" 
                    }
                    Label { 
                        text: "Ingresa los detalles al inventario"
                        font.pixelSize: 12
                        color: "#60A5FA" 
                    }
                }
                
                Item { Layout.fillWidth: true } // Espaciador
                
                // Botón Cerrar (X) discreto
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
            
            // Línea divisoria abajo
            Rectangle {
                width: parent.width; height: 1; color: "#DBEAFE"
                anchors.bottom: parent.bottom
            }
        }

        // 2. FORMULARIO (Con padding)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 24
            spacing: 20

            // Nombre
            ColumnLayout {
                Layout.fillWidth: true; spacing: 6
                Label { text: "Nombre del Producto"; font.weight: Font.DemiBold; color: textDark }
                TextField { 
                    id: nameField
                    placeholderText: "Ej. Audífonos Bluetooth"
                    Layout.fillWidth: true 
                    font.pixelSize: 14
                    topPadding: 12; bottomPadding: 12; leftPadding: 12
                    background: Rectangle { 
                        color: bgSecondary; radius: 8
                        border.color: parent.activeFocus ? accentPurple : borderLight; border.width: 1 
                    }
                    color: textDark // Forza texto negro
                }
            }

            // Descripción
            ColumnLayout {
                Layout.fillWidth: true; spacing: 6
                Label { text: "Descripción (Opcional)"; font.weight: Font.DemiBold; color: textDark }
                TextField { 
                    id: descField
                    placeholderText: "Marca, modelo, color..."
                    Layout.fillWidth: true 
                    font.pixelSize: 14
                    topPadding: 12; bottomPadding: 12; leftPadding: 12
                    background: Rectangle { 
                        color: bgSecondary; radius: 8
                        border.color: parent.activeFocus ? accentPurple : borderLight; border.width: 1 
                    }
                    color: textDark
                }
            }

            // FILA DOBLE: Precio y Stock
            RowLayout {
                Layout.fillWidth: true
                spacing: 20

                // Precio
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 6
                    Label { text: "Precio Unitario ($)"; font.weight: Font.DemiBold; color: textDark }
                    TextField { 
                        id: priceField
                        placeholderText: "0.00"
                        Layout.fillWidth: true 
                        font.pixelSize: 14
                        topPadding: 12; bottomPadding: 12; leftPadding: 12
                        validator: DoubleValidator { bottom: 0.0; decimals: 2 }
                        background: Rectangle { 
                            color: bgSecondary; radius: 8
                            border.color: parent.activeFocus ? accentPurple : borderLight; border.width: 1 
                        }
                        color: textDark
                    }
                }

                // Stock (SPINBOX PERSONALIZADO PARA QUE NO SEA NEGRO)
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 6
                    Label { text: "Stock Inicial"; font.weight: Font.DemiBold; color: textDark }
                    
                    SpinBox {
                        id: stockField
                        from: 0; to: 9999; editable: true
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46 // Altura igual al TextField

                        // Personalización completa del fondo
                        background: Rectangle {
                            color: bgSecondary
                            border.color: stockField.activeFocus ? accentPurple : borderLight
                            border.width: 1
                            radius: 8
                        }

                        // Personalización del texto (número)
                        contentItem: TextInput {
                            text: stockField.textFromValue(stockField.value, stockField.locale)
                            font: stockField.font
                            color: textDark // <--- ESTO ARREGLA EL TEXTO INVISIBLE/NEGRO
                            selectionColor: accentPurple
                            selectedTextColor: "white"
                            horizontalAlignment: Qt.AlignHCenter
                            verticalAlignment: Qt.AlignVCenter
                            readOnly: !stockField.editable
                            validator: stockField.validator
                            inputMethodHints: Qt.ImhFormattedNumbersOnly
                        }

                        // Botones + y - (Opcional: estilo simple)
                        up.indicator: Rectangle {
                            x: parent.width - width - 1
                            height: parent.height; width: 30
                            color: "transparent"
                            Text { text: "+"; font.pixelSize: 18; color: textMedium; anchors.centerIn: parent }
                        }
                        down.indicator: Rectangle {
                            x: 1
                            height: parent.height; width: 30
                            color: "transparent"
                            Text { text: "-"; font.pixelSize: 18; color: textMedium; anchors.centerIn: parent }
                        }
                    }
                }
            }
            
            // Espacio flexible
            Item { Layout.fillHeight: true }

            // Nota y Botones
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Rectangle { Layout.fillWidth: true; height: 1; color: borderLight }
                
                Label { 
                    text: "ℹ️ El código se generará automáticamente." 
                    font.pixelSize: 12; color: textMedium 
                    Layout.alignment: Qt.AlignHCenter
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Botón Cancelar
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        flat: true
                        background: Rectangle {
                            color: parent.down ? "#F3F4F6" : "white"
                            radius: 8
                            border.color: borderLight; border.width: 1
                        }
                        contentItem: Text {
                            text: "Cancelar"; color: textMedium; font.bold: true
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: root.close()
                    }

                    // Botón Guardar
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 48
                        background: Rectangle {
                            color: parent.down ? Qt.darker(accentPurple, 1.1) : accentPurple
                            radius: 8
                        }
                        contentItem: Text {
                            text: "Guardar Producto"; color: "white"; font.bold: true
                            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: saveProduct()
                    }
                }
            }
        }
    }
}