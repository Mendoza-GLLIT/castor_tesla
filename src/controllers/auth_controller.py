# src/controllers/auth_controller.py
import os
from PySide6.QtCore import QObject, Slot, Signal, Property, QSettings
from src.database.user_repo import check_user_login

class AuthController(QObject):
    # Señal única para avisar a la UI que cualquier dato del usuario cambió
    userChanged = Signal()
    
    def __init__(self, engine):
        super().__init__()
        self.engine = engine
        self.settings = QSettings("CastorTesla", "AppConfig") # Para guardar "Recordarme"
        
        # Estado inicial de la sesión
        self._user_session = {
            "id": 0,
            "username": "Invitado",
            "full_name": "Usuario Invitado",
            "rol": "Invitado",
            "email": ""
        }

    # --- PROPIEDADES PARA QML ---
    
    @Property(str, notify=userChanged)
    def username(self):
        return self._user_session["username"]

    @Property(str, notify=userChanged)
    def fullName(self):
        return self._user_session["full_name"]

    @Property(str, notify=userChanged)
    def userRole(self):
        return self._user_session["rol"]

    @Property(str, constant=True)
    def savedEmail(self):
        # Devuelve el email guardado o vacío si no existe
        return self.settings.value("saved_email", "")

    # --- FUNCIONES ---

    @Slot(str, str, bool, result=bool)
    def login(self, email, password, remember_me):
        print(f"🔑 Intentando login con: {email}")
        
        # Consultamos a la base de datos
        user_data = check_user_login(email, password)
        
        if user_data:
            print(f"✅ Login exitoso: {user_data.get('nombre', 'Usuario')}")
            
            # 1. Formatear datos bonitos para la UI
            nombre = user_data.get('nombre', '')
            apellido = user_data.get('apellido', '')
            # Ejemplo: "Juan P."
            nombre_completo = f"{nombre} {apellido[0]}." if apellido else nombre
            
            self._user_session = {
                "id": user_data.get('id', 0),
                "username": user_data.get('username', email),
                "full_name": nombre_completo,
                "rol": user_data.get('rol', 'Empleado').capitalize(),
                "email": user_data.get('email', email)
            }
            
            # Avisamos a la UI que actualice textos
            self.userChanged.emit()

            # 2. Manejo de "Recordarme"
            if remember_me:
                self.settings.setValue("saved_email", email)
            else:
                self.settings.remove("saved_email")

            # 3. Cambiar ventana al Dashboard
            self._load_view("dashboard.qml")
            return True
        else:
            print("❌ Credenciales incorrectas")
            return False

    @Slot()
    def logout(self):
        print("🔒 Cerrando sesión...")
        
        # Limpiar datos de sesión en RAM
        self._user_session = {
            "id": 0,
            "username": "Invitado",
            "full_name": "Usuario Invitado",
            "rol": "Invitado",
            "email": ""
        }
        self.userChanged.emit()
        
        # Volver al Login
        self._load_view("login.qml")

    # --- GESTIÓN DE VENTANAS ---

    def _load_view(self, view_name):
        """
        Cierra todo y carga una nueva vista QML.
        Maneja rutas relativas para src/ui/ o src/ui/views/
        """
        self._close_all_windows()
        
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) # Sube a /src
        
        # Intentamos buscar en src/ui/views/ y luego en src/ui/
        paths_to_try = [
            os.path.join(base_dir, "ui", "views", view_name),
            os.path.join(base_dir, "ui", view_name)
        ]
        
        final_path = None
        for path in paths_to_try:
            if os.path.exists(path):
                final_path = path
                break
        
        if final_path:
            print(f"📂 Cargando vista: {final_path}")
            self.engine.load(final_path)
        else:
            print(f"❌ Error CRÍTICO: No se encontró el archivo {view_name}")

    def _close_all_windows(self):
        """Limpia ventanas viejas para evitar 'zombies'"""
        for window in self.engine.rootObjects():
            if hasattr(window, 'close'): window.close()
            if hasattr(window, 'deleteLater'): window.deleteLater()
        self.engine.clearComponentCache()