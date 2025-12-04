🔷 **Castor Tesla - Sistema de Punto de Venta (POS)**

Castor Tesla es un sistema integral de gestión de inventario y Punto de Venta diseñado para ofrecer una experiencia de usuario moderna, fluida y eficiente.

Desarrollado con Python y Qt (QML), el sistema permite administrar productos, realizar ventas en tiempo real y visualizar historiales de transacciones de manera intuitiva. El proyecto sigue una arquitectura MVC (Modelo-Vista-Controlador) estricta, separando la lógica de negocio, la gestión de datos y la interfaz gráfica para garantizar un código limpio y escalable.

---

## 🚀 **Tecnologías Utilizadas**

- **Lenguaje:** Python 3.10+
- **Interfaz Gráfica (GUI):** PySide6 (Qt for Python) con QML
- **Base de Datos:** PostgreSQL
- **ORM y Conectores:** SQLAlchemy y Psycopg2
- **Arquitectura:** MVC

---

## 📂 **Estructura del Proyecto**
Aquí tienes la estructura formateada específicamente para ser copiada y pegada en un archivo README.md.

He añadido una breve descripción de la arquitectura (MVC) para dar contexto a quien lea la documentación, ya que tu estructura separa claramente Lógica, Modelos y Vista.

Opción 1: Bloque de Código (Copiar y Pegar)
Markdown

## 📂 Estructura del Proyecto

El proyecto sigue una arquitectura modular basada en el patrón **MVC (Modelo-Vista-Controlador)** adaptado para **PySide6** y **QML**. El código fuente se encuentra en el directorio `src/`, separando la lógica de negocio de la interfaz de usuario.

```text
castor_tesla/
│
├── main.py                     # Punto de entrada (Inicia la app, carga estilos y rutas)
├── requirements.txt            # Dependencias del proyecto (PySide6, SQLAlchemy, psycopg2)
├── .gitignore                  # Archivos excluidos del control de versiones
├── README.md                   # Documentación general
│
├── resources/                  # Archivos estáticos y multimedia
│   └── icons/                  # Iconos e imágenes (assets gráficos)
│
└── src/                        # Código Fuente Principal
    │
    ├── database/               # CAPA DE DATOS (Repositories)
    │   ├── connection.py       # Configuración del pool de conexión a PostgreSQL
    │   ├── *_repo.py           # Scripts de consultas SQL directas por entidad
    │   └── stats_repo.py       # Consultas complejas para reportes y KPIs
    │
    ├── models/                 # CAPA DE MODELOS (Qt Models)
    │   ├── models.py           # Modelos genéricos
    │   ├── cart_model.py       # Lógica reactiva del carrito de compras
    │   └── sales_model.py      # Modelo para visualización de tablas en QML
    │
    ├── controllers/            # CAPA DE CONTROLADORES (Business Logic)
    │   ├── auth_controller.py  # Gestión de sesión (Login/Logout)
    │   ├── pos_controller.py   # Orquestador del Punto de Venta
    │   └── *_controller.py     # Lógica CRUD puente entre UI y Base de Datos
    │
    └── ui/                     # CAPA DE VISTA (Interfaz QML)
        ├── login.qml           # Ventana de autenticación
        ├── dashboard.qml       # Window principal y layout
        ├── sidebar.qml         # Navegación lateral
        │
        └── views/              # Pantallas principales del sistema
            ├── pos.qml         # Interfaz de Punto de Venta
            ├── inventory.qml   # Gestión de inventario
            ├── statistics.qml  # Dashboards visuales
            └── *.qml           # Vistas de módulos específicos (Clientes, Activos, etc.)
```

## ⚙️ **Guía de Instalación y Despliegue**

Para mantener el proyecto limpio, se recomienda crear el Entorno Virtual fuera de la carpeta del código fuente.

### 1. Pre-requisitos

- Tener instalado **Python 3.x**.
- Tener instalado **PostgreSQL** y el servicio en ejecución.
- Tener creada la base de datos llamada **CastorTesla** en tu servidor local.

### 2. Creación del Entorno Virtual

Abre tu terminal y ubícate en la carpeta padre del proyecto:


# Crear el entorno virtual llamado 'env'
python -m venv env
Activar el entorno:

Windows: .\env\Scripts\activate

Mac/Linux: source env/bin/activate

3. Instalación de Dependencias
Con el entorno virtual activo, ingresa a la carpeta del proyecto e instala las librerías:


pip install -r requirements.txt
4. Configuración de Base de Datos
Verifica que el archivo src/database/connection.py tenga las credenciales correctas:

User: postgres (o tu usuario configurado)

Password: Tu contraseña

Port: 5432

Database: CastorTesla

5. Ejecución del Proyecto
Ejecuta el archivo principal para iniciar el sistema:

python main.py
👤 Usuarios de Prueba
Credenciales de acceso predeterminadas para administradores:

Usuario	Contraseña
Mendo	23310035
Valente	23310012
Dulce	23310004