from src.database.connection import get_db_connection

def save_sale_transaction(user_id, client_id, total, cart_items):
    """
    Registra una venta, sus detalles y descuenta el stock.
    Argumentos:
      user_id: ID del usuario (Cajero)
      client_id: ID del cliente seleccionado
      total: Monto total de la venta
      cart_items: Lista de diccionarios con productos
    """
    conn = get_db_connection()
    if not conn:
        return False, "Error de conexión a la BD"

    try:
        cur = conn.cursor()
        
        # 1. INSERTAR CABECERA DE VENTA
        # Quitamos 'sucursal' y agregamos 'id_cliente'
        query_venta = """
            INSERT INTO "VENTA" (id_usuario, id_cliente, total_venta)
            VALUES (%s, %s, %s) 
            RETURNING id_venta
        """
        cur.execute(query_venta, (user_id, client_id, total))
        id_venta = cur.fetchone()[0]

        # 2. INSERTAR DETALLES Y ACTUALIZAR STOCK
        query_detalle = """
            INSERT INTO "DETALLE_VENTA" (id_venta, id_producto, cantidad, precio_unitario, subtotal)
            VALUES (%s, %s, %s, %s, %s)
        """
        
        # Como eliminamos la tabla INVENTARIO, el stock está directo en PRODUCTO
        query_stock = """
            UPDATE "PRODUCTO" 
            SET stock = stock - %s 
            WHERE id_producto = %s
        """

        for item in cart_items:
            # Insertar detalle
            cur.execute(query_detalle, (
                id_venta, 
                item['id'], 
                item['cantidad'], 
                item['precio'], 
                item['subtotal']
            ))

            # Restar Stock
            cur.execute(query_stock, (item['cantidad'], item['id']))

        conn.commit()
        cur.close()
        conn.close()
        return True, "Venta registrada exitosamente"

    except Exception as e:
        if conn:
            conn.rollback()
            conn.close()
        print(f"❌ Error en transacción: {e}")
        return False, str(e)


def get_sales_history():
    conn = get_db_connection()
    sales_data = []
    
    if not conn:
        return []

    try:
        cur = conn.cursor()
        
        # 1. Consulta corregida con tus columnas REALES
        # VENTA: id_venta, fecha_venta, total_venta
        # USUARIO: nombre (puedes concatenar apellido si quieres)
        # CLIENTE: nombre_empresa
        query_ventas = """
            SELECT 
                v.id_venta, 
                c.nombre_empresa, 
                u.nombre, 
                v.fecha_venta, 
                v.total_venta
            FROM "VENTA" v
            JOIN "CLIENTE" c ON v.id_cliente = c.id_cliente
            JOIN "USUARIO" u ON v.id_usuario = u.id_usuario
            ORDER BY v.fecha_venta DESC
        """
        cur.execute(query_ventas)
        rows_ventas = cur.fetchall()

        for row in rows_ventas:
            venta_id = row[0]
            
            # 2. Detalles usando DETALLE_VENTA y PRODUCTO
            query_detalles = """
                SELECT p.nombre, dv.cantidad, dv.subtotal
                FROM "DETALLE_VENTA" dv
                JOIN "PRODUCTO" p ON dv.id_producto = p.id_producto
                WHERE dv.id_venta = %s
            """
            cur.execute(query_detalles, (venta_id,))
            rows_detalles = cur.fetchall()
            
            lista_detalles = []
            for det in rows_detalles:
                lista_detalles.append({
                    "producto": det[0],
                    "cantidad": det[1],
                    "subtotal": float(det[2])
                })

            # 3. Mapeo exacto para QML
            sales_data.append({
                "id_venta": str(venta_id),
                "cliente": row[1], # nombre_empresa
                "vendedor": row[2], # u.nombre
                "fecha": str(row[3]), # fecha_venta
                "total": f"${float(row[4]):.2f}", # total_venta
                "detalles": lista_detalles
            })

        cur.close()
        conn.close()
        return sales_data

    except Exception as e:
        print(f"❌ Error obteniendo historial: {e}")
        return []