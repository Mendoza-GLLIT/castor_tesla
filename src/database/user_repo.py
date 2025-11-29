from src.database.connection import get_db_connection

def check_user_login(user_email, password):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        query = """
            SELECT u.id_usuario, u.nombre, u.apellido, r.nombre_rol
            FROM "USUARIO" u
            JOIN "ROL" r ON u.id_rol = r.id_rol
            WHERE u.email = %s AND u.password = %s
        """
        cur.execute(query, (user_email, password))
        row = cur.fetchone()
        conn.close()

        if row:
            return {
                "id": row[0],
                "nombre": row[1],
                "apellido": row[2],
                "rol": row[3]
            }
        return None
    except Exception as e:
        print(f"Error Login: {e}")
        return None