import random
from PySide6.QtCore import QObject, Slot
from src.database.connection import get_db_connection
from src.database.messages_repo import create_notification

class InventoryController(QObject):
    def __init__(self, ui_model):
        super().__init__()
        self.ui_model = ui_model 

    @Slot(str, str, str, int)
    def create_product(self, nombre, descripcion, precio, stock_inicial):
        clean_name = nombre.replace(" ", "").upper()
        prefix = clean_name[:3] if len(clean_name) >= 3 else clean_name.ljust(3, 'X')
        suffix = random.randint(1000, 9999)
        codigo_generado = f"{prefix}-{suffix}"

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
            
            query = """
                INSERT INTO "PRODUCTO" 
                (codigo_producto, nombre, descripcion, precio_unitario, stock)
                VALUES (%s, %s, %s, %s, %s)
                RETURNING id_producto;
            """
            cur.execute(query, (codigo_generado, nombre, descripcion, precio_final, stock_inicial))
            
            new_id = cur.fetchone()[0]
            conn.commit()
            
            prod_dict = {
                "id_producto": new_id,
                "codigo": codigo_generado,
                "nombre": nombre,
                "descripcion": descripcion,
                "precio": str(precio_final),
                "stock": stock_inicial
            }
            
            self.ui_model.add_product_ui(prod_dict)

            # Notificación sin icono especial
            create_notification(
                "Nuevo Producto",
                f"Registrado: {nombre} ({stock_inicial} un.)",
                "success",
                "resources/icons/success.png"  # si no tienes este, bórralo
            )

            cur.close()

        except Exception as e:
            if conn: conn.rollback()
            print(f"Error creando producto: {e}")
        finally:
            if conn: conn.close()

    @Slot(int, int)
    def update_stock(self, id_producto, nuevo_stock):
        conn = None
        try:
            conn = get_db_connection()
            cur = conn.cursor()

            query = 'UPDATE "PRODUCTO" SET stock = %s WHERE id_producto = %s'
            cur.execute(query, (nuevo_stock, id_producto))
            conn.commit()

            self.ui_model.update_stock_ui(id_producto, nuevo_stock)

            nombre_producto = "Producto"
            
            for p in self.ui_model._all_products:
                if p['id_producto'] == id_producto:
                    nombre_producto = p['nombre']
                    break

            # Info normal → sin emoji
            create_notification(
                "Stock Actualizado",
                f"El stock de '{nombre_producto}' se ajustó a {nuevo_stock} unidades.",
                "info",
                "resources/icons/info.png"  # si lo tienes
            )

            # STOCK CRÍTICO (<500)
            if nuevo_stock < 500:
                create_notification(
                    "Stock Crítico",
                    f"URGENTE: '{nombre_producto}' tiene menos de 500 unidades ({nuevo_stock}). ¡Resurtir!",
                    "critical",
                    "resources/icons/alert.png"
                )

            # STOCK BAJO (<1000)
            elif nuevo_stock < 1000:
                create_notification(
                    "Advertencia de Stock",
                    f"'{nombre_producto}' está bajando ({nuevo_stock} unidades).",
                    "warning",
                    "resources/icons/warning.png"
                )
            
            cur.close()

        except Exception as e:
            if conn: conn.rollback()
            print(f"❌ Error actualizando stock: {e}")
        finally:
            if conn: conn.close()

    def scan_all_low_stock(self):
        """Escaneo inicial al abrir la app"""
        print("Escaneando inventario...")
        conn = get_db_connection()
        if not conn: return

        try:
            cur = conn.cursor()
            query = 'SELECT nombre, stock, codigo_producto FROM "PRODUCTO" WHERE stock < 1000'
            cur.execute(query)
            rows = cur.fetchall()
            
            for r in rows:
                nombre, stock, codigo = r

                if stock < 500:
                    create_notification(
                        "Stock Crítico",
                        f"{nombre} ({codigo}) está por debajo del mínimo ({stock} u).",
                        "critical",
                        "resources/icons/alert.png"
                    )
                else:
                    create_notification(
                        "Stock Bajo",
                        f"{nombre} ({codigo}) tiene stock bajo ({stock} u).",
                        "warning",
                        "resources/icons/warning.png"
                    )
            
        except Exception as e:
            print(f"Error en escaneo inicial: {e}")
        finally:
            conn.close()

    @Slot(int, str, str, str, int)
    def update_product(self, id_producto, nombre, descripcion, precio, stock):
        precio_final = 0.0
        try:
            precio_final = float(precio)
        except ValueError:
            precio_final = 0.0

        conn = None
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            
            query = """
                UPDATE "PRODUCTO" 
                SET nombre=%s, descripcion=%s, precio_unitario=%s
                WHERE id_producto=%s
            """
            cur.execute(query, (nombre, descripcion, precio_final, id_producto))
            conn.commit()
            
            self.ui_model.update_product_ui(id_producto, nombre, descripcion, precio_final)
            
            create_notification(
                "Producto Actualizado",
                f"Datos actualizados para '{nombre}'.",
                "info",
                "resources/icons/info.png"
            )

            cur.close()

        except Exception as e:
            if conn: conn.rollback()
            print(f"Error actualizando: {e}")
        finally:
            if conn: conn.close()

    @Slot(int)
    def delete_product(self, id_producto):
        conn = None
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            
            cur.execute('DELETE FROM "PRODUCTO" WHERE id_producto = %s', (id_producto,))
            conn.commit()
            
            self.ui_model.delete_product_ui(id_producto)
            
            create_notification(
                "Producto Eliminado",
                "El producto ha sido eliminado correctamente.",
                "warning",
                "resources/icons/warning.png"
            )
            cur.close()

        except Exception as e:
            if conn: conn.rollback()
            print(f"Error eliminando: {e}")
            create_notification(
                "Error Eliminando",
                "No se puede eliminar (posiblemente tiene ventas asociadas).",
                "critical",
                "resources/icons/alert.png"
            )
        finally:
            if conn: conn.close()
