import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Dialog {
    id: root
    modal: true
    width: 480
    height: 650
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    closePolicy: Popup.NoAutoClose
    standardButtons: Dialog.NoButton

    // Propiedades
    property bool isEditing: false
    property int currentUserId: 0
    property var backendReference: null

    // --- ESTILOS ---
    readonly property color bgPrimary: "#FFFFFF"
    readonly property color bgSecondary: "#F9FAFB"
    readonly property color borderLight: "#D1D5DB"
    readonly property color textDark: "#111827"
    readonly property color textMedium: "#6B7280"
    readonly property color accentPurple: "#6366F1"

    background: Rectangle {
        color: bgPrimary
        radius: 12
        border.color: borderLight
        border.width: 1
        layer.enabled: true
    }

    // --- FUNCIONES ---
    function openForCreate() {
        isEditing = false
        currentUserId = 0
        fName.text = ""; fLast.text = ""; fUser.text = ""; fEmail.text = ""; fPass.text = ""
        roleCombo.currentIndex = 0
        root.open()
    }

    function openForEdit(user) {
        isEditing = true
        currentUserId = user.id
        fName.text = user.nombre
        fLast.text = user.apellido
        fUser.text = user.username
        fEmail.text = user.email
        fPass.text = user.password
        
        for(var i=0; i<roleCombo.count; i++) {
            var roleItem = backendReference.rolesModel[i]
            if (roleItem && roleItem.id === user.id_rol) {
                roleCombo.currentIndex = i
                break
            }
        }
        root.open()
    }

    function saveUser() {
        if (fName.text === "" || fUser.text === "") {
            console.log("⚠️ Faltan datos")
            fName.field.forceActiveFocus()
            return
        }
        
        var selectedRoleIndex = roleCombo.currentIndex
        var selectedRoleId = backendReference.rolesModel[selectedRoleIndex].id

        if (isEditing) {
            backendReference.updateUser(currentUserId, fUser.text, fName.text, fLast.text, fEmail.text, fPass.text, selectedRoleId)
        } else {
            backendReference.createUser(fUser.text, fName.text, fLast.text, fEmail.text, fPass.text, selectedRoleId)
        }
        root.close()
    }

    // --- COMPONENTE INTERNO: CAMPO DE TEXTO ---
    component StyledField: Column {
        property alias label: lbl.text
        property alias text: txt.text
        property alias placeholder: txt.placeholderText
        property bool isPassword: false
        property alias field: txt
        
        spacing: 6
        
        Label { id: lbl; font.weight: Font.DemiBold; color: textDark; font.pixelSize: 13 }
        
        TextField {
            id: txt
            width: parent.width 
            height: 42
            font.pixelSize: 14
            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 12; rightPadding: 12
            placeholderTextColor: textMedium
            color: textDark
            echoMode: isPassword ? TextInput.Password : TextInput.Normal
            
            background: Rectangle {
                color: bgSecondary
                radius: 8
                border.color: txt.activeFocus ? accentPurple : borderLight
                border.width: 1
            }
        }
    }

    // --- CONTENIDO ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 0

        // 1. CABECERA
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#EEF2FF"
            radius: 12
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 12; color: parent.color }
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 15
                
                Rectangle {
                    width: 32; height: 32; radius: 16; color: "white"
                    Label { text: isEditing ? "✏️" : "👤"; anchors.centerIn: parent; font.pixelSize: 18 }
                }
                
                ColumnLayout {
                    spacing: 0
                    Label { 
                        text: isEditing ? "Editar Empleado" : "Nuevo Empleado"
                        font.pixelSize: 16; font.bold: true; color: "#3730A3"
                    }
                    Label { 
                        text: "Gestiona los accesos al sistema"
                        font.pixelSize: 12; color: "#6366F1" 
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "✕"
                    flat: true
                    Layout.preferredWidth: 30; Layout.preferredHeight: 30
                    background: Rectangle { color: parent.hovered ? "#E0E7FF" : "transparent"; radius: 15 }
                    contentItem: Text { text: parent.text; color: "#3730A3"; font.bold: true; anchors.centerIn: parent }
                    onClicked: root.close()
                }
            }
            Rectangle { width: parent.width; height: 1; color: "#E0E7FF"; anchors.bottom: parent.bottom }
        }

        // 2. FORMULARIO SCROLLABLE
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: parent.width
            
            ColumnLayout {
                width: parent.width - 48
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: 20
                spacing: 16

                // --- FILA MICHA Y MICHA (Manual) ---
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 15
                    
                    // Calculamos el ancho exacto: (AnchoTotal - Espacio) / 2
                    property real halfWidth: (parent.width - spacing) / 2

                    StyledField { 
                        id: fName
                        label: "Nombre"
                        placeholder: "Ej. Juan"
                        // AQUÍ ESTÁ EL CAMBIO: Ancho preferido explícito
                        Layout.preferredWidth: parent.halfWidth
                        Layout.fillWidth: true 
                    }
                    
                    StyledField { 
                        id: fLast
                        label: "Apellido"
                        placeholder: "Ej. Perez"
                        // AQUÍ TAMBIÉN
                        Layout.preferredWidth: parent.halfWidth
                        Layout.fillWidth: true 
                    }
                }
                // ------------------------------------

                StyledField { id: fUser; label: "Usuario (Login)"; placeholder: "Ej. jperez"; Layout.fillWidth: true }
                StyledField { id: fEmail; label: "Email"; placeholder: "correo@castor.com"; Layout.fillWidth: true }
                StyledField { id: fPass; label: "Contraseña"; isPassword: true; placeholder: "******"; Layout.fillWidth: true }

                Column {
                    spacing: 6
                    Layout.fillWidth: true
                    Label { text: "Rol / Puesto"; font.weight: Font.DemiBold; color: textDark; font.pixelSize: 13 }
                    
                    ComboBox {
                        id: roleCombo
                        width: parent.width
                        height: 42
                        textRole: "nombre"
                        valueRole: "id"
                        model: backendReference ? backendReference.rolesModel : []
                        
                        background: Rectangle {
                            color: bgSecondary
                            radius: 8
                            border.color: parent.activeFocus ? accentPurple : borderLight
                            border.width: 1
                        }
                        contentItem: Text {
                            leftPadding: 12
                            text: parent.displayText
                            font.pixelSize: 14
                            color: textDark
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
                
                Item { height: 20; Layout.fillWidth: true }
            }
        }

        // 3. FOOTER
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            
            Rectangle { Layout.fillWidth: true; height: 1; color: borderLight }
            
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 20
                spacing: 12

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
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

                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45
                    background: Rectangle {
                        color: parent.down ? Qt.darker(accentPurple, 1.1) : accentPurple
                        radius: 8
                    }
                    contentItem: Text {
                        text: "Guardar Datos"; color: "white"; font.bold: true
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: saveUser()
                }
            }
        }
    }
}