import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    // Inyectamos el formulario
    AssetFormDialog {
        id: assetForm
        backendReference: assetsBackend
    }

    Dialog {
        id: deleteDialog
        title: "Eliminar Activo"
        anchors.centerIn: parent
        standardButtons: Dialog.Yes | Dialog.No
        property var assetToDelete: null
        background: Rectangle { color: "white"; radius: 8; border.color: "#E5E7EB" }
        Text { text: "¿Eliminar este activo permanentemente?"; color: "#374151"; padding: 20 }
        onAccepted: if (assetToDelete) assetsBackend.deleteAsset(assetToDelete.id)
    }

    Rectangle {
        anchors.fill: parent
        color: "#F9FAFB"

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 24; spacing: 20

            // Header
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Gestión de Activos Fijos"; font.pixelSize: 24; font.bold: true; color: "#111827"; Layout.fillWidth: true }
                Button {
                    text: "+ Nuevo Activo"
                    background: Rectangle { color: "#6366F1"; radius: 8 }
                    contentItem: Text { text: parent.text; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: assetForm.openForCreate()
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
                        Label { text: "CÓDIGO"; color: "#6B7280"; font.bold: true; Layout.preferredWidth: root.width * 0.15 }
                        Label { text: "ACTIVO"; color: "#6B7280"; font.bold: true; Layout.preferredWidth: root.width * 0.25 }
                        Label { text: "UBICACIÓN"; color: "#6B7280"; font.bold: true; Layout.preferredWidth: root.width * 0.20 }
                        Label { text: "RESPONSABLE"; color: "#6B7280"; font.bold: true; Layout.preferredWidth: root.width * 0.20 }
                        Label { text: "ACCIONES"; color: "#6B7280"; font.bold: true; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight }
                    }
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#E5E7EB" }
                }

                // Lista
                ListView {
                    anchors.top: parent.top; anchors.topMargin: 50; anchors.bottom: parent.bottom; width: parent.width
                    model: assetsBackend.assetsModel
                    clip: true
                    delegate: Rectangle {
                        width: parent.width; height: 70
                        color: index % 2 === 0 ? "white" : "#FAFAFA"
                        
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 24; anchors.rightMargin: 24; spacing: 10
                            
                            // Código
                            Label { text: modelData.codigo; color: "#374151"; font.bold: true; Layout.preferredWidth: root.width * 0.15 }
                            
                            // Nombre + Desc
                            Column {
                                Layout.preferredWidth: root.width * 0.25
                                Label { text: modelData.nombre; font.bold: true; color: "#1F2937"; font.pixelSize: 14; elide: Text.ElideRight; width: parent.width }
                                Label { text: modelData.descripcion; font.pixelSize: 12; color: "#6B7280"; elide: Text.ElideRight; width: parent.width }
                            }
                            
                            // Ubicación
                            Label { text: modelData.ubicacion; color: "#374151"; Layout.preferredWidth: root.width * 0.20 }

                            // Badge Responsable
                            Item {
                                Layout.preferredWidth: root.width * 0.20; height: 26
                                Rectangle {
                                    anchors.left: parent.left; width: respLbl.implicitWidth + 20; height: parent.height
                                    color: modelData.id_responsable > 0 ? "#E0E7FF" : "#F3F4F6"
                                    radius: 13
                                    Label { 
                                        id: respLbl
                                        text: modelData.responsable_nombre
                                        color: modelData.id_responsable > 0 ? "#3730A3" : "#6B7280"
                                        font.bold: true; font.pixelSize: 11
                                        anchors.centerIn: parent
                                    }
                                }
                            }

                            // Acciones
                            RowLayout {
                                Layout.fillWidth: true; Layout.alignment: Qt.AlignRight
                                Button {
                                    text: "✎"; Layout.preferredWidth: 36; Layout.preferredHeight: 36
                                    background: Rectangle { color: parent.hovered ? "#DBEAFE" : "transparent"; radius: 6; border.color: "#BFDBFE" }
                                    contentItem: Text { text: parent.text; color: "#2563EB"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: assetForm.openForEdit(modelData)
                                }
                                Button {
                                    text: "🗑"; Layout.preferredWidth: 36; Layout.preferredHeight: 36
                                    background: Rectangle { color: parent.hovered ? "#FEE2E2" : "transparent"; radius: 6; border.color: "#FECACA" }
                                    contentItem: Text { text: parent.text; color: "#DC2626"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                                    onClicked: { deleteDialog.assetToDelete = modelData; deleteDialog.open() }
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