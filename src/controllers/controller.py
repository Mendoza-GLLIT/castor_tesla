import os
from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.database import check_user_login

class Controller(QObject):
    # Señales para notificar cambios en la UI
    userNameChanged = Signal()
    userRoleChanged = Signal()

    def __init__(self, engine):
        super().__init__()
        self.engine = engine
        # Variables privadas para almacenar datos del usuario
        self._user_name = "Usuario"
        self._user_role = "Invitado"

    # Propiedad de lectura para el nombre
    @Property(str, notify=userNameChanged)
    def userName(self):
        return self._user_name

    # Propiedad de lectura para el rol
    @Property(str, notify=userRoleChanged)
    def userRole(self):
        return self._user_role

    @Slot(str, str, result=bool)  
    def login(self, username, password):
        # check_user_login ahora devuelve un diccionario o None
        user_data = check_user_login(username, password)
        
        if user_data:
            print(f"✅ Login exitoso: {user_data['nombre']}")

            # Formatear Nombre: "Nombre" + "Inicial Apellido."
            apellido_inicial = f"{user_data['apellido'][0]}." if user_data['apellido'] else ""
            self._user_name = f"{user_data['nombre']} {apellido_inicial}".strip()
            
            # Formatear Rol: Primera letra mayúscula
            self._user_role = user_data['rol'].capitalize()

            # Emitir señales para actualizar la UI (Sidebar)
            self.userNameChanged.emit()
            self.userRoleChanged.emit()

            # 1. Cerrar TODAS las ventanas actuales (Login)
            self._close_all_windows()

            current_dir = os.path.dirname(__file__)
            dashboard_path = os.path.join(current_dir, "../ui/views/dashboard.qml")
            
            if not os.path.exists(dashboard_path):
                dashboard_path = os.path.join(current_dir, "../ui/dashboard.qml")

            # 2. Cargar el Dashboard limpio
            self.engine.load(dashboard_path)
            return True
        
        print("❌ Login fallido")
        return False

    @Slot()
    def logout(self):
        print("🔒 Cerrando sesión...")
        
        # Reseteamos datos al salir
        self._user_name = "Usuario"
        self._user_role = "Invitado"
        self.userNameChanged.emit()
        self.userRoleChanged.emit()
        
        # 1. Cerrar TODAS las ventanas actuales (Dashboard)
        self._close_all_windows()

        # 2. Calcular ruta al Login
        current_dir = os.path.dirname(__file__)
        login_path = os.path.join(current_dir, "../ui/login.qml")

        # 3. Cargar Login
        self.engine.load(login_path)

    def _close_all_windows(self):
        """
        Cierra y elimina explícitamente todas las ventanas cargadas
        por el motor QML para evitar ventanas 'zombie'.
        """
        # Iteramos sobre una copia de la lista de objetos raíz
        for window in self.engine.rootObjects():
            # Intentamos cerrar visualmente
            if hasattr(window, 'close'):
                window.close()
            # Forzamos la eliminación del objeto C++ en el siguiente ciclo
            if hasattr(window, 'deleteLater'):
                window.deleteLater()
        
        # Limpiamos la caché para que la próxima ventana cargue de cero
        self.engine.clearComponentCache()