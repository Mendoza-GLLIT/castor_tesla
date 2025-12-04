from src.database.connection import get_db_connection
import os

def get_notifications():
    """Obtiene las notificaciones ordenadas por fecha (las más nuevas primero)."""
    conn = get_db_connection()
    if not conn:
        return []
    try:
        cur = conn.cursor()
        query = """
            SELECT 
                id_notificacion, 
                titulo, 
                mensaje, 
                tipo, 
                COALESCE(icon, ''), 
                to_char(fecha_creacion, 'DD/MM/YYYY HH24:MI')
            FROM "NOTIFICACION"
            ORDER BY fecha_creacion DESC
            LIMIT 50
        """
        cur.execute(query)
        rows = cur.fetchall()

        msgs = []
        for r in rows:
            icon_path = r[4]

            # Convertimos a ruta absoluta SOLO si existe algo
            if icon_path:
                icon_path = os.path.abspath(icon_path)

            msgs.append({
                "id": r[0],
                "titulo": r[1],
                "mensaje": r[2],
                "tipo": r[3],
                "icon": icon_path,   # <-- ahora NUNCA será undefined
                "fecha": r[5]
            })
        return msgs

    except Exception as e:
        print(f"❌ Error obteniendo mensajes: {e}")
        return []
    finally:
        conn.close()


def create_notification(titulo, mensaje, tipo='info', icon_path=None):
    """Crea una notificación en la BD."""
    
    if icon_path:
        icon_path = os.path.abspath(icon_path)

    conn = get_db_connection()
    if not conn:
        return False

    try:
        cur = conn.cursor()
        query = """
            INSERT INTO "NOTIFICACION" (titulo, mensaje, tipo, icon)
            VALUES (%s, %s, %s, %s)
        """
        cur.execute(query, (titulo, mensaje, tipo, icon_path))
        conn.commit()
        return True

    except Exception as e:
        print(f"❌ Error creando notificación: {e}")
        return False

    finally:
        conn.close()
