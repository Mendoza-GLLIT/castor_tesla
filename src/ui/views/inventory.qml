import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    // Colores
    readonly property color bgPrimary: "#FFFFFF"
    readonly property color bgSecondary: "#F9FAFB"
    readonly property color borderLight: "#E5E7EB"
    readonly property color textDark: "#111827"
    readonly property color textMedium: "#6B7280"
    readonly property color accentPurple: "#6366F1"

    // Diálogos (Asumiendo que estos componentes existen en tu proyecto)
    NewProductDialog { id: myNewProductDialog }
    StockAdjustmentDialog { id: myStockDialog }

    // Diálogo de Eliminación
    Dialog {
        id: deleteDialog
        title: "Eliminar Producto"
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No
        property var prodToDelete: null
        
        background: Rectangle { color: "white"; radius: 8; border.color: borderLight }
        contentItem: ColumnLayout {
            Label { 
                text: "¿Estás seguro de eliminar este producto?\nSi tiene ventas históricas, fallará." 
                color: textDark; padding: 20 
            }
        }
        onAccepted: {
            if (prodToDelete) inventoryCtrl.delete_product(prodToDelete.id_producto)
        }
    }

    // Componente Botón Redondeado
    component RoundedButton: Button {
        id: control
        property color btnColor: accentPurple
        property color btnTextColor: "white"
        font.pixelSize: 14; font.weight: Font.Medium
        leftPadding: 20; rightPadding: 20; topPadding: 10; bottomPadding: 10
        background: Rectangle {
            color: control.down ? Qt.darker(control.btnColor, 1.1) : (control.hovered ? Qt.lighter(control.btnColor, 1.1) : control.btnColor)
            radius: 8
        }
        contentItem: Text {
            text: control.text; font: control.font; color: control.btnTextColor
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        }
        MouseArea { 
            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
            onPressed: (mouse) => { mouse.accepted = false } 
        }
    }

    // UI Principal
    Rectangle {
        anchors.fill: parent; color: bgSecondary

        Rectangle {
            width: Math.min(parent.width - 48, 1200) 
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.margins: 24
            color: bgPrimary; radius: 12
            border.color: borderLight; border.width: 1; clip: true

            ColumnLayout {
                anchors.fill: parent; anchors.margins: 24; spacing: 24

                // Cabecera y Buscador
                ColumnLayout {
                    Layout.fillWidth: true; spacing: 16
                    RowLayout {
                        Layout.fillWidth: true; spacing: 16
                        Label { text: "Productos"; font.pixelSize: 24; font.weight: Font.Bold; color: textDark; Layout.fillWidth: true }
                        RoundedButton { text: "+ Nuevo Producto"; onClicked: myNewProductDialog.openForCreate() }
                        RoundedButton { text: "📦 Ajustar Stock"; btnColor: "#10B981"; onClicked: myStockDialog.open() }
                    }
                    RowLayout {
                        Layout.fillWidth: true; spacing: 16
                        Rectangle {
                            Layout.preferredWidth: 320; Layout.preferredHeight: 42
                            color: bgSecondary; radius: 8; border.color: borderLight; border.width: 1
                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 8
                                Text { text: "🔍"; font.pixelSize: 16; color: textMedium }
                                TextField {
                                    id: searchField
                                    placeholderText: "Buscar por nombre, código..."
                                    placeholderTextColor: textMedium
                                    font.pixelSize: 14; color: textDark; background: null
                                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter
                                    onTextChanged: productsModel.filter(text)
                                }
                            }
                        }
                    }
                }
                
                // TABLA CORREGIDA
                ColumnLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

                    // 1. Encabezados
                    Rectangle {
                        Layout.fillWidth: true; height: 48; color: bgSecondary
                        Rectangle { width: parent.width; height: 1; color: borderLight; anchors.bottom: parent.bottom }
                        RowLayout {
                            anchors.fill: parent; spacing: 0
                            // NOTA: Todos los encabezados tienen Layout.fillWidth: true para definir la grilla
                            Label { text: "CÓDIGO"; font.weight: Font.DemiBold; color: textMedium; Layout.preferredWidth: 1.5; Layout.fillWidth: true; leftPadding: 16 }
                            Label { text: "PRODUCTO"; font.weight: Font.DemiBold; color: textMedium; Layout.preferredWidth: 3; Layout.fillWidth: true; leftPadding: 16 }
                            Label { text: "DESCRIPCIÓN"; font.weight: Font.DemiBold; color: textMedium; Layout.preferredWidth: 4; Layout.fillWidth: true; leftPadding: 16 }
                            Label { text: "PRECIO"; font.weight: Font.DemiBold; color: textMedium; Layout.preferredWidth: 1.5; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight; rightPadding: 16 }
                            Label { text: "STOCK"; font.weight: Font.DemiBold; color: textMedium; Layout.preferredWidth: 1.5; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight; rightPadding: 32 }
                            Label { text: "ACCIONES"; font.weight: Font.DemiBold; color: textMedium; Layout.preferredWidth: 1.5; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight; rightPadding: 16 }
                        }
                    }

                    // 2. Lista (Rows)
                    ListView {
                        id: productList
                        Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                        model: productsModel
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            width: productList.width; height: 64; color: bgPrimary
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: borderLight }
                            
                            RowLayout {
                                anchors.fill: parent; spacing: 0
                                
                                // Col 1: CÓDIGO (1.5)
                                Label { 
                                    text: model.codigo 
                                    font.weight: Font.Medium; color: textDark 
                                    Layout.preferredWidth: 1.5; Layout.fillWidth: true; leftPadding: 16 
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                // Col 2: PRODUCTO (3)
                                Column {
                                    Layout.preferredWidth: 3; Layout.fillWidth: true; leftPadding: 16 
                                    Layout.alignment: Qt.AlignVCenter
                                    Label { text: model.nombre; font.weight: Font.Medium; color: textDark; width: parent.width - 32; elide: Text.ElideRight }
                                    Label { text: "Electrónica"; font.pixelSize: 12; color: textMedium }
                                }
                                
                                // Col 3: DESCRIPCIÓN (4)
                                Label { 
                                    text: model.descripcion ? model.descripcion : "---"
                                    color: textMedium; 
                                    Layout.preferredWidth: 4; Layout.fillWidth: true 
                                    leftPadding: 16; elide: Text.ElideRight 
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                // Col 4: PRECIO (1.5)
                                Label { 
                                    text: model.precio 
                                    font.weight: Font.Medium; color: textDark 
                                    Layout.preferredWidth: 1.5; Layout.fillWidth: true 
                                    horizontalAlignment: Text.AlignRight; rightPadding: 16 
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                // Col 5: STOCK (1.5) - Alineado a la derecha usando Spacer
                                RowLayout {
                                    Layout.preferredWidth: 1.5; Layout.fillWidth: true 
                                    spacing: 8 
                                    
                                    // Espaciador: Empuja el contenido a la derecha sin romper la celda
                                    Item { Layout.fillWidth: true } 
                                    
                                    Rectangle { width: 8; height: 8; radius: 4; color: model.stock > 10 ? "#10B981" : (model.stock > 0 ? "#F59E0B" : "#EF4444") }
                                    
                                    Label { 
                                        text: model.stock + " un."; 
                                        font.weight: Font.Medium; color: textDark 
                                        rightPadding: 32 // Coincide con el header
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                // Col 6: ACCIONES (1.5) - Alineado a la derecha usando Spacer
                                RowLayout {
                                    Layout.preferredWidth: 1.5; Layout.fillWidth: true
                                    spacing: 0
                                    
                                    // Espaciador
                                    Item { Layout.fillWidth: true }
                                    
                                    Row {
                                        spacing: 8
                                        rightPadding: 16 // Coincide con el header
                                        
                                        Button {
                                            text: "✎"; width: 32; height: 32
                                            background: Rectangle { color: parent.hovered ? "#DBEAFE" : "transparent"; radius: 6; border.color: "#BFDBFE" }
                                            contentItem: Text { text: parent.text; color: "#2563EB"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                            onClicked: myNewProductDialog.openForEdit(model)
                                        }
                                        
                                        Button {
                                            text: "🗑"; width: 32; height: 32
                                            background: Rectangle { color: parent.hovered ? "#FEE2E2" : "transparent"; radius: 6; border.color: "#FECACA" }
                                            contentItem: Text { text: parent.text; color: "#DC2626"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                            onClicked: { deleteDialog.prodToDelete = model; deleteDialog.open() }
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