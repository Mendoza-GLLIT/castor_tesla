import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Dialog {
    id: root
    modal: true
    width: 480
    height: 600
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    closePolicy: Popup.NoAutoClose
    standardButtons: Dialog.NoButton

    property bool isEditing: false
    property int currentClientId: 0
    property var backendReference: null

    // --- ESTILOS ---
    readonly property color bgPrimary: "#FFFFFF"
    readonly property color bgSecondary: "#F9FAFB"
    readonly property color borderLight: "#D1D5DB"
    readonly property color textDark: "#111827"
    readonly property color textMedium: "#6B7280"
    readonly property color accentPurple: "#6366F1"

    background: Rectangle {
        color: bgPrimary; radius: 12; border.color: borderLight; border.width: 1
    }

    // --- COMPONENTE INTERNO (Definido AQUÍ para que vea las propiedades) ---
    component StyledField: Column {
        property alias label: lbl.text
        property alias text: txt.text
        property alias placeholder: txt.placeholderText
        property alias field: txt
        
        spacing: 6
        
        Label { 
            id: lbl
            font.weight: Font.DemiBold
            // Usamos root.textDark para ser explícitos
            color: root.textDark 
            font.pixelSize: 13 
        }
        
        TextField {
            id: txt
            width: parent.width
            height: 42
            font.pixelSize: 14
            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 12; rightPadding: 12
            color: root.textDark
            placeholderTextColor: root.textMedium
            
            background: Rectangle { 
                color: root.bgSecondary
                radius: 8
                border.color: txt.activeFocus ? root.accentPurple : root.borderLight
                border.width: 1 
            }
        }
    }

    // --- LÓGICA ---
    function openForCreate() {
        isEditing = false
        currentClientId = 0
        fName.text = ""; fRfc.text = ""; fDir.text = ""; fTel.text = ""; fEmail.text = ""
        root.open()
    }

    function openForEdit(client) {
        isEditing = true
        currentClientId = client.id
        fName.text = client.nombre
        fRfc.text = client.rfc
        fDir.text = client.direccion
        fTel.text = client.telefono
        fEmail.text = client.email
        root.open()
    }

    function saveClient() {
        if (fName.text === "") {
            fName.field.forceActiveFocus()
            return
        }
        if (isEditing) {
            backendReference.updateClient(currentClientId, fName.text, fRfc.text, fDir.text, fTel.text, fEmail.text)
        } else {
            backendReference.createClient(fName.text, fRfc.text, fDir.text, fTel.text, fEmail.text)
        }
        root.close()
    }

    // --- UI PRINCIPAL ---
    ColumnLayout {
        anchors.fill: parent; spacing: 0

        // Cabecera
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 60; color: "#EEF2FF"; radius: 12
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 12; color: parent.color }
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 15
                Label { text: isEditing ? "✏️" : "👤"; font.pixelSize: 22 }
                ColumnLayout {
                    spacing: 0
                    Label { text: isEditing ? "Editar Cliente" : "Nuevo Cliente"; font.pixelSize: 16; font.bold: true; color: "#3730A3" }
                    Label { text: "Datos de contacto y facturación"; font.pixelSize: 12; color: "#6366F1" }
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "✕"; flat: true; Layout.preferredWidth: 30; Layout.preferredHeight: 30
                    background: Rectangle { color: "transparent" }
                    contentItem: Text { text: parent.text; color: "#3730A3"; font.bold: true; anchors.centerIn: parent }
                    onClicked: root.close()
                }
            }
        }

        // Formulario
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; contentWidth: parent.width
            ColumnLayout {
                width: parent.width - 48; anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: 20; spacing: 16

                StyledField { id: fName; label: "Nombre Empresa / Cliente"; placeholder: "Ej. Abarrotes Don Pepe"; Layout.fillWidth: true }
                
                RowLayout {
                    Layout.fillWidth: true; spacing: 15
                    property real halfWidth: (parent.width - spacing) / 2
                    
                    StyledField { 
                        id: fRfc; label: "RFC"
                        placeholder: "XAXX010101000"
                        // Forzamos el ancho calculado
                        Layout.preferredWidth: parent.halfWidth 
                        Layout.fillWidth: true 
                    }
                    
                    StyledField { 
                        id: fTel; label: "Teléfono"
                        placeholder: "33 1234 5678"
                        Layout.preferredWidth: parent.halfWidth
                        Layout.fillWidth: true 
                    }
                }

                StyledField { id: fEmail; label: "Email"; placeholder: "contacto@cliente.com"; Layout.fillWidth: true }
                StyledField { id: fDir; label: "Dirección"; placeholder: "Calle, Número, Colonia, CP"; Layout.fillWidth: true }
                
                Item { height: 20; Layout.fillWidth: true }
            }
        }

        // Footer
        Rectangle { Layout.fillWidth: true; height: 1; color: borderLight }
        RowLayout {
            Layout.fillWidth: true; Layout.margins: 20; spacing: 12
            Button {
                Layout.fillWidth: true; Layout.preferredHeight: 45; flat: true
                background: Rectangle { color: parent.down ? "#F3F4F6" : "white"; radius: 8; border.color: borderLight; border.width: 1 }
                contentItem: Text { text: "Cancelar"; color: textMedium; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: root.close()
            }
            Button {
                Layout.fillWidth: true; Layout.preferredHeight: 45
                background: Rectangle { color: accentPurple; radius: 8 }
                contentItem: Text { text: "Guardar Datos"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: saveClient()
            }
        }
    }
}