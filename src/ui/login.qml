import QtQuick
import QtQuick.Controls

ApplicationWindow {
    width: 960
    height: 600
    visible: true
    title: qsTr("Login")
    color: "#0a0f24"

    Rectangle {
        id: leftPanel
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width / 2
        color: "#0a0f24"

        Column {
            anchors.centerIn: parent
            spacing: 24
            width: parent.width 

            Image {
                id: logo
                source: "../../resources/logo.png"
                width: 200
                height: 200
                fillMode: Image.PreserveAspectFit
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: qsTr("Bienvenido a Castor Tesla")
                font.pixelSize: 28
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
            }
        }
    }

    Rectangle {
        id: rightPanel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width / 2
        color: "#1b2241"

        Column {
            anchors.centerIn: parent
            spacing: 20
            width: Math.min(parent.width * 0.6, 420)

            Label {
                text: qsTr("Inicia sesión")
                font.pixelSize: 32
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: userInput
                placeholderText: qsTr("Usuario")
                placeholderTextColor: "#aaaaaa"
                color: "white"
                width: parent.width
                height: 44
                verticalAlignment: Text.AlignVCenter
                background: Rectangle {
                    color: "transparent"
                    border.color: userInput.activeFocus ? "#4facfe" : "white"
                    border.width: userInput.activeFocus ? 2 : 1
                    radius: 6
                }
                onAccepted: passwordField.forceActiveFocus()
            }

            TextField {
                id: passwordField
                placeholderText: qsTr("Contraseña")
                echoMode: TextInput.Password
                placeholderTextColor: "#aaaaaa"
                color: "white"
                width: parent.width
                height: 44
                verticalAlignment: Text.AlignVCenter
                background: Rectangle {
                    color: "transparent"
                    border.color: passwordField.activeFocus ? "#4facfe" : "white"
                    border.width: passwordField.activeFocus ? 2 : 1
                    radius: 6
                }
                onAccepted: loginBtn.clicked()
            }

            Label {
                id: errorMessage
                text: ""
                color: "#ff5555"
                font.pixelSize: 14
                visible: text !== ""
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: 8
                width: parent.width
                CheckBox {
                    id: rememberCheck
                    checked: false
                }
                Label {
                    text: qsTr("Recordarme")
                    color: "white"
                    font.pixelSize: 16
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Button {
                id: loginBtn
                width: parent.width
                height: 48
                text: qsTr("Iniciar sesión")
                hoverEnabled: true

                background: Rectangle {
                    radius: 8
                    color: loginBtn.down ? "#cccccc" : (loginBtn.hovered ? "#eeeeee" : "white")
                    border.color: loginBtn.down ? "#999" : "transparent"
                    border.width: 1
                }

                contentItem: Text {
                    text: loginBtn.text
                    color: "black"
                    font.pixelSize: 18
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: loginBtn.clicked()
                    onPressed: loginBtn.down = true
                    onReleased: loginBtn.down = false
                }

                onClicked: {
                    errorMessage.text = ""

                    if (userInput.text === "" || passwordField.text === "") {
                        errorMessage.text = "⚠️ Por favor llena todos los campos"
                        return
                    }

                    var success = Controller.login(userInput.text, passwordField.text)
                    
                    if (!success) {
                        errorMessage.text = "❌ Usuario o contraseña incorrectos"
                        passwordField.text = ""
                    }
                }
            }
        }
    }
}
