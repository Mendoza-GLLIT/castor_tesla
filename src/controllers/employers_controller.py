import sys
import os
from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.user_repo import (
    get_all_users,
    get_all_roles,
    create_user_db,
    update_user_db,
    delete_user_db
)
from src.database.messages_repo import create_notification

def resource_path(relative_path: str) -> str:
    """
    Devuelve la ruta absoluta de un recurso, compatible con PyInstaller.
    """
    try:
        base_path = sys._MEIPASS
    except AttributeError:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

ICON_PATHS = {
    "info": resource_path("resources/icons/info.png"),
    "success": resource_path("resources/icons/success.png"),
    "warning": resource_path("resources/icons/warning.png"),
    "critical": resource_path("resources/icons/alert.png")
}

class EmployersController(QObject):
    usersListChanged = Signal()
    rolesListChanged = Signal()
    notification = Signal(str, bool)

    def __init__(self):
        super().__init__()
        self._users = []
        self._roles = []
        self.refreshData()

    @Property(list, notify=usersListChanged)
    def usersModel(self):
        return self._users

    @Property(list, notify=rolesListChanged)
    def rolesModel(self):
        return self._roles

    @Slot()
    def refreshData(self):
        users = get_all_users()
        lista_final = []
        for u in users:
            lista_final.append({
                "id": u["id"],
                "username": u.get("username", ""),
                "nombre": u.get("nombre", ""),
                "apellido": u.get("apellido", ""),
                "email": u.get("email", ""),
                "password": u.get("password", ""),   # opcional, según tu repo
                "id_rol": u.get("id_rol", 0),
                "icon": ICON_PATHS["info"]
            })
        self._users = lista_final
        self._roles = get_all_roles()
        self.usersListChanged.emit()
        self.rolesListChanged.emit()

    @Slot(str, str, str, str, str, int)
    def createUser(self, username, nombre, apellido, email, password, id_rol):
        success, msg = create_user_db(username, nombre, apellido, email, password, id_rol)
        if success:
            create_notification("Usuario Creado", msg, "success", ICON_PATHS["success"])
            self.refreshData()
        else:
            create_notification("Error Creando Usuario", msg, "critical", ICON_PATHS["critical"])

    @Slot(int, str, str, str, str, str, int)
    def updateUser(self, id_user, username, nombre, apellido, email, password, id_rol):
        success, msg = update_user_db(id_user, username, nombre, apellido, email, password, id_rol)
        if success:
            create_notification("Usuario Actualizado", msg, "success", ICON_PATHS["success"])
            self.refreshData()
        else:
            create_notification("Error Actualizando Usuario", msg, "critical", ICON_PATHS["critical"])

    @Slot(int)
    def deleteUser(self, id_user):
        success, msg = delete_user_db(id_user)
        if success:
            create_notification("Usuario Eliminado", msg, "warning", ICON_PATHS["warning"])
            self.refreshData()
        else:
            create_notification("Error Eliminando Usuario", msg, "critical", ICON_PATHS["critical"])
