from src.database.connection import get_db_connection

def load_products():
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        
        # CONSULTA DIRECTA
        query = """
            SELECT id_producto, codigo_producto, nombre, precio_unitario, stock, descripcion
            FROM "PRODUCTO"
            ORDER BY nombre ASC
        """
        
        cur.execute(query)
        products = []
        
        for pid, code, name, price, stock, desc in cur.fetchall():
            products.append({
                # --- CORRECCIÓN AQUÍ ---
                "id_producto": pid,      # Antes decia "id", ahora coincide con el modelo
                # -----------------------
                "codigo": code,
                "nombre": name,
                "precio": float(price) if price else 0.0,
                "stock": int(stock), 
                "descripcion": desc
            })
        conn.close()
        return products
    except Exception as e:
        print(f"❌ Error en load_products: {e}")
        return []
    
    
# src/database/product_repo.py

def get_product_by_code(code):
    try:
        conn = get_db_connection()
        if not conn: return None
        cur = conn.cursor()

        # CONSULTA DIRECTA
        query = """
            SELECT id_producto, codigo_producto, nombre, precio_unitario, stock
            FROM "PRODUCTO" 
            WHERE codigo_producto = %s
        """
        
        cur.execute(query, (code,))
        row = cur.fetchone()
        conn.close()

        if row:
            return {
                # --- ESTO ES EL BLINDAJE ---
                "id": row[0],           # <--- INDISPENSABLE para el POS (CartModel)
                "id_producto": row[0],  # <--- INDISPENSABLE para el Inventario
                # ---------------------------
                "codigo": row[1],
                "nombre": row[2],
                "precio": float(row[3]),
                "stock": int(row[4])
            }
        
        return None

    except Exception as e:
        print(f"❌ Error en get_product_by_code: {e}")
        return None