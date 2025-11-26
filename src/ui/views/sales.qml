import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    readonly property color bgPrimary: "#FFFFFF"
    readonly property color bgSecondary: "#F9FAFB"
    readonly property color borderLight: "#E5E7EB"
    readonly property color textDark: "#111827"
    readonly property color textMedium: "#6B7280"
    readonly property color accentPurple: "#6366F1"

    Rectangle {
        anchors.fill: parent
        color: bgSecondary

        Rectangle {
            width: Math.min(parent.width - 48, 1000)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.margins: 24
            
            color: bgPrimary
            radius: 12
            border.color: borderLight
            border.width: 1
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 24

                Label {
                    text: "Historial de Ventas"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    color: textDark
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 48
                    color: bgSecondary
                    
                    Rectangle { width: parent.width; height: 1; color: borderLight; anchors.bottom: parent.bottom }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0
                        Label { text: "ID VENTA"; font.bold: true; color: textMedium; Layout.preferredWidth: 1; Layout.fillWidth: true; leftPadding: 16 }
                        Label { text: "FECHA"; font.bold: true; color: textMedium; Layout.preferredWidth: 2; Layout.fillWidth: true }
                        Label { text: "VENDEDOR"; font.bold: true; color: textMedium; Layout.preferredWidth: 2; Layout.fillWidth: true }
                        Label { text: "TOTAL"; font.bold: true; color: textMedium; Layout.preferredWidth: 1; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight; rightPadding: 40 }
                        Item { width: 40 }
                    }
                }

                ListView {
                    id: salesList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: salesModel 
                    spacing: 8

                    delegate: Column {
                        width: parent.width
                        property bool isExpanded: false 

                        Rectangle {
                            width: parent.width
                            height: 56
                            color: bgPrimary
                            
                            Rectangle { 
                                anchors.fill: parent 
                                color: parent.parent.isExpanded ? "#F3F4F6" : (clickArea.containsMouse ? "#FAFAFA" : "transparent")
                            }

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0
                                Label { text: "#" + idVenta; font.bold: true; color: accentPurple; Layout.preferredWidth: 1; Layout.fillWidth: true; leftPadding: 16 }
                                Label { text: fecha; color: textDark; Layout.preferredWidth: 2; Layout.fillWidth: true }
                                Label { text: vendedor; color: textDark; Layout.preferredWidth: 2; Layout.fillWidth: true }
                                Label { text: total; font.bold: true; color: "#10B981"; Layout.preferredWidth: 1; Layout.fillWidth: true; horizontalAlignment: Text.AlignRight; rightPadding: 40 }
                                
                                Text { 
                                    text: parent.parent.isExpanded ? "▼" : "▶"
                                    color: textMedium
                                    font.pixelSize: 12
                                    width: 40
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: clickArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: parent.parent.isExpanded = !parent.parent.isExpanded
                            }
                            
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: borderLight }
                        }

                        Rectangle {
                            width: parent.width
                            // Altura automática basada en el contenido si está expandido
                            height: parent.isExpanded ? contentCol.implicitHeight + 20 : 0 
                            color: "#F8FAFC" // Gris muy suave
                            clip: true
                            
                            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

                            ColumnLayout {
                                id: contentCol
                                width: parent.width
                                anchors.top: parent.top
                                anchors.topMargin: 10
                                visible: parent.height > 0 // Ocultar contenido si altura es 0
                                
                                Label { 
                                    text: "Productos en este ticket:"
                                    font.pixelSize: 12; font.bold: true; color: textMedium 
                                    Layout.leftMargin: 24
                                    Layout.bottomMargin: 4
                                }

                                Repeater {
                                    model: detalles // La lista que viene de Python

                                    delegate: RowLayout {
                                        Layout.fillWidth: true
                                        Layout.leftMargin: 24
                                        Layout.rightMargin: 40
                                        Layout.bottomMargin: 4
                                        
                                        Label { 
                                            text: "• " + modelData.producto 
                                            font.pixelSize: 13 
                                            color: textDark 
                                            Layout.fillWidth: true 
                                        }
                                        
                                        Label { 
                                            text: "x" + modelData.cantidad 
                                            font.pixelSize: 13 
                                            color: textMedium 
                                            Layout.preferredWidth: 50
                                            horizontalAlignment: Text.AlignRight 
                                        }
                                        
                                        Label { 
                                            text: "$" + modelData.subtotal.toFixed(2) 
                                            font.pixelSize: 13 
                                            font.bold: true 
                                            color: textDark 
                                            Layout.preferredWidth: 80 
                                            horizontalAlignment: Text.AlignRight 
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