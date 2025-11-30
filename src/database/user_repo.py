from src.database.connection import get_db_connection

def check_user_login(email_or_username, password):
    """
    Verifica credenciales. Acepta Email O Username.
    """
    try:
        conn = get_db_connection()
        if not conn: return None
        
        cur = conn.cursor()
        
        # Buscamos por email (preferente) o por username, y verificamos password
        query = """
            SELECT u.id_usuario, u.username, u.nombre, u.apellido, u.email, r.nombre_rol
            FROM "USUARIO" u
            JOIN "ROL" r ON u.id_rol = r.id_rol
            WHERE (u.email = %s OR u.username = %s) AND u.password = %s
        """
        cur.execute(query, (email_or_username, email_or_username, password))
        
        row = cur.fetchone()
        conn.close()
        
        if row:
            return {
                "id": row[0],
                "username": row[1],
                "nombre": row[2],
                "apellido": row[3],
                "email": row[4],
                "rol": row[5]
            }
        return None
        
    except Exception as e:
        print(f"Error en Login: {e}")
        return None