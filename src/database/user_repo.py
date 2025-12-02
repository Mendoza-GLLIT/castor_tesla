from src.database.connection import get_db_connection

def check_user_login(email_or_username, password):
    """
    Verifica credenciales. Acepta Email O Username.
    """
    try:
        conn = get_db_connection()
        if not conn: return None
        
        cur = conn.cursor()
        
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

# --- NUEVAS FUNCIONES CRUD ---

def get_all_users():
    try:
        conn = get_db_connection()
        if not conn: return []
        cur = conn.cursor()
        
        # Traemos también el nombre del rol para mostrarlo en la tabla
        query = """
            SELECT u.id_usuario, u.username, u.nombre, u.apellido, u.email, u.password, u.id_rol, r.nombre_rol
            FROM "USUARIO" u
            JOIN "ROL" r ON u.id_rol = r.id_rol
            ORDER BY u.id_usuario ASC
        """
        cur.execute(query)
        rows = cur.fetchall()
        conn.close()
        
        users = []
        for row in rows:
            users.append({
                "id": row[0],
                "username": row[1],
                "nombre": row[2],
                "apellido": row[3],
                "email": row[4],
                "password": row[5], # Ojo: En prod no deberías devolver passwords planos
                "id_rol": row[6],
                "nombre_rol": row[7]
            })
        return users
    except Exception as e:
        print(f"❌ Error get_all_users: {e}")
        return []

def get_all_roles():
    try:
        conn = get_db_connection()
        if not conn: return []
        cur = conn.cursor()
        cur.execute('SELECT id_rol, nombre_rol FROM "ROL" ORDER BY id_rol ASC')
        rows = cur.fetchall()
        conn.close()
        return [{"id": r[0], "nombre": r[1]} for r in rows]
    except Exception as e:
        print(f"❌ Error get_all_roles: {e}")
        return []

def create_user_db(username, nombre, apellido, email, password, id_rol):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        query = """
            INSERT INTO "USUARIO" (username, nombre, apellido, email, password, id_rol)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        cur.execute(query, (username, nombre, apellido, email, password, id_rol))
        conn.commit()
        cur.close()
        conn.close()
        return True, "Usuario creado exitosamente"
    except Exception as e:
        return False, str(e)

def update_user_db(id_user, username, nombre, apellido, email, password, id_rol):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        query = """
            UPDATE "USUARIO" 
            SET username=%s, nombre=%s, apellido=%s, email=%s, password=%s, id_rol=%s
            WHERE id_usuario=%s
        """
        cur.execute(query, (username, nombre, apellido, email, password, id_rol, id_user))
        conn.commit()
        cur.close()
        conn.close()
        return True, "Usuario actualizado exitosamente"
    except Exception as e:
        return False, str(e)

def delete_user_db(id_user):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('DELETE FROM "USUARIO" WHERE id_usuario = %s', (id_user,))
        conn.commit()
        cur.close()
        conn.close()
        return True, "Usuario eliminado"
    except Exception as e:
        return False, str(e)