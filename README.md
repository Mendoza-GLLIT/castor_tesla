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
castor_tesla/
│
├── main.py                     # Punto de entrada (Inicia la app, carga estilos y rutas)
├── requirements.txt            # Lista de librerías (PySide6, SQLAlchemy, etc.)
├── .gitignore                  # Archivos ignorados por Git
├── README.md                   # Documentación del proyecto
│
├── resources/                  # Archivos estáticos
│   └── icons/                  # Iconos e imágenes .png
│
└── src/                        # Código Fuente Principal
    │
    ├── database/               # CAPA DE DATOS (SQL y Conexión)
    │   ├── connection.py       # Configuración de conexión a PostgreSQL
    │   ├── user_repo.py        # Consultas tabla USUARIO
    │   ├── product_repo.py     # Consultas tabla PRODUCTO
    │   ├── sales_repo.py       # Consultas tabla VENTA y DETALLE
    │   ├── clients_repo.py     # Consultas tabla CLIENTE
    │   ├── messages_repo.py    # Consultas tabla MENSAJES
    │   ├── assets_repo.py      # Consultas tabla ACTIVO_FIJO
    │   └── stats_repo.py       # Consultas complejas para Estadísticas
    │
    ├── models/                 # CAPA DE MODELOS (Adaptadores para QML)
    │   ├── models.py           # ProductModel (Lista de productos con filtro)
    │   ├── cart_model.py       # CartModel (Lógica del carrito de compras)
    │   └── sales_model.py      # SalesModel (Lista de historial de ventas)
    │
    ├── controllers/            # CAPA DE CONTROLADORES (Lógica de Negocio)
    │   ├── auth_controller.py      # Login y Logout
    │   ├── pos_controller.py       # Cobro, carrito, selección cliente
    │   ├── inventory_controller.py # Altas, bajas y stock de productos
    │   ├── employers_controller.py # CRUD de empleados
    │   ├── clients_controller.py   # CRUD de clientes
    │   ├── messages_controller.py  # Control de mensajes
    │   ├── assets_controller.py    # CRUD de activos fijos
    │   └── stats_controller.py     # Cálculo de KPIs y gráficas
    │
    └── ui/                     # CAPA DE VISTA (Interfaz Gráfica QML)
        ├── login.qml           # Pantalla de inicio de sesión
        ├── dashboard.qml       # Contenedor principal (StackLayout)
        ├── sidebar.qml         # Menú lateral de navegación
        ├── SidebarButton.qml   # Botón personalizado del menú con icono
        │
        └── views/              # Páginas y Formularios
            ├── pos.qml                 # Vista: Punto de Venta
            ├── inventory.qml           # Vista: Tabla de Productos
            ├── sales.qml               # Vista: Historial de Ventas
            ├── employers.qml           # Vista: Gestión de Empleados
            ├── clients.qml             # Vista: Cartera de Clientes
            ├── assets.qml              # Vista: Activos Fijos
            ├── messages.qml            # Vista: Alertas
            ├── statistics.qml          # Vista: Dashboard y Gráficas
            │
            ├── NewProductDialog.qml      # Modal: Crear Producto
            ├── StockAdjustmentDialog.qml # Modal: Ajustar Stock
            ├── EmployeeFormDialog.qml    # Modal: Crear/Editar Empleado
            ├── ClientFormDialog.qml      # Modal: Crear/Editar Cliente
            └── AssetFormDialog.qml       # Modal: Crear/Editar Activo

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