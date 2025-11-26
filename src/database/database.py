import psycopg2


def get_db_connection():
    return psycopg2.connect(
        dbname="CastorTesla",
        user="postgres",
        password="160603",
        host="localhost",
        port="5432"
    )


def load_products():
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute("""
            SELECT codigo_producto, nombre, precio_unitario, stock, descripcion
            FROM "PRODUCTO"
            ORDER BY id_producto ASC
        """)

        products = []

        for code, name, price, stock, description in cur.fetchall():
            products.append({
                "codigo": code,
                "nombre": name,
                "precio": float(price) if price else 0.0,
                "stock": stock,
                "descripcion": description
            })

        cur.close()
        conn.close()

        return products

    except Exception:
        return []


def check_user_login(user_email, password):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        query = """
            SELECT id_usuario 
            FROM "USUARIO" 
            WHERE email = %s AND password = %s
        """
        cur.execute(query, (user_email, password))

        result = cur.fetchone()
        conn.close()

        return True if result else False

    except Exception:
        return False


def get_product_by_code(code):
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute("""
            SELECT id_producto, codigo_producto, nombre, precio_unitario, stock
            FROM "PRODUCTO"
            WHERE codigo_producto = %s
        """, (code,))

        row = cur.fetchone()
        conn.close()

        if row:
            return {
                "id": row[0],
                "codigo": row[1],
                "nombre": row[2],
                "precio": float(row[3]),
                "stock": row[4]
            }

        return None

    except Exception:
        return None


def save_sale_transaction(user_id, total, cart_items):
    conn = get_db_connection()
    try:
        cur = conn.cursor()

        cur.execute("""
            INSERT INTO "VENTA" (id_usuario, total_venta, sucursal)
            VALUES (%s, %s, 'Tonalá')
            RETURNING id_venta
        """, (user_id, total))

        id_venta = cur.fetchone()[0]

        for item in cart_items:
            cur.execute("""
                INSERT INTO "DETALLE_VENTA" 
                    (id_venta, id_producto, cantidad, precio_unitario, subtotal)
                VALUES (%s, %s, %s, %s, %s)
            """, (
                id_venta,
                item['id'],
                item['cantidad'],
                item['precio'],
                item['subtotal']
            ))

            cur.execute("""
                UPDATE "PRODUCTO" 
                SET stock = stock - %s 
                WHERE id_producto = %s
            """, (item['cantidad'], item['id']))

        conn.commit()
        cur.close()
        conn.close()

        return True, "Venta exitosa"

    except Exception as e:
        conn.rollback()
        return False, str(e)


def get_sales_history():
    try:
        conn = get_db_connection()
        cur = conn.cursor()

        cur.execute("""
            SELECT 
                v.id_venta, 
                v.fecha_venta, 
                v.total_venta, 
                u.nombre
            FROM "VENTA" v
            JOIN "USUARIO" u ON v.id_usuario = u.id_usuario
            ORDER BY v.fecha_venta DESC
        """)

        ventas_raw = cur.fetchall()
        sales_list = []

        for venta in ventas_raw:
            id_venta = venta[0]
            fecha = venta[1].strftime("%Y-%m-%d %H:%M") if venta[1] else ""
            total = float(venta[2])
            vendedor = venta[3]

            cur.execute("""
                SELECT p.nombre, d.cantidad, d.precio_unitario, d.subtotal
                FROM "DETALLE_VENTA" d
                JOIN "PRODUCTO" p ON d.id_producto = p.id_producto
                WHERE d.id_venta = %s
            """, (id_venta,))

            detalles = []
            for prod in cur.fetchall():
                detalles.append({
                    "producto": prod[0],
                    "cantidad": prod[1],
                    "precio": prod[2],
                    "subtotal": prod[3]
                })

            sales_list.append({
                "id_venta": str(id_venta),
                "fecha": fecha,
                "total": f"${total:,.2f}",
                "vendedor": vendedor,
                "detalles": detalles
            })

        cur.close()
        conn.close()
        return sales_list

    except Exception:
        return []
