import random
from PySide6.QtCore import QObject, Slot
from src.database.connection import get_db_connection  # <--- Tu conexión real

class InventoryController(QObject):
    def __init__(self, ui_model):
        super().__init__()
        self.ui_model = ui_model 
        # No guardamos la conexión aquí, la abrimos y cerramos por operación
        # para evitar problemas de hilos con psycopg2.

    @Slot(str, str, str, int)
    def create_product(self, nombre, descripcion, precio, stock_inicial):
        # 1. Generar Código
        clean_name = nombre.replace(" ", "").upper()
        prefix = clean_name[:3] if len(clean_name) >= 3 else clean_name.ljust(3, 'X')
        suffix = random.randint(1000, 9999)
        codigo_generado = f"{prefix}-{suffix}"

        # 2. Validar precio
        precio_final = 0.0
        try:
            if precio:
                precio_final = float(precio)
        except ValueError:
            precio_final = 0.0

        conn = None
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            
            # 3. Insertar con SQL PURO
            query = """
                INSERT INTO "PRODUCTO" 
                (codigo_producto, nombre, descripcion, precio_unitario, stock)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id_producto;
            """
            cur.execute(query, (codigo_generado, nombre, descripcion, precio_final, stock_inicial))
            
            # Obtener el ID generado
            new_id = cur.fetchone()[0]
            conn.commit()
            
            # 4. Actualizar la UI
            prod_dict = {
                "id_producto": new_id,
                "codigo": codigo_generado,
                "nombre": nombre,
                "descripcion": descripcion,
                "precio": str(precio_final),
                "stock": stock_inicial
            }
            
            self.ui_model.add_product_ui(prod_dict)
            print(f"✅ Producto creado: {nombre} (ID: {new_id})")
            
            cur.close()

        except Exception as e:
            if conn: conn.rollback()
            print(f"❌ Error creando producto: {e}")
        finally:
            if conn: conn.close()

    @Slot(int, int)
    def update_stock(self, id_producto, nuevo_stock):
        conn = None
        try:
            conn = get_db_connection()
            cur = conn.cursor()

            # 1. Actualizar con SQL PURO
            query = 'UPDATE "PRODUCTO" SET stock = %s WHERE id_producto = %s'
            cur.execute(query, (nuevo_stock, id_producto))
            conn.commit()

            # 2. Actualizar UI
            self.ui_model.update_stock_ui(id_producto, nuevo_stock)
            print(f"✅ Stock actualizado ID {id_producto}: {nuevo_stock}")
            
            cur.close()

        except Exception as e:
            if conn: conn.rollback()
            print(f"❌ Error actualizando stock: {e}")
        finally:
            if conn: conn.close()