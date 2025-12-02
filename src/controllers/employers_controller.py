from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.user_repo import get_all_users, get_all_roles, create_user_db, update_user_db, delete_user_db

class EmployersController(QObject):
    # Señales para avisar a la UI que actualice las listas
    usersListChanged = Signal()
    rolesListChanged = Signal()
    notification = Signal(str, bool) # msg, isError

    def __init__(self):
        super().__init__()
        self._users = []
        self._roles = []
        self.refreshData() # Cargar datos al iniciar

    # --- PROPIEDADES (Modelos para QML) ---
    @Property(list, notify=usersListChanged)
    def usersModel(self):
        return self._users

    @Property(list, notify=rolesListChanged)
    def rolesModel(self):
        return self._roles

    # --- ACCIONES ---
    @Slot()
    def refreshData(self):
        self._users = get_all_users()
        self._roles = get_all_roles()
        self.usersListChanged.emit()
        self.rolesListChanged.emit()

    @Slot(str, str, str, str, str, int)
    def createUser(self, username, nombre, apellido, email, password, id_rol):
        success, msg = create_user_db(username, nombre, apellido, email, password, id_rol)
        if success:
            self.notification.emit("✅ " + msg, False)
            self.refreshData()
        else:
            self.notification.emit("❌ Error: " + msg, True)

    @Slot(int, str, str, str, str, str, int)
    def updateUser(self, id_user, username, nombre, apellido, email, password, id_rol):
        success, msg = update_user_db(id_user, username, nombre, apellido, email, password, id_rol)
        if success:
            self.notification.emit("✅ " + msg, False)
            self.refreshData()
        else:
            self.notification.emit("❌ Error: " + msg, True)

    @Slot(int)
    def deleteUser(self, id_user):
        success, msg = delete_user_db(id_user)
        if success:
            self.notification.emit("🗑️ " + msg, False)
            self.refreshData()
        else:
            self.notification.emit("❌ Error: " + msg, True)