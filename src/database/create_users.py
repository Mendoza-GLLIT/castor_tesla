# crear_usuarios.py
import psycopg2
from database import get_db_connection


def create_data():
    conn = get_db_connection()
    try:
        cur = conn.cursor()

        print("1. Creando Roles...")

        # Insertar ROL Admin y Client 
        roles_sql = """
        INSERT INTO "ROL" (id_rol, nombre_rol, descripcion) 
        VALUES 
            (1, 'admin', 'Administrador del sistema'),
            (2, 'client', 'Cliente o usuario regular')
        ON CONFLICT (id_rol) DO NOTHING;
        """
        cur.execute(roles_sql)

        print("2. Creando Usuarios...")

        # Lista de usuarios por defecto 
        users = [
            ('Mendo', '23310035', 1),
            ('Dulce', '23310004', 1),
            ('Valente', '23310012', 1)
        ]

        # SQL para insertar usuario
        user_sql = """
        INSERT INTO "USUARIO" (nombre, apellido, email, password, id_rol)
        VALUES (%s, '', %s, %s, %s);
        """

        for name, pwd, role_id in users:

            # Revisar si el usuario ya existe por email
            cur.execute(
                'SELECT id_usuario FROM "USUARIO" WHERE email = %s',
                (name,)
            )

            if cur.fetchone() is None:
                cur.execute(user_sql, (name, name, pwd, role_id))
                print(f"   -> Usuario {name} creado.")
            else:
                print(f"   -> Usuario {name} ya existía.")

        conn.commit()
        print("\n✅ ¡Listo! Usuarios y roles creados correctamente.")

    except Exception as e:
        print(f"❌ Error: {e}")
        conn.rollback()

    finally:
        conn.close()


if __name__ == "__main__":
    create_data()
