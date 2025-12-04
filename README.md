# 🔷 Castor Tesla - Sistema de Punto de Venta (POS)

¡Bienvenido a **Castor Tesla**!

Este es un sistema integral de gestión de inventario y Punto de Venta diseñado para ofrecer una experiencia de usuario moderna, fluida y eficiente. Desarrollado con **Python** y **Qt (QML)**, el sistema permite administrar productos, realizar ventas en tiempo real y visualizar historiales de transacciones de manera intuitiva.

El proyecto sigue una arquitectura **MVC (Modelo-Vista-Controlador)** estricta, separando la lógica de negocio, la gestión de datos y la interfaz gráfica para garantizar un código limpio y escalable.

---

## 🚀 Tecnologías Utilizadas

* **Lenguaje:** Python 3.10+
* **Interfaz Gráfica (GUI):** [PySide6](https://pypi.org/project/PySide6/) (Qt for Python) con **QML**.
* **Base de Datos:** PostgreSQL.
* **ORM y Conectores:** SQLAlchemy y Psycopg2.
* **Arquitectura:** MVC.

---

## 📂 Estructura del Proyecto

```text
castor_tesla/
│
├── main.py                     # 🚀 Punto de entrada (Inicia la app, carga estilos y rutas)
├── requirements.txt            # 📦 Lista de librerías (PySide6, SQLAlchemy, psycopg2, etc.)
├── .gitignore                  # 🙈 Archivos que Git debe ignorar (como __pycache__)
├── README.md                   # 📄 Documentación del proyecto
│
├── resources/                  # 🎨 Archivos estáticos
│   └── icons/                  # Iconos .png (logo, user, boxes, delivery_truck, etc.)
│
└── src/                        # 🧠 Código Fuente Principal
    │
    ├── database/               # 💾 CAPA DE DATOS (SQL y Conexión)
    │   ├── connection.py       # Configuración de conexión a PostgreSQL
    │   ├── user_repo.py        # Consultas tabla USUARIO
    │   ├── product_repo.py     # Consultas tabla PRODUCTO
    │   ├── sales_repo.py       # Consultas tabla VENTA y DETALLE
    │   ├── clients_repo.py     # Consultas tabla CLIENTE}
    │   ├── messages_repo.py    # Consultas tabla MENSAJES
    │   ├── assets_repo.py      # Consultas tabla ACTIVO_FIJO
    │   └── stats_repo.py       # Consultas complejas para Estadísticas
    │
    ├── models/                 # 📋 CAPA DE MODELOS (Adaptadores para QML)
    │   ├── models.py           # ProductModel (Lista de productos con filtro)
    │   ├── cart_model.py       # CartModel (Lógica del carrito de compras)
    │   └── sales_model.py      # SalesModel (Lista de historial de ventas)
    │
    ├── controllers/            # 🎮 CAPA DE CONTROLADORES (Lógica de Negocio)
    │   ├── auth_controller.py      # Login y Logout
    │   ├── pos_controller.py       # Cobro, carrito, selección cliente
    │   ├── inventory_controller.py # Altas, bajas y stock de productos
    │   ├── employers_controller.py # CRUD de empleados
    │   ├── clients_controller.py   # CRUD de clientes
    │   ├── messages_controller.py  # control de mensajes
    │   ├── assets_controller.py    # CRUD de activos fijos
    │   └── stats_controller.py     # Cálculo de KPIs y gráficas
    │
    └── ui/                     # 🖼️ CAPA DE VISTA (Interfaz Gráfica QML)
        ├── login.qml           # Pantalla de inicio de sesión
        ├── dashboard.qml       # Contenedor principal (StackLayout)
        ├── sidebar.qml         # Menú lateral de navegación
        ├── SidebarButton.qml   # Botón personalizado del menú con icono
        │
        └── views/              # 📄 Páginas y Formularios
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
            ├── StockAdjustmentDialog.qml # Modal: Ajustar Stock (+/-)
            ├── EmployeeFormDialog.qml    # Modal: Crear/Editar Empleado
            ├── ClientFormDialog.qml      # Modal: Crear/Editar Cliente
            └── AssetFormDialog.qml       # Modal: Crear/Editar Activo

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



## 🤝 Guía de Contribución y Flujo de Trabajo Git

Para mantener el orden en el proyecto y evitar conflictos en el código, seguimos estas reglas estrictas de control de versiones.

### 🚫 Regla de Oro
**NUNCA trabajar directamente sobre la rama `main`.**
La rama `main` es sagrada; solo debe contener código funcional y probado.

---

### 🔀 1. Estrategia de Ramas (Branches)

Cada nueva funcionalidad, corrección o experimento debe realizarse en su propia rama personal.

**Convención de Nombres:**
Usa el formato: `tipo/nombre-descriptivo`

* **`feature/`**: Para nuevas funcionalidades (ej: `feature/login-screen`, `feature/tabla-ventas`).
* **`fix/`**: Para arreglar errores (ej: `fix/error-calculo-iva`).
* **`docs/`**: Para cambios en documentación (ej: `docs/actualizar-readme`).
* **`refactor/`**: Para mejorar código sin cambiar funcionalidad.

**Cómo crear tu rama:**
1.  Asegúrate de estar en `main` y actualizado:
    ```bash
    git checkout main
    git pull origin main
    ```
2.  Crea tu rama y cámbiate a ella:
    ```bash
    git checkout -b feature/mi-nueva-funcionalidad
    ```

---

### 📝 2. Reglas para Commits

Los mensajes de commit deben ser claros y descriptivos. Imagina que alguien más leerá tu historial en el futuro.

* **Idioma:** Español o Inglés (pero consistente).
* **Tiempo:** Usa imperativo presente ("Agrega", "Corrige", "Elimina").
* **Atomicidad:** Un commit por cada cambio lógico. No hagas un solo commit gigante al final del día.

**✅ Buenos ejemplos:**
* `Agrega validación de contraseña en Login`
* `Corrige alineación en la tabla de inventario`
* `Elimina código muerto en pos_controller.py`

**❌ Malos ejemplos:**
* `cambios`
* `arreglando cosas`
* `final final ahora si`
* `subiendo código`

**Comando:**
```bash
git add .
git commit -m "Agrega función para calcular total en carrito"


hola soy valente y me gusta el