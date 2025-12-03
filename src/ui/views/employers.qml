import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    // --- CONFIGURACIÓN COLUMNAS ---
    property real colNameWidth: 0.35
    property real colUserWidth: 0.20
    property real colRoleWidth: 0.20

    // --- INSTANCIA DEL FORMULARIO BONITO ---
    EmployeeFormDialog {
        id: employeeForm
        // Pasamos la referencia del backend para que pueda leer roles y guardar
        backendReference: employersBackend 
    }

    // --- DIÁLOGO DE ELIMINAR (Simple) ---
    Dialog {
        id: deleteDialog
        title: "Confirmar eliminación"
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No
        property var userToDelete: null
        
        background: Rectangle { color: "white"; radius: 8; border.color: "#E5E7EB" }

        Text { 
            text: "¿Estás seguro de que deseas eliminar este usuario?"
            color: "#374151"
            topPadding: 20; bottomPadding: 20; leftPadding: 20; rightPadding: 20 
        }

        onAccepted: {
            if (userToDelete) {
                employersBackend.deleteUser(userToDelete.id)
            }
        }
    }

    // --- INTERFAZ PRINCIPAL ---
    Rectangle {
        anchors.fill: parent
        color: "#F9FAFB" // Fondo gris muy claro

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            // --- ENCABEZADO ---
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
                    background: Rectangle { 
                        color: parent.down ? Qt.darker("#6366F1", 1.1) : "#6366F1"
                        radius: 8 
                    }
                    contentItem: Text { 
                        text: parent.text; color: "white"; font.bold: true 
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter 
                    }
                    onClicked: employeeForm.openForCreate()
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

                // 1. CABECERA TABLA
                Rectangle {
                    id: tableHeader
                    width: parent.width; height: 50
                    color: "#F3F4F6"
                    z: 10
                    
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24
                        spacing: 10
                        Label { text: "NOMBRE"; color: "#6B7280"; font.bold: true; font.pixelSize: 12; Layout.preferredWidth: root.width * root.colNameWidth }
                        Label { text: "USUARIO"; color: "#6B7280"; font.bold: true; font.pixelSize: 12; Layout.preferredWidth: root.width * root.colUserWidth }
                        Label { text: "ROL"; color: "#6B7280"; font.bold: true; font.pixelSize: 12; Layout.preferredWidth: root.width * root.colRoleWidth }
                        Label { text: "ACCIONES"; color: "#6B7280"; font.bold: true; font.pixelSize: 12; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#E5E7EB" }
                }

                // 2. LISTA DE DATOS
                ListView {
                    id: usersList
                    anchors.top: tableHeader.bottom; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
                    model: employersBackend.usersModel
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: usersList.width
                        height: 70
                        color: index % 2 === 0 ? "white" : "#FAFAFA"

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 10

                            // Nombre
                            Column {
                                Layout.preferredWidth: root.width * root.colNameWidth
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2
                                Label { text: modelData.nombre + " " + modelData.apellido; font.bold: true; color: "#1F2937"; font.pixelSize: 14; elide: Text.ElideRight; width: parent.width }
                                Label { text: modelData.email; font.pixelSize: 12; color: "#6B7280"; elide: Text.ElideRight; width: parent.width }
                            }
                            
                            // Usuario
                            Label { 
                                text: modelData.username
                                color: "#374151"; font.pixelSize: 14
                                Layout.preferredWidth: root.width * root.colUserWidth
                                Layout.alignment: Qt.AlignVCenter
                            }
                            
                            // Rol (Badge)
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

                            // Acciones
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                spacing: 8
                                
                                Button {
                                    text: "✎"
                                    Layout.preferredWidth: 36; Layout.preferredHeight: 36
                                    background: Rectangle { color: parent.hovered ? "#DBEAFE" : "transparent"; radius: 6; border.color: "#BFDBFE" }
                                    contentItem: Text { text: parent.text; color: "#2563EB"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: employeeForm.openForEdit(modelData)
                                }
                                
                                Button {
                                    text: "🗑"
                                    Layout.preferredWidth: 36; Layout.preferredHeight: 36
                                    background: Rectangle { color: parent.hovered ? "#FEE2E2" : "transparent"; radius: 6; border.color: "#FECACA" }
                                    contentItem: Text { text: parent.text; color: "#DC2626"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: {
                                        deleteDialog.userToDelete = modelData
                                        deleteDialog.open()
                                    }
                                }
                            }
                        }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F3F4F6" }
                    }
                }
            }
        }
    }

    // Funciones de color (Badge)
    function getRolColor(rolName) {
        if (rolName === "Administrador") return "#DBEAFE"
        if (rolName === "Vendedor") return "#D1FAE5"
        if (rolName === "Contador") return "#FEF3C7"
        if (rolName === "Almacenista") return "#F3E8FF"
        return "#F3F4F6"
    }

    function getRolTextColor(rolName) {
        if (rolName === "Administrador") return "#1E40AF"
        if (rolName === "Vendedor") return "#065F46"
        if (rolName === "Contador") return "#92400E"
        if (rolName === "Almacenista") return "#6B21A8"
        return "#374151"
    }

    Component.onCompleted: employersBackend.refreshData()
}