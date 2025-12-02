import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    // Propiedades para el manejo del formulario
    property bool isEditing: false
    property int currentUserId: 0

    // --- CONFIGURACIÓN DE COLUMNAS (Para alineación perfecta) ---
    // Definimos porcentajes del ancho total disponible
    property real colNameWidth: 0.35  // 35%
    property real colUserWidth: 0.20  // 20%
    property real colRoleWidth: 0.20  // 20%
    // El resto será para Acciones

    // Componente reutilizable para campos de texto
    component FormField: ColumnLayout {
        property alias label: lbl.text
        property alias text: txt.text
        property alias placeholder: txt.placeholderText
        property bool isPassword: false
        spacing: 4
        Label { id: lbl; color: "#374151"; font.bold: true }
        TextField {
            id: txt
            Layout.fillWidth: true
            echoMode: isPassword ? TextInput.Password : TextInput.Normal
            background: Rectangle {
                color: "white"; radius: 6; border.color: "#D1D5DB"; border.width: 1
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#F9FAFB" // Fondo gris muy claro

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // --- ENCABEZADO SUPERIOR ---
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Gestión de Empleados"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#111827"
                    Layout.fillWidth: true
                }

                Button {
                    text: "+ Nuevo Empleado"
                    font.bold: true
                    background: Rectangle { color: "#6366F1"; radius: 8 }
                    contentItem: Text { 
                        text: parent.text; color: "white"; font.bold: true 
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter 
                    }
                    onClicked: openModalForCreate()
                }
            }

            // --- TABLA DE USUARIOS ---
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "white"
                radius: 12
                border.color: "#E5E7EB"
                clip: true

                // 1. CABECERA DE LA TABLA
                Rectangle {
                    id: tableHeader
                    width: parent.width
                    height: 50
                    color: "#F3F4F6"
                    z: 10
                    
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 24
                        anchors.rightMargin: 24
                        spacing: 10

                        Label { 
                            text: "NOMBRE"
                            color: "#6B7280"; font.bold: true; font.pixelSize: 12
                            Layout.preferredWidth: root.width * root.colNameWidth
                        }
                        Label { 
                            text: "USUARIO"
                            color: "#6B7280"; font.bold: true; font.pixelSize: 12
                            Layout.preferredWidth: root.width * root.colUserWidth
                        }
                        Label { 
                            text: "ROL"
                            color: "#6B7280"; font.bold: true; font.pixelSize: 12
                            Layout.preferredWidth: root.width * root.colRoleWidth
                        }
                        Label { 
                            text: "ACCIONES"
                            color: "#6B7280"; font.bold: true; font.pixelSize: 12
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#E5E7EB" }
                }

                // 2. LISTA DE DATOS
                ListView {
                    id: usersList
                    anchors.top: tableHeader.bottom
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    model: employersBackend.usersModel
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: usersList.width
                        height: 70
                        color: index % 2 === 0 ? "white" : "#FAFAFA"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 24
                            anchors.rightMargin: 24
                            spacing: 10

                            // COLUMNA NOMBRE
                            Column {
                                Layout.preferredWidth: root.width * root.colNameWidth
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2
                                Label { 
                                    text: modelData.nombre + " " + modelData.apellido 
                                    font.bold: true; color: "#1F2937"; font.pixelSize: 14 
                                    elide: Text.ElideRight; width: parent.width
                                }
                                Label { 
                                    text: modelData.email
                                    font.pixelSize: 12; color: "#6B7280"
                                    elide: Text.ElideRight; width: parent.width
                                }
                            }
                            
                            // COLUMNA USUARIO
                            Label { 
                                text: modelData.username
                                color: "#374151"; font.pixelSize: 14
                                Layout.preferredWidth: root.width * root.colUserWidth
                                Layout.alignment: Qt.AlignVCenter
                            }
                            
                            // COLUMNA ROL (Badge)
                            Item {
                                Layout.preferredWidth: root.width * root.colRoleWidth
                                Layout.alignment: Qt.AlignVCenter
                                height: 26
                                
                                Rectangle {
                                    anchors.left: parent.left
                                    height: parent.height
                                    width: roleLabel.implicitWidth + 24
                                    radius: 13
                                    color: getRolColor(modelData.nombre_rol)
                                    
                                    Label { 
                                        id: roleLabel
                                        text: modelData.nombre_rol
                                        anchors.centerIn: parent
                                        color: getRolTextColor(modelData.nombre_rol)
                                        font.pixelSize: 12; font.bold: true
                                    }
                                }
                            }

                            // COLUMNA ACCIONES
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                spacing: 8
                                
                                Button {
                                    text: "✎"
                                    Layout.preferredWidth: 36; Layout.preferredHeight: 36
                                    background: Rectangle { color: parent.hovered ? "#DBEAFE" : "transparent"; radius: 6; border.color: "#BFDBFE" }
                                    contentItem: Text { text: parent.text; color: "#2563EB"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: openModalForEdit(modelData)
                                    ToolTip.visible: hovered; ToolTip.text: "Editar"
                                }
                                
                                Button {
                                    text: "🗑"
                                    Layout.preferredWidth: 36; Layout.preferredHeight: 36
                                    background: Rectangle { color: parent.hovered ? "#FEE2E2" : "transparent"; radius: 6; border.color: "#FECACA" }
                                    contentItem: Text { text: parent.text; color: "#DC2626"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: confirmDelete(modelData)
                                    ToolTip.visible: hovered; ToolTip.text: "Eliminar"
                                }
                            }
                        }
                        
                        // Separador sutil
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F3F4F6" }
                    }
                }
            }
        }
    }

    // --- POPUP: FORMULARIO ---
    Popup {
        id: userPopup
        anchors.centerIn: parent
        width: 450
        height: 550 // Altura fija suficiente
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape
        
        background: Rectangle { radius: 12; color: "white"; border.color: "#E5E7EB"; border.width: 1 }

        // overlay: Rectangle { color: "#00000080" } // Oscurecer fondo (requiere QtQuick.Controls.Basic o Fusion)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16

            Label {
                text: isEditing ? "Editar Empleado" : "Crear Nuevo Empleado"
                font.pixelSize: 20; font.bold: true; color: "#111827"
                Layout.alignment: Qt.AlignHCenter
            }

            GridLayout {
                columns: 2
                rowSpacing: 10
                columnSpacing: 10
                Layout.fillWidth: true

                FormField { id: fName; label: "Nombre"; placeholder: "Ej. Juan"; Layout.columnSpan: 1; Layout.fillWidth: true }
                FormField { id: fLast; label: "Apellido"; placeholder: "Ej. Perez"; Layout.columnSpan: 1; Layout.fillWidth: true }
            }

            FormField { id: fUser; label: "Usuario (Login)"; placeholder: "Ej. jperez"; Layout.fillWidth: true }
            FormField { id: fEmail; label: "Email"; placeholder: "correo@castor.com"; Layout.fillWidth: true }
            FormField { id: fPass; label: "Contraseña"; isPassword: true; placeholder: "******"; Layout.fillWidth: true }

            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true
                Label { text: "Rol / Puesto"; color: "#374151"; font.bold: true }
                ComboBox {
                    id: roleCombo
                    Layout.fillWidth: true
                    textRole: "nombre"
                    valueRole: "id"
                    model: employersBackend.rolesModel // Modelo desde Python
                }
            }

            Item { Layout.fillHeight: true } // Espaciador

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    text: "Cancelar"
                    Layout.fillWidth: true
                    onClicked: userPopup.close()
                }
                
                Button {
                    text: "Guardar"
                    Layout.fillWidth: true
                    background: Rectangle { color: "#6366F1"; radius: 6 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: saveUser()
                }
            }
        }
    }

    // --- DIALOGO CONFIRMACION BORRAR ---
    Dialog {
        id: deleteDialog
        title: "Confirmar eliminación"
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No
        property var userToDelete: null

        Text { text: "¿Estás seguro de que deseas eliminar este usuario?"; color: "black"; leftPadding: 20; rightPadding: 20 }

        onAccepted: {
            if (userToDelete) {
                employersBackend.deleteUser(userToDelete.id)
            }
        }
    }

    // --- FUNCIONES LÓGICAS (Sin cambios) ---
    function getRolColor(rolName) {
        if (rolName === "Administrador") return "#DBEAFE" // Azul suave
        if (rolName === "Vendedor") return "#D1FAE5" // Verde suave
        if (rolName === "Contador") return "#FEF3C7" // Amarillo suave
        if (rolName === "Almacenista") return "#F3E8FF" // Morado suave
        return "#F3F4F6"
    }

    function getRolTextColor(rolName) {
        if (rolName === "Administrador") return "#1E40AF"
        if (rolName === "Vendedor") return "#065F46"
        if (rolName === "Contador") return "#92400E"
        if (rolName === "Almacenista") return "#6B21A8"
        return "#374151"
    }

    function openModalForCreate() {
        isEditing = false
        currentUserId = 0
        fName.text = ""; fLast.text = ""; fUser.text = ""; fEmail.text = ""; fPass.text = ""
        roleCombo.currentIndex = 0
        userPopup.open()
    }

    function openModalForEdit(user) {
        isEditing = true
        currentUserId = user.id
        fName.text = user.nombre
        fLast.text = user.apellido
        fUser.text = user.username
        fEmail.text = user.email
        fPass.text = user.password
        
        for(var i=0; i<roleCombo.count; i++) {
            if (roleCombo.model[i].id === user.id_rol) {
                roleCombo.currentIndex = i
                break
            }
        }
        userPopup.open()
    }

    function confirmDelete(user) {
        deleteDialog.userToDelete = user
        deleteDialog.open()
    }

    function saveUser() {
        if (fName.text === "" || fUser.text === "") return
        var selectedRoleId = roleCombo.model[roleCombo.currentIndex].id

        if (isEditing) {
            employersBackend.updateUser(currentUserId, fUser.text, fName.text, fLast.text, fEmail.text, fPass.text, selectedRoleId)
        } else {
            employersBackend.createUser(fUser.text, fName.text, fLast.text, fEmail.text, fPass.text, selectedRoleId)
        }
        userPopup.close()
    }

    Component.onCompleted: employersBackend.refreshData()
}