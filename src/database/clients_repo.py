from src.database.connection import get_db_connection

def get_all_clients():
    conn = get_db_connection()
    if not conn: return []
    try:
        cur = conn.cursor()
        # Traemos todas las columnas que definiste en tu tabla
        query = """
            SELECT id_cliente, nombre_empresa, rfc, direccion, telefono, email 
            FROM "CLIENTE" 
            ORDER BY nombre_empresa ASC
        """
        cur.execute(query)
        rows = cur.fetchall()
        clients = []
        for r in rows:
            clients.append({
                "id": r[0],
                "nombre": r[1],
                "rfc": r[2] if r[2] else "",
                "direccion": r[3] if r[3] else "",
                "telefono": r[4] if r[4] else "",
                "email": r[5] if r[5] else ""
            })
        return clients
    except Exception as e:
        print(f"❌ Error obteniendo clientes: {e}")
        return []
    finally:
        conn.close()

def create_client(nombre, rfc, direccion, telefono, email):
    conn = get_db_connection()
    if not conn: return False
    try:
        cur = conn.cursor()
        query = """
            INSERT INTO "CLIENTE" (nombre_empresa, rfc, direccion, telefono, email)
            VALUES (%s, %s, %s, %s, %s)
        """
        cur.execute(query, (nombre, rfc, direccion, telefono, email))
        conn.commit()
        return True
    except Exception as e:
        print(f"❌ Error creando cliente: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()

def update_client(client_id, nombre, rfc, direccion, telefono, email):
    conn = get_db_connection()
    if not conn: return False
    try:
        cur = conn.cursor()
        query = """
            UPDATE "CLIENTE" 
            SET nombre_empresa=%s, rfc=%s, direccion=%s, telefono=%s, email=%s
            WHERE id_cliente=%s
        """
        cur.execute(query, (nombre, rfc, direccion, telefono, email, client_id))
        conn.commit()
        return True
    except Exception as e:
        print(f"❌ Error actualizando cliente: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()

def delete_client(client_id):
    conn = get_db_connection()
    if not conn: return False
    try:
        cur = conn.cursor()
        # Ojo: Si tiene ventas asociadas, esto podría fallar por FK.
        # Lo ideal es manejar soft-delete (activo=false), pero para este ejemplo borramos.
        cur.execute('DELETE FROM "CLIENTE" WHERE id_cliente = %s', (client_id,))
        conn.commit()
        return True
    except Exception as e:
        print(f"❌ Error eliminando cliente: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()