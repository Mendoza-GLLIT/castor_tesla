import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string icon: ""
    property string text: ""
    property bool isActive: false
    
    // Default size 24, pero lo puedes cambiar desde fuera
    property int iconSize: 24 
    
    signal clicked

    Layout.fillWidth: true
    height: 48
    radius: 8
    
    color: isActive ? "#232a4d" : (mouseArea.containsMouse ? "#232a4d" : "transparent")

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        spacing: 12

        // Contenedor rígido para el icono
        Item {
            // Usamos Layout.preferred... para que el RowLayout lo respete
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter // Centrado verticalmente
            
            Image {
                anchors.fill: parent // Llena el contenedor rígido
                source: iconBasePath + "/" + root.icon + ".png"
                fillMode: Image.PreserveAspectFit
                opacity: (root.isActive || mouseArea.containsMouse) ? 1.0 : 0.7
                mipmap: true
                
                // [TRUCO] sourceSize ayuda a Qt a renderizar mejor
                sourceSize.width: root.iconSize
                sourceSize.height: root.iconSize
            }
        }

        Label {
            text: root.text
            color: "white"
            font.pixelSize: 14
            font.weight: root.isActive ? Font.Bold : Font.Normal
            opacity: (root.isActive || mouseArea.containsMouse) ? 1.0 : 0.7
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft 
            verticalAlignment: Text.AlignVCenter
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