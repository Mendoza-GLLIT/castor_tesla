# 🔷 Castor Tesla - Sistema de Punto de Venta (POS)

¡Bienvenido a **Castor Tesla**!

Este es un sistema integral de gestión de inventario y Punto de Venta diseñado para ofrecer una experiencia de usuario moderna, fluida y eficiente. Desarrollado con **Python** y **Qt (QML)**, el sistema permite administrar productos, realizar ventas en tiempo real y visualizar historiales de transacciones de manera intuitiva.

El proyecto sigue una arquitectura **MVC (Modelo-Vista-Controlador)** estricta, separando la lógica de negocio, la gestión de datos y la interfaz gráfica para garantizar un código limpio, escalable y fácil de mantener.

---

## 🚀 Tecnologías Utilizadas

El núcleo del sistema combina la potencia de Python con la flexibilidad visual de QML y la robustez de PostgreSQL.

* **Lenguaje:** Python 3.10+
* **Interfaz Gráfica (GUI):** [PySide6](https://pypi.org/project/PySide6/) (Qt for Python) con **QML**.
* **Base de Datos:** PostgreSQL.
* **ORM y Conectores:** SQLAlchemy y Psycopg2.
* **Arquitectura:** MVC (Model-View-Controller).

### 📂 Estructura del Proyecto
El código está organizado para mantener el orden y la modularidad:

```text
CastorTesla/
│
├── main.py                 # Punto de entrada (Entry Point)
├── requirements.txt        # Dependencias del proyecto
├── src/
│   ├── controllers/        # Lógica de negocio (Puente entre UI y BD)
│   │   ├── controller.py       # Navegación y Login
│   │   └── pos_controller.py   # Lógica de Ventas y Carrito
│   ├── models/             # Modelos de datos para QML (QAbstractListModel)
│   │   ├── cart_model.py       # Modelo dinámico del carrito
│   │   ├── sales_model.py      # Modelo de historial de ventas
│   │   └── models.py           # Modelos generales
│   ├── database/           # Conexión y consultas SQL (PostgreSQL)
│   ├── ui/                 # Vistas QML (Interfaz de Usuario)
│   │   ├── views/              # Pantallas (POS, Sales, Inventory)
│   │   └── resources/          # Assets (Iconos, Imágenes)



⚙️ Guía de Instalación y Despliegue
Para mantener el proyecto limpio, se recomienda crear el Entorno Virtual fuera de la carpeta del código fuente. Sigue estos pasos para desplegar el proyecto en tu máquina local.

1. Pre-requisitos
- Tener instalado Python 3.x.
- Tener instalado PostgreSQL y el servicio en ejecución.
- Tener creada la base de datos llamada CastorTesla en tu servidor local.

2. Creación del Entorno Virtual
- Abre tu terminal (CMD, PowerShell o Bash). Supongamos que has descargado la carpeta del proyecto llamada CastorTesla.
- Ubicarse un nivel atrás de la carpeta del proyecto (en la carpeta padre):
    cd ruta/donde/guardaste/el/proyecto
- Crear el entorno virtual (lo llamaremos env):
    python -m venv env
    (Esto creará la carpeta env junto a la carpeta CastorTesla, no adentro).
- Activar el entorno virtual:
    source env/bin/activate
    (Sabrás que está activo porque verás (env) al inicio de tu terminal).

3. Instalación de Dependencias
- Una vez activo el entorno, entra a la carpeta del proyecto e instala las librerías:
    pip install -r requirements.txt

4. Configuración de Base de Datos
- Verifica que el archivo src/database/database.py tenga las credenciales correctas de tu base de datos local:
    User: postgres (u otro)
    Password: Tu contraseña
    Port: 5432

▶️ Ejecución del Proyecto
- Con el entorno virtual activo y las dependencias instaladas, puedes iniciar el sistema ejecutando el archivo principal:
    python main.py
    El sistema abrirá la ventana de Login.

Usuarios de prueba: 
    user: Mendo
    password: 23310035
    user: Valente
    password: 23310012
    user: Dulce
    password: 23310004
