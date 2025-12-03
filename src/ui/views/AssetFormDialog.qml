import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

Dialog {
    id: root
    modal: true
    width: 480
    height: 620
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    
    closePolicy: Popup.NoAutoClose
    standardButtons: Dialog.NoButton

    property bool isEditing: false
    property int currentAssetId: 0
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

    // --- 1. LÓGICA DE GENERACIÓN DE CÓDIGO ---
    function generateAssetCode(name) {
        if (!name || name.length < 3) return ""
        
        // 1. Tomamos las primeras 3 letras, quitamos espacios y convertimos a mayúsculas
        var prefix = name.replace(/[^a-zA-Z0-9]/g, "").substring(0, 3).toUpperCase()
        
        // 2. Generamos un número aleatorio de 4 dígitos
        var randomNum = Math.floor(Math.random() * 9000) + 1000
        
        // Retornamos formato: LAP-4829
        return prefix + "-" + randomNum
    }

    // --- FUNCIONES ---
    function openForCreate() {
        isEditing = false; currentAssetId = 0
        fCode.text = ""; fName.text = ""; fDesc.text = ""; fLoc.text = ""
        respCombo.currentIndex = 0 
        root.open()
    }

    function openForEdit(asset) {
        isEditing = true; currentAssetId = asset.id
        fCode.text = asset.codigo
        fName.text = asset.nombre
        fDesc.text = asset.descripcion
        fLoc.text = asset.ubicacion
        
        respCombo.currentIndex = 0
        if (backendReference) {
            for(var i=0; i < backendReference.employeesModel.length; i++) {
                if (backendReference.employeesModel[i].id === asset.id_responsable) {
                    respCombo.currentIndex = i; break
                }
            }
        }
        root.open()
    }

    function saveAsset() {
        if (fCode.text === "" || fName.text === "") { 
            console.log("⚠️ Faltan datos"); fCode.field.forceActiveFocus(); return 
        }
        
        var selectedIndex = respCombo.currentIndex
        var selectedRespId = 0
        if (backendReference && backendReference.employeesModel[selectedIndex]) {
            selectedRespId = backendReference.employeesModel[selectedIndex].id
        }

        if (isEditing) {
            backendReference.updateAsset(currentAssetId, fCode.text, fName.text, fDesc.text, fLoc.text, selectedRespId)
        } else {
            backendReference.createAsset(fCode.text, fName.text, fDesc.text, fLoc.text, selectedRespId)
        }
        root.close()
    }

    // --- COMPONENTE INTERNO ---
    component StyledField: Column {
        property alias label: lbl.text
        property alias text: txt.text
        property alias placeholder: txt.placeholderText
        property alias field: txt
        // Propiedad extra para saber si es de solo lectura (opcional)
        property bool readOnly: false 
        
        spacing: 6
        
        Label { id: lbl; font.weight: Font.DemiBold; color: root.textDark; font.pixelSize: 13 }
        TextField {
            id: txt; width: parent.width; height: 42; font.pixelSize: 14
            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 12; rightPadding: 12; color: root.textDark
            placeholderTextColor: root.textMedium
            readOnly: parent.readOnly // Conectamos
            
            // Si es readOnly, lo ponemos gris para que se note
            background: Rectangle { 
                color: parent.readOnly ? "#F3F4F6" : root.bgSecondary
                radius: 8
                border.color: txt.activeFocus ? root.accentPurple : root.borderLight; border.width: 1 
            }
        }
    }

    // --- CONTENIDO ---
    ColumnLayout {
        anchors.fill: parent; spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 60; color: "#EEF2FF"; radius: 12
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 12; color: parent.color }
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 15
                Label { text: isEditing ? "✏️" : "💻"; font.pixelSize: 22 }
                ColumnLayout {
                    spacing: 0
                    Label { text: isEditing ? "Editar Activo" : "Nuevo Activo"; font.pixelSize: 16; font.bold: true; color: "#3730A3" }
                    Label { text: "Control de inventario interno"; font.pixelSize: 12; color: "#6366F1" }
                }
                Item { Layout.fillWidth: true }
                Button {
                    text: "✕"; flat: true; Layout.preferredWidth: 30; Layout.preferredHeight: 30
                    background: Rectangle { color: "transparent" }
                    contentItem: Text { text: parent.text; color: "#3730A3"; font.bold: true; anchors.centerIn: parent }
                    onClicked: root.close()
                }
            }
            Rectangle { width: parent.width; height: 1; color: "#E0E7FF"; anchors.bottom: parent.bottom }
        }

        // Formulario
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; contentWidth: parent.width
            ColumnLayout {
                width: parent.width - 48; anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top; anchors.topMargin: 20; spacing: 16

                // 2. CAMPO NOMBRE (Aquí ocurre la magia)
                StyledField { 
                    id: fName; label: "Nombre del Activo"; placeholder: "Ej. Laptop HP Pavilion"
                    Layout.fillWidth: true 
                    
                    // 👇👇👇 AUTOMATIZACIÓN 👇👇👇
                    field.onTextChanged: {
                        // Solo generamos si NO estamos editando uno existente
                        if (!isEditing) {
                            fCode.text = generateAssetCode(fName.text)
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true; spacing: 15
                    property real halfWidth: (parent.width - spacing) / 2
                    
                    // 3. CAMPO CÓDIGO (Autocompletado)
                    StyledField { 
                        id: fCode
                        label: "Código (Auto)"
                        placeholder: "Generado automáticamente..."
                        Layout.preferredWidth: parent.halfWidth
                        Layout.fillWidth: true 
                        // Opcional: readOnly: true // Si quieres impedir que lo cambien a mano
                    }
                    
                    StyledField { id: fLoc; label: "Ubicación"; placeholder: "Oficina Ventas"; Layout.preferredWidth: parent.halfWidth; Layout.fillWidth: true }
                }

                StyledField { id: fDesc; label: "Descripción"; placeholder: "i5 8GB RAM 256SSD"; Layout.fillWidth: true }

                Column {
                    spacing: 6; Layout.fillWidth: true
                    Label { text: "Responsable Asignado"; font.weight: Font.DemiBold; color: textDark; font.pixelSize: 13 }
                    ComboBox {
                        id: respCombo; width: parent.width; height: 42
                        textRole: "nombre"; valueRole: "id"
                        model: backendReference ? backendReference.employeesModel : []
                        background: Rectangle { 
                            color: bgSecondary; radius: 8
                            border.color: parent.activeFocus ? accentPurple : borderLight; border.width: 1 
                        }
                        contentItem: Text { 
                            leftPadding: 12; text: parent.displayText; font.pixelSize: 14; color: textDark; verticalAlignment: Text.AlignVCenter 
                        }
                    }
                }
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
                contentItem: Text { text: "Guardar Activo"; color: "white"; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: saveAsset()
            }
        }
    }
}