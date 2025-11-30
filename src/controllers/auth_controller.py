import os
from PySide6.QtCore import QObject, Slot, Signal, Property, QSettings
from src.database.user_repo import check_user_login

class AuthController(QObject):
    # Señales para notificar a QML
    userChanged = Signal()
    
    def __init__(self, engine):
        super().__init__()
        self.engine = engine
        self.settings = QSettings("CastorTesla", "AppConfig") # Para guardar "Recordarme"
        
        # Estado de la sesión actual
        self._user_session = {
            "id": 0,
            "username": "Invitado",
            "full_name": "",
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
        # Recupera el email guardado si existe, sino devuelve cadena vacía
        return self.settings.value("saved_email", "")

    # --- FUNCIONES ---

    @Slot(str, str, bool, result=bool)
    def login(self, email, password, remember_me):
        print(f"🔑 Intentando login con: {email}")
        
        user_data = check_user_login(email, password)
        
        if user_data:
            print(f"✅ Bienvenido {user_data['nombre']}")
            
            # 1. Guardar sesión en memoria RAM
            self._user_session = {
                "id": user_data['id'],
                "username": user_data['username'],
                "full_name": f"{user_data['nombre']} {user_data['apellido']}",
                "rol": user_data['rol'].capitalize(),
                "email": user_data['email']
            }
            self.userChanged.emit()

            # 2. Lógica de "Recordarme" (Persistencia local)
            if remember_me:
                self.settings.setValue("saved_email", email)
            else:
                self.settings.remove("saved_email") # Si no marca, olvidamos

            # 3. Cambiar de ventana
            self._switch_to_dashboard()
            return True
        else:
            print("❌ Credenciales incorrectas")
            return False

    @Slot()
    def logout(self):
        print("🔒 Cerrando sesión...")
        
        # Limpiar sesión RAM
        self._user_session = {
            "id": 0,
            "username": "Invitado",
            "full_name": "",
            "rol": "Invitado",
            "email": ""
        }
        self.userChanged.emit()
        
        # Volver al Login
        self._close_all_windows()
        current_dir = os.path.dirname(__file__)
        login_path = os.path.join(current_dir, "../ui/login.qml")
        self.engine.load(login_path)

    # --- UTILIDADES INTERNAS ---

    def _switch_to_dashboard(self):
        self._close_all_windows()
        current_dir = os.path.dirname(__file__)
        # Intenta rutas relativas comunes
        dashboard_path = os.path.join(current_dir, "../ui/views/dashboard.qml")
        if not os.path.exists(dashboard_path):
            dashboard_path = os.path.join(current_dir, "../ui/dashboard.qml")
        
        self.engine.load(dashboard_path)

    def _close_all_windows(self):
        # Cierra ventanas agresivamente para evitar zombies
        for window in self.engine.rootObjects():
            if hasattr(window, 'close'): window.close()
            if hasattr(window, 'deleteLater'): window.deleteLater()
        self.engine.clearComponentCache()