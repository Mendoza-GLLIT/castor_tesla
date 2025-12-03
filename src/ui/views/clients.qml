import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    // Inyectamos el formulario
    ClientFormDialog {
        id: clientForm
        backendReference: clientsBackend
    }

    Dialog {
        id: deleteDialog
        title: "Eliminar Cliente"
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No
        property var clientToDelete: null
        background: Rectangle { color: "white"; radius: 8; border.color: "#E5E7EB" }
        Text { text: "¿Seguro que deseas eliminar este cliente?\nSi tiene ventas, no se podrá borrar."; color: "#374151"; padding: 20 }
        onAccepted: if (clientToDelete) clientsBackend.deleteClient(clientToDelete.id)
    }

    // Interfaz
    Rectangle {
        anchors.fill: parent
        color: "#F9FAFB"

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 24; spacing: 20

            // Header
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Cartera de Clientes"; font.pixelSize: 24; font.bold: true; color: "#111827"; Layout.fillWidth: true }
                Button {
                    text: "+ Nuevo Cliente"
                    background: Rectangle { color: "#6366F1"; radius: 8 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: clientForm.openForCreate()
                }
            }

            // Tabla
            Rectangle {
                Layout.fillWidth: true; Layout.fillHeight: true
                color: "white"; radius: 12; border.color: "#E5E7EB"; clip: true

                // Cabecera Tabla
                Rectangle {
                    width: parent.width; height: 50; color: "#F3F4F6"; z: 10
                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 10
                        Label { text: "EMPRESA"; color: "#6B7280"; font.bold: true; Layout.preferredWidth: root.width * 0.3 }
                        Label { text: "RFC"; color: "#6B7280"; font.bold: true; Layout.preferredWidth: root.width * 0.2 }
                        Label { text: "TELÉFONO"; color: "#6B7280"; font.bold: true; Layout.preferredWidth: root.width * 0.2 }
                        Label { text: "ACCIONES"; color: "#6B7280"; font.bold: true; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#E5E7EB" }
                }

                // Lista
                ListView {
                    anchors.top: parent.top; anchors.topMargin: 50; anchors.bottom: parent.bottom; width: parent.width
                    model: clientsBackend.clientsModel
                    clip: true
                    delegate: Rectangle {
                        width: parent.width; height: 70
                        color: index % 2 === 0 ? "white" : "#FAFAFA"
                        
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 10
                            
                            // Nombre + Email
                            Column {
                                Layout.preferredWidth: root.width * 0.3
                                Layout.alignment: Qt.AlignVCenter
                                Label { text: modelData.nombre; font.bold: true; color: "#1F2937"; font.pixelSize: 14; elide: Text.ElideRight; width: parent.width }
                                Label { text: modelData.email; font.pixelSize: 12; color: "#6B7280"; elide: Text.ElideRight; width: parent.width }
                            }
                            
                            // RFC
                            Label { text: modelData.rfc; color: "#374151"; Layout.preferredWidth: root.width * 0.2 }
                            
                            // Teléfono
                            Label { text: modelData.telefono; color: "#374151"; Layout.preferredWidth: root.width * 0.2 }

                            // Acciones
                            RowLayout {
                                Layout.fillWidth: true; Layout.alignment: Qt.AlignRight
                                Button {
                                    text: "✎"; Layout.preferredWidth: 36; Layout.preferredHeight: 36
                                    background: Rectangle { color: parent.hovered ? "#DBEAFE" : "transparent"; radius: 6; border.color: "#BFDBFE" }
                                    contentItem: Text { text: parent.text; color: "#2563EB"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: clientForm.openForEdit(modelData)
                                }
                                Button {
                                    text: "🗑"; Layout.preferredWidth: 36; Layout.preferredHeight: 36
                                    background: Rectangle { color: parent.hovered ? "#FEE2E2" : "transparent"; radius: 6; border.color: "#FECACA" }
                                    contentItem: Text { text: parent.text; color: "#DC2626"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: { deleteDialog.clientToDelete = modelData; deleteDialog.open() }
                                }
                            }
                        }
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F3F4F6" }
                    }
                }
            }
        }
    }
}