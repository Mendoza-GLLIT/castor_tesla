import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string icon: ""
    property string text: ""
    property bool isActive: false
    signal clicked

    Layout.fillWidth: true
    height: 48
    radius: 8
    
    // Hover sutil (#232a4d) y activo morado
    color: isActive ? "#232a4d" : (mouseArea.containsMouse ? "#232a4d" : "transparent")

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        spacing: 12

        Image {
            source: "../../resources/icons/" + root.icon + ".png"
            width: 20; height: 20
            fillMode: Image.PreserveAspectFit
            opacity: (root.isActive || mouseArea.containsMouse) ? 1.0 : 0.7
        }

        Label {
            text: root.text
            color: "white"
            font.pixelSize: 14
            font.weight: root.isActive ? Font.Bold : Font.Normal
            opacity: (root.isActive || mouseArea.containsMouse) ? 1.0 : 0.7
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft // Texto a la izquierda
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}