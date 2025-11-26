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
CastorTesla/
│
├── main.py                 # 🏁 Punto de entrada principal (Ejecutar este archivo)
├── crear_usuarios.py       # 🛠️ Script de utilidad (Root)
├── requirements.txt        # 📦 Lista de librerías necesarias
├── README.md               # 📄 Documentación del proyecto
│
└── src/
    ├── controllers/        # 🧠 Lógica de Negocio (Python)
    │   ├── controller.py       # Controlador principal (Login y Navegación)
    │   └── pos_controller.py   # Controlador del Punto de Venta (Cálculos y Venta)
    │
    ├── models/             # 📊 Modelos de Datos (QAbstractListModel)
    │   ├── cart_model.py       # Modelo dinámico para el carrito de compras
    │   ├── sales_model.py      # Modelo para el historial de ventas
    │   └── models.py           # Modelo general de productos (Inventario)
    │
    ├── database/           # 🗄️ Base de Datos
    │   ├── Create_tables.py    # Script para crear tablas
    │   ├── Create_users.py     # Script para crear usuarios
    │   ├── insert_products.py  # Script para llenar inventario inicial
    │   └── database.py         # Conexión a PostgreSQL y consultas SQL
    │
    ├── resources/          # 🎨 Recursos Gráficos
    │   ├── icons/              # Iconos del menú
    │   ├── logo.png            # Logotipo
    │   └── profile.png         # Imagen de perfil
    │
    └── ui/                 # 🖥️ Interfaz de Usuario (QML)
        ├── login.qml           # Pantalla de Inicio de Sesión
        ├── sidebar.qml         # Menú lateral de navegación
        ├── SidebarButton.qml   # Componente personalizado de botón
        │
        └── views/          # 📑 Vistas de la Aplicación
            ├── pos.qml             # Pantalla de Punto de Venta (Cobrar)
            ├── sales.qml           # Pantalla de Historial de Ventas
            ├── inventory.qml       # Pantalla de Inventario
            ├── schedule.qml        # Agenda (Placeholder)
            ├── messages.qml        # Mensajes (Placeholder)
            └── settings.qml        # Configuración (Placeholder)


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