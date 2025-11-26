import psycopg2

conn = psycopg2.connect(
    dbname="CastorTesla",
    user="postgres",
    password="160603",
    host="localhost",
    port="5432"
)

cur = conn.cursor()

productos = [
    
    ("RES-001", "Resistencia 220Ω", "Resistencia de carbón 1/4W", 1.00, "pieza", 100),
    ("RES-002", "Resistencia 1kΩ", "Resistencia de carbón 1/4W", 1.00, "pieza", 100),
    ("RES-003", "Resistencia 10kΩ", "Resistencia de carbón 1/4W", 1.00, "pieza", 100),
    ("RES-004", "Resistencia 100kΩ", "Resistencia de carbón 1/4W", 1.00, "pieza", 100),
    ("DIO-001", "Diodo 1N4001", "Diodo rectificador 50V 1A", 2.00, "pieza", 50),
    ("DIO-002", "Diodo 1N4148", "Diodo señal rápido", 1.00, "pieza", 50),
    ("DIO-003", "Diodo Zener 5.1V", "Diodo regulador de voltaje", 2.00, "pieza", 50),
    ("CAP-001", "Capacitor 10uF", "Electrolítico 25V", 3.00, "pieza", 40),
    ("CAP-002", "Capacitor 100uF", "Electrolítico 25V", 3.00, "pieza", 40),
    ("CAP-003", "Capacitor 100nF", "Cerámico", 2.00, "pieza", 40),
    ("TRA-001", "Transistor BC547", "NPN de propósito general", 1.00, "pieza", 30),
    ("TRA-002", "Transistor 2N2222", "NPN de propósito general", 4.00, "pieza", 30),
    ("TRA-003", "Transistor TIP41", "NPN de potencia", 9.00, "pieza", 20),
    ("TRA-004", "Transistor TIP42", "PNP de potencia", 15.00, "pieza", 20),
    ("IC-001", "Circuito Integrado 555", "Timer IC", 10.00, "pieza", 25),
    ("IC-002", "Circuito Integrado LM7805", "Regulador de voltaje 5V", 8.00, "pieza", 25),
    ("IC-003", "Circuito Integrado LM317", "Regulador ajustable", 10.00, "pieza", 25),
    ("IC-004", "Circuito Integrado ULN2003", "Driver para relés/motores", 15.00, "pieza", 15),
    ("LED-001", "LED Rojo 5mm", "LED estándar", 1.00, "pieza", 200),
    ("LED-002", "LED Verde 5mm", "LED estándar", 1.00, "pieza", 200),
    ("LED-003", "LED Azul 5mm", "LED estándar", 2.00, "pieza", 200),
    ("LED-004", "LED Blanco 5mm", "LED estándar", 2.00, "pieza", 200),
    ("CON-001", "Conector DB9", "Conector serial", 20.00, "pieza", 15),
    ("CON-002", "Conector USB Tipo A", "Conector hembra PCB", 15.00, "pieza", 30),
    ("CON-003", "Conector RJ45", "Conector de red", 10.00, "pieza", 30),
    ("MOD-001", "Módulo ESP32", "Microcontrolador WiFi/Bluetooth", 199.00, "pieza", 10),
    ("MOD-002", "Módulo Arduino Nano", "Microcontrolador ATmega328", 200.00, "pieza", 10),
    ("MOD-003", "Módulo Sensor PIR", "Sensor de movimiento", 50.00, "pieza", 15),
    ("MOD-004", "Módulo Relé 5V", "Relé de un canal", 40.00, "pieza", 20),
    ("MOD-005", "Módulo Display LCD 16x2", "Pantalla alfanumérica", 100.00, "pieza", 5),
]

print("Iniciando inserción con stock...")

for codigo, nombre, descripcion, precio, unidad, stock in productos:
    
    query = """
        INSERT INTO "PRODUCTO" (codigo_producto, nombre, descripcion, precio_unitario, unidad_medida, stock)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT (codigo_producto) 
        DO UPDATE SET stock = EXCLUDED.stock; 
    """
    cur.execute(query, (codigo, nombre, descripcion, precio, unidad, stock))

conn.commit()
cur.close()
conn.close()

print("✅ Se insertaron los productos con sus cantidades de STOCK.")