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

    component RoundedButton: Button {
        id: control
        property color btnColor: accentPurple
        property color btnTextColor: "white"
        font.pixelSize: 14
        font.weight: Font.Medium
        leftPadding: 20
        rightPadding: 20
        topPadding: 10
        bottomPadding: 10
        background: Rectangle {
            color: control.down ? Qt.darker(control.btnColor, 1.1) : (control.hovered ? Qt.lighter(control.btnColor, 1.1) : control.btnColor)
            radius: 8
        }
        contentItem: Text {
            text: control.text
            font: control.font
            color: control.btnTextColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onPressed: mouse.accepted = false }
    }

    Rectangle {
        anchors.fill: parent
        color: bgSecondary

        Rectangle {
            width: Math.min(parent.width - 48, 1200) 
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

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        Label {
                            text: "Productos"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: textDark
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                        }
                        RoundedButton {
                            text: "+ Añadir Producto"
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 16
                        Rectangle {
                            Layout.preferredWidth: 320
                            Layout.preferredHeight: 42
                            color: bgSecondary
                            radius: 8
                            border.color: borderLight
                            border.width: 1
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8
                                Text { text: "🔍"; font.pixelSize: 16; color: textMedium }
                                TextField {
                                    id: searchField
                                    placeholderText: "Buscar por nombre, código..."
                                    placeholderTextColor: textMedium
                                    font.pixelSize: 14
                                    color: textDark
                                    background: null
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0

                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        color: bgSecondary
                        Rectangle { width: parent.width; height: 1; color: borderLight; anchors.bottom: parent.bottom }

                        RowLayout {
                            anchors.fill: parent
                            spacing: 0 

                            Label { 
                                text: "CÓDIGO"
                                font.pixelSize: 12; font.weight: Font.DemiBold; color: textMedium
                                Layout.preferredWidth: 1.5; Layout.fillWidth: true 
                                leftPadding: 16; verticalAlignment: Text.AlignVCenter
                            }
                            Label { 
                                text: "PRODUCTO"
                                font.pixelSize: 12; font.weight: Font.DemiBold; color: textMedium
                                Layout.preferredWidth: 3; Layout.fillWidth: true 
                                leftPadding: 16; verticalAlignment: Text.AlignVCenter
                            }
                            Label { 
                                text: "DESCRIPCIÓN"
                                font.pixelSize: 12; font.weight: Font.DemiBold; color: textMedium
                                Layout.preferredWidth: 4; Layout.fillWidth: true 
                                leftPadding: 16; verticalAlignment: Text.AlignVCenter
                            }
                            Label { 
                                text: "PRECIO"
                                font.pixelSize: 12; font.weight: Font.DemiBold; color: textMedium
                                Layout.preferredWidth: 1.5; Layout.fillWidth: true 
                                horizontalAlignment: Text.AlignRight; rightPadding: 16; verticalAlignment: Text.AlignVCenter
                            }
                            Label { 
                                text: "STOCK"
                                font.pixelSize: 12; font.weight: Font.DemiBold; color: textMedium
                                Layout.preferredWidth: 1.5; Layout.fillWidth: true 
                                horizontalAlignment: Text.AlignRight; rightPadding: 32; verticalAlignment: Text.AlignVCenter
                            }
                            Item { width: 40 } 
                        }
                    }

                    ListView {
                        id: productList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: productsModel
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            width: parent.width
                            height: 64
                            color: bgPrimary
                            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: borderLight }

                            RowLayout {
                                anchors.fill: parent
                                spacing: 0

                                Label { 
                                    text: codigo
                                    font.pixelSize: 14; font.weight: Font.Medium; color: textDark
                                    Layout.preferredWidth: 1.5; Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    leftPadding: 16; elide: Text.ElideRight
                                }
                                
                                Column {
                                    Layout.preferredWidth: 3; Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    leftPadding: 16 
                                    Label { 
                                        text: nombre
                                        font.pixelSize: 14; font.weight: Font.Medium; color: textDark
                                        width: parent.width - 32; elide: Text.ElideRight 
                                    }
                                    Label { 
                                        text: "Electrónica"
                                        font.pixelSize: 12; color: textMedium 
                                        width: parent.width - 32; elide: Text.ElideRight
                                    }
                                }

                                Label { 
                                    text: model.descripcion ? model.descripcion : "Sin descripción" 
                                    font.pixelSize: 13; color: textMedium
                                    Layout.preferredWidth: 4; Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    leftPadding: 16; elide: Text.ElideRight
                                }

                                Label { 
                                    text: precio
                                    font.pixelSize: 14; font.weight: Font.Medium; color: textDark
                                    Layout.preferredWidth: 1.5; Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignRight; Layout.alignment: Qt.AlignVCenter 
                                    rightPadding: 16
                                }
                                
                                RowLayout {
                                    Layout.preferredWidth: 1.5; Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                                    spacing: 8
                                    anchors.rightMargin: 16 
                                    
                                    Item { Layout.fillWidth: true }
                                    Rectangle { 
                                        width: 8; height: 8; radius: 4
                                        color: stock > 10 ? "#10B981" : (stock > 0 ? "#F59E0B" : "#EF4444") 
                                    }
                                    Label { 
                                        text: stock + " un."
                                        font.pixelSize: 14; font.weight: Font.Medium; color: textDark 
                                        rightPadding: 16
                                    }
                                }

                                Button {
                                    text: "•••"
                                    font.pixelSize: 20
                                    width: 40; height: 40
                                    flat: true
                                    Layout.alignment: Qt.AlignVCenter
                                    contentItem: Text { 
                                        text: parent.text; color: textMedium
                                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                        bottomPadding: 8 
                                    }
                                    background: Rectangle { color: parent.hovered ? bgSecondary : "transparent"; radius: 6 }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onPressed: mouse.accepted = false }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
