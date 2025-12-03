import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes 1.15 // Necesario para la gráfica de línea

Item {
    id: root
    anchors.fill: parent

    // --- PALETA DE COLORES "COOL" ---
    readonly property color bgPage: "#F3F4F6"
    readonly property color cardBg: "#FFFFFF"
    readonly property color textMain: "#1F2937"
    readonly property color textMuted: "#6B7280"
    
    readonly property color accent: "#6366F1" // Indigo
    readonly property color accentLight: "#818CF8"
    readonly property color success: "#10B981" // Verde
    readonly property color danger: "#EF4444" // Rojo

    Component.onCompleted: statsBackend.refreshData()

    // Fondo General
    Rectangle { anchors.fill: parent; color: bgPage }

    ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth
        
        ColumnLayout {
            width: parent.width
            anchors.margins: 24
            spacing: 24

            // --- 1. HEADER CON FECHA Y BOTÓN ---
            RowLayout {
                Layout.fillWidth: true
                Layout.margins: 24
                
                Column {
                    Label { text: "Resumen Financiero"; font.pixelSize: 24; font.bold: true; color: textMain }
                    Label { text: new Date().toLocaleDateString(Qt.locale(), "dddd, d MMMM yyyy"); color: textMuted }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: "🔄 Actualizar"
                    background: Rectangle { color: "white"; radius: 8; border.color: "#E5E7EB" }
                    contentItem: Text { text: parent.text; color: textMain; font.bold: true; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                    onClicked: statsBackend.refreshData()
                }
            }

            // --- 2. TARJETAS KPI MODERNAS ---
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: 24; Layout.rightMargin: 24
                spacing: 20

                // CARD 1: Ventas Hoy
                KpiCard {
                    title: "Ventas de Hoy"
                    value: "$" + statsBackend.salesToday.toFixed(2)
                    icon: "💵"
                    trendText: "Cierre diario"
                    trendColor: textMuted
                }

                // CARD 2: Ventas del Mes + Comparación
                KpiCard {
                    title: "Ingresos del Mes"
                    value: "$" + statsBackend.salesCurrentMonth.toFixed(2)
                    icon: "📈"
                    // Lógica para mostrar crecimiento
                    property bool isPositive: statsBackend.growthPercent >= 0
                    trendText: (isPositive ? "▲ " : "▼ ") + Math.abs(statsBackend.growthPercent).toFixed(1) + "% vs mes anterior"
                    trendColor: isPositive ? success : danger
                }

                // CARD 3: Stock
                KpiCard {
                    title: "Total Inventario"
                    value: statsBackend.stockTotal + " un."
                    icon: "📦"
                    trendText: "Activos en almacén"
                    trendColor: accent
                }
            }

            // --- 3. GRÁFICA DE LÍNEA CURVA (AREA CHART) ---
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 350
                Layout.leftMargin: 24; Layout.rightMargin: 24
                color: cardBg; radius: 16
                // Sombra suave (hack simple con borde grueso transparente)
                border.color: "#E5E7EB"; border.width: 1

                ColumnLayout {
                    anchors.fill: parent; anchors.margins: 24
                    
                    Label { text: "Tendencia Anual de Ventas"; font.bold: true; font.pixelSize: 16; color: textMain }
                    
                    // Contenedor de la gráfica
                    Item {
                        id: chartArea
                        Layout.fillWidth: true; Layout.fillHeight: true
                        
                        // Dibujo de la línea y el relleno
                        Shape {
                            anchors.fill: parent
                            // Antialiasing para que la curva se vea suave (importante)
                            layer.enabled: true
                            layer.samples: 4

                            // 1. Relleno Degradado (Fondo)
                            ShapePath {
                                strokeWidth: 0
                                fillGradient: LinearGradient {
                                    x1: 0; y1: 0; x2: 0; y2: chartArea.height
                                    GradientStop { position: 0; color: "#406366F1" } // Morado transparente
                                    GradientStop { position: 1; color: "#006366F1" } // Transparente total
                                }
                                startX: 0; startY: chartArea.height
                                
                                PathLine { x: 0; y: getY(0) } // Primer punto
                                
                                // Generamos la curva dinámicamente
                                // Nota: Usamos Repeater no visual para lógica o bucle manual, aquí haré un path dinámico simple
                                PathCurve { x: getX(1); y: getY(1) }
                                PathCurve { x: getX(2); y: getY(2) }
                                PathCurve { x: getX(3); y: getY(3) }
                                PathCurve { x: getX(4); y: getY(4) }
                                PathCurve { x: getX(5); y: getY(5) }
                                PathCurve { x: getX(6); y: getY(6) }
                                PathCurve { x: getX(7); y: getY(7) }
                                PathCurve { x: getX(8); y: getY(8) }
                                PathCurve { x: getX(9); y: getY(9) }
                                PathCurve { x: getX(10); y: getY(10) }
                                PathCurve { x: getX(11); y: getY(11) }

                                PathLine { x: chartArea.width; y: chartArea.height } // Bajar al suelo
                                PathLine { x: 0; y: chartArea.height } // Cerrar forma
                            }

                            // 2. La Línea Maestra (Trazo sólido encima)
                            ShapePath {
                                strokeColor: accent
                                strokeWidth: 3
                                fillColor: "transparent"
                                capStyle: ShapePath.RoundCap
                                
                                startX: getX(0); startY: getY(0)
                                PathCurve { x: getX(1); y: getY(1) }
                                PathCurve { x: getX(2); y: getY(2) }
                                PathCurve { x: getX(3); y: getY(3) }
                                PathCurve { x: getX(4); y: getY(4) }
                                PathCurve { x: getX(5); y: getY(5) }
                                PathCurve { x: getX(6); y: getY(6) }
                                PathCurve { x: getX(7); y: getY(7) }
                                PathCurve { x: getX(8); y: getY(8) }
                                PathCurve { x: getX(9); y: getY(9) }
                                PathCurve { x: getX(10); y: getY(10) }
                                PathCurve { x: getX(11); y: getY(11) }
                            }
                        }

                        // Puntos interactivos (Círculos encima de la línea)
                        Repeater {
                            model: 12
                            delegate: Rectangle {
                                width: 12; height: 12; radius: 6
                                color: "white"
                                border.color: accent; border.width: 2
                                x: getX(index) - width/2
                                y: getY(index) - height/2
                                z: 10
                                
                                // Tooltip al pasar el mouse
                                MouseArea {
                                    anchors.fill: parent; hoverEnabled: true
                                    onEntered: parent.scale = 1.5
                                    onExited: parent.scale = 1.0
                                    ToolTip {
                                        visible: parent.containsMouse
                                        text: getMonthName(index) + ": $" + statsBackend.revenueData[index].toFixed(2)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Etiquetas Eje X (Meses)
                    RowLayout {
                        Layout.fillWidth: true
                        Repeater {
                            model: ["Ene","Feb","Mar","Abr","May","Jun","Jul","Ago","Sep","Oct","Nov","Dic"]
                            delegate: Label { 
                                text: modelData; color: textMuted; font.pixelSize: 10 
                                Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter 
                            }
                        }
                    }
                }
            }

            // --- 4. LISTAS TOP (Estilo Tabla Limpia) ---
            RowLayout {
                Layout.fillWidth: true; Layout.preferredHeight: 320
                Layout.leftMargin: 24; Layout.rightMargin: 24; Layout.bottomMargin: 24
                spacing: 24

                // Top Productos
                TopListCard {
                    title: "🔥 Top Productos"
                    modelData: statsBackend.topProductsModel
                    isProduct: true
                }

                // Top Clientes
                TopListCard {
                    title: "💎 Top Clientes"
                    modelData: statsBackend.topClientsModel
                    isProduct: false
                }
            }
        }
    }

    // --- FUNCIONES DE GRÁFICA ---
    function getX(index) {
        // Divide el ancho disponible entre 11 segmentos (12 puntos)
        var step = chartArea.width / 11
        return step * index
    }

    function getY(index) {
        // Regla de 3 inversa: Mayor valor = Y más cercano a 0 (arriba)
        var val = statsBackend.revenueData[index]
        var max = statsBackend.maxRevenue
        // Dejamos un margen del 10% arriba para que no toque el techo
        return chartArea.height - ((val / max) * (chartArea.height * 0.9))
    }

    function getMonthName(idx) {
        return ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"][idx]
    }

    // --- COMPONENTES INTERNOS REUTILIZABLES ---

    component KpiCard: Rectangle {
        property string title
        property string value
        property string icon
        property string trendText
        property color trendColor
        
        Layout.fillWidth: true; height: 110
        color: cardBg; radius: 16; border.color: borderCol
        
        RowLayout {
            anchors.fill: parent; anchors.margins: 20
            ColumnLayout {
                spacing: 4
                Label { text: title; color: textMuted; font.weight: Font.Medium }
                Label { text: value; font.pixelSize: 26; font.bold: true; color: textMain }
                Label { text: trendText; color: trendColor; font.pixelSize: 12; font.weight: Font.DemiBold }
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 48; height: 48; radius: 12; color: "#F3F4F6"
                Label { text: icon; font.pixelSize: 24; anchors.centerIn: parent }
            }
        }
    }

    component TopListCard: Rectangle {
        property string title
        property var modelData
        property bool isProduct: true
        
        Layout.fillWidth: true; Layout.fillHeight: true
        color: cardBg; radius: 16; border.color: borderCol
        
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 20
            Label { text: title; font.bold: true; font.pixelSize: 16; color: textMain }
            
            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true
                model: modelData
                spacing: 12
                
                delegate: Rectangle {
                    width: parent.width; height: 40; color: "transparent"
                    RowLayout {
                        anchors.fill: parent
                        // Icono simple
                        Rectangle {
                            width: 32; height: 32; radius: 8; color: isProduct ? "#EEF2FF" : "#ECFDF5"
                            Label { text: isProduct ? "📦" : "👤"; anchors.centerIn: parent }
                        }
                        Label { 
                            text: modelData.nombre 
                            color: textMain; font.weight: Font.Medium
                            Layout.fillWidth: true; elide: Text.ElideRight 
                        }
                        Label { 
                            text: isProduct ? modelData.cantidad + " un." : "$" + modelData.total.toFixed(2)
                            color: isProduct ? accent : success
                            font.bold: true 
                        }
                    }
                    // Línea separadora sutil
                    Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: "#F9FAFB" }
                }
            }
        }
    }
}