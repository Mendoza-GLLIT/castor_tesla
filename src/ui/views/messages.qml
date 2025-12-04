import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    readonly property color cInfo: "#3B82F6"
    readonly property color cSuccess: "#10B981"
    readonly property color cWarning: "#F59E0B"
    readonly property color cCritical: "#EF4444"

    readonly property color textDark: "#111827"
    readonly property color textMedium: "#6B7280"

    Component.onCompleted: messagesBackend.refreshData()

    Rectangle {
        anchors.fill: parent
        color: "#F9FAFB"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: "Centro de Mensajes"
                    font.pixelSize: 24
                    font.bold: true
                    color: textDark
                }
                Item { Layout.fillWidth: true }

                Button {
                    text: "🔄 Actualizar"
                    flat: true
                    background: Rectangle {
                        color: parent.down ? "#E5E7EB" : "white"
                        radius: 8; border.color: "#E5E7EB"
                    }
                    contentItem: Text {
                        text: parent.text; color: textDark; font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: messagesBackend.refreshData()
                }
            }

            ListView {
                id: msgList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 12

                model: messagesBackend.messagesModel

                delegate: Rectangle {
                    width: parent.width
                    height: 80
                    radius: 8
                    color: "white"
                    border.color: "#E5E7EB"
                    border.width: 1

                    Rectangle {
                        width: 6
                        height: parent.height
                        anchors.left: parent.left
                        radius: 2
                        color: {
                            if (modelData.tipo === "critical") return cCritical
                            if (modelData.tipo === "warning") return cWarning
                            if (modelData.tipo === "success") return cSuccess
                            return cInfo
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20
                        anchors.rightMargin: 20
                        spacing: 15

                        Rectangle {
                            width: 40; height: 40; radius: 20
                            color: {
                                if (modelData.tipo === "critical") return "#FEE2E2"
                                if (modelData.tipo === "warning") return "#FEF3C7"
                                if (modelData.tipo === "success") return "#D1FAE5"
                                return "#DBEAFE"
                            }

                            Image {
                                anchors.centerIn: parent
                                // ← AQUÍ ESTABA EL ERROR
                                source: "file:///" + modelData.icon
                                width: 24
                                height: 24
                                fillMode: Image.PreserveAspectFit
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4

                            Label {
                                text: modelData.titulo
                                font.bold: true
                                font.pixelSize: 15
                                color: textDark
                            }
                            Label {
                                text: modelData.mensaje
                                color: textMedium
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        Label {
                            text: modelData.fecha
                            color: "#9CA3AF"
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }
            }
        }
    }
}
