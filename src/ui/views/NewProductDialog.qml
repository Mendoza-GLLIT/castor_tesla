import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Dialog {
    id: root
    modal: true
    width: 480; height: 580
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    closePolicy: Popup.NoAutoClose
    standardButtons: Dialog.NoButton

    property bool isEditing: false
    property int currentProdId: 0

    readonly property color bgPrimary: "#FFFFFF"
    readonly property color bgSecondary: "#F9FAFB"
    readonly property color borderLight: "#D1D5DB"
    readonly property color textDark: "#111827"
    readonly property color accentPurple: "#6366F1"

    background: Rectangle { color: bgPrimary; radius: 12; border.color: borderLight; border.width: 1 }

    function openForCreate() {
        isEditing = false; currentProdId = 0
        fName.text = ""; fDesc.text = ""; fPrice.text = ""; fStock.text = ""
        root.open()
    }

    function openForEdit(prod) {
        isEditing = true; currentProdId = prod.id_producto
        fName.text = prod.nombre
        fDesc.text = prod.descripcion
        fPrice.text = prod.precio.replace("$", "")
        fStock.text = prod.stock
        root.open()
    }

    function save() {
        if (fName.text === "") { fName.field.forceActiveFocus(); return }
        if (isEditing) {
            inventoryCtrl.update_product(currentProdId, fName.text, fDesc.text, fPrice.text, 0)
        } else {
            inventoryCtrl.create_product(fName.text, fDesc.text, fPrice.text, parseInt(fStock.text))
        }
        root.close()
    }

    component StyledField: Column {
        property alias label: lbl.text
        property alias text: txt.text
        property alias field: txt
        spacing: 6
        Label { id: lbl; font.weight: Font.DemiBold; color: root.textDark; font.pixelSize: 13 }
        TextField {
            id: txt; width: parent.width; height: 42; font.pixelSize: 14; color: root.textDark
            background: Rectangle { color: root.bgSecondary; radius: 8; border.color: txt.activeFocus ? root.accentPurple : root.borderLight; border.width: 1 }
        }
    }

    ColumnLayout {
        anchors.fill: parent; spacing: 0

        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 60; color: "#EEF2FF"; radius: 12
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 12; color: parent.color }
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 15
                Label { text: isEditing ? "✏️" : "📦"; font.pixelSize: 22 }
                ColumnLayout {
                    spacing: 0
                    Label { text: isEditing ? "Editar Producto" : "Nuevo Producto"; font.bold: true; font.pixelSize: 16; color: "#3730A3" }
                    Label { text: "Gestión de catálogo"; font.pixelSize: 12; color: "#6366F1" }
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "✕"; flat: true; onClicked: root.close()
                    background: Rectangle { color: "transparent" }
                    contentItem: Text { text: parent.text; color: "#3730A3"; font.bold: true; anchors.centerIn: parent }
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; contentWidth: parent.width
            ColumnLayout {
                width: parent.width - 48; anchors.horizontalCenter: parent.horizontalCenter; anchors.topMargin: 20; spacing: 16

                StyledField { id: fName; label: "Nombre del Producto"; Layout.fillWidth: true }
                StyledField { id: fDesc; label: "Descripción / Detalles"; Layout.fillWidth: true }

                RowLayout {
                    Layout.fillWidth: true; spacing: 15
                    property real half: (parent.width - spacing) / 2

                    StyledField {
                        id: fPrice; label: "Precio Unitario ($)"
                        Layout.preferredWidth: parent.half; Layout.fillWidth: true
                    }

                    StyledField {
                        id: fStock
                        label: "Stock Inicial"
                        visible: !isEditing
                        Layout.preferredWidth: isEditing ? 0 : parent.half
                        Layout.fillWidth: true
                        opacity: isEditing ? 0 : 1
                    }
                }
            }
        }

        Rectangle { Layout.fillWidth: true; height: 1; color: borderLight }

        RowLayout {
            Layout.fillWidth: true; Layout.margins: 20; spacing: 12
            Button {
                Layout.fillWidth: true; Layout.preferredHeight: 45; flat: true; onClicked: root.close()
                background: Rectangle { color: parent.down ? "#F3F4F6" : "white"; radius: 8; border.color: borderLight; border.width: 1 }
                contentItem: Text { text: "Cancelar"; color: textDark; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            Button {
                Layout.fillWidth: true; Layout.preferredHeight: 45; onClicked: save()
                background: Rectangle { color: accentPurple; radius: 8 }
                contentItem: Text { text: "Guardar"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }
    }
}
