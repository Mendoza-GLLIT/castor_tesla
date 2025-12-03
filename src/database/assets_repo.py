from src.database.connection import get_db_connection

def get_all_assets():
    conn = get_db_connection()
    if not conn: return []
    try:
        cur = conn.cursor()
        # JOIN para traer el nombre del empleado responsable
        query = """
            SELECT 
                a.id_activo, a.codigo_activo, a.nombre, a.descripcion, 
                a.ubicacion, a.id_responsable, 
                u.nombre || ' ' || u.apellido as responsable_nombre
            FROM "ACTIVO_FIJO" a
            LEFT JOIN "USUARIO" u ON a.id_responsable = u.id_usuario
            ORDER BY a.nombre ASC
        """
        cur.execute(query)
        rows = cur.fetchall()
        assets = []
        for r in rows:
            assets.append({
                "id": r[0],
                "codigo": r[1],
                "nombre": r[2],
                "descripcion": r[3] if r[3] else "",
                "ubicacion": r[4] if r[4] else "Sin asignar",
                "id_responsable": r[5] if r[5] else 0,
                "responsable_nombre": r[6] if r[6] else "Sin Asignar"
            })
        return assets
    except Exception as e:
        print(f"❌ Error obteniendo activos: {e}")
        return []
    finally:
        conn.close()

def create_asset(codigo, nombre, descripcion, ubicacion, id_responsable):
    conn = get_db_connection()
    if not conn: return False
    try:
        cur = conn.cursor()
        # Manejo de responsable nulo (0 = NULL)
        resp_val = id_responsable if id_responsable > 0 else None
        
        query = """
            INSERT INTO "ACTIVO_FIJO" (codigo_activo, nombre, descripcion, ubicacion, id_responsable)
            VALUES (%s, %s, %s, %s, %s)
        """
        cur.execute(query, (codigo, nombre, descripcion, ubicacion, resp_val))
        conn.commit()
        return True
    except Exception as e:
        print(f"❌ Error creando activo: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()

def update_asset(asset_id, codigo, nombre, descripcion, ubicacion, id_responsable):
    conn = get_db_connection()
    if not conn: return False
    try:
        cur = conn.cursor()
        resp_val = id_responsable if id_responsable > 0 else None
        
        query = """
            UPDATE "ACTIVO_FIJO" 
            SET codigo_activo=%s, nombre=%s, descripcion=%s, ubicacion=%s, id_responsable=%s
            WHERE id_activo=%s
        """
        cur.execute(query, (codigo, nombre, descripcion, ubicacion, resp_val, asset_id))
        conn.commit()
        return True
    except Exception as e:
        print(f"❌ Error actualizando activo: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()

def delete_asset(asset_id):
    conn = get_db_connection()
    if not conn: return False
    try:
        cur = conn.cursor()
        cur.execute('DELETE FROM "ACTIVO_FIJO" WHERE id_activo = %s', (asset_id,))
        conn.commit()
        return True
    except Exception as e:
        print(f"❌ Error eliminando activo: {e}")
        conn.rollback()
        return False
    finally:
        conn.close()