from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.assets_repo import get_all_assets, create_asset, update_asset, delete_asset
from src.database.user_repo import get_all_users 
from src.database.messages_repo import create_notification
import os

# Rutas de iconos según tipo de mensaje
ICON_PATHS = {
    "info": os.path.abspath("resources/icons/info.png"),
    "success": os.path.abspath("resources/icons/success.png"),
    "warning": os.path.abspath("resources/icons/warning.png"),
    "critical": os.path.abspath("resources/icons/alert.png")
}

class AssetsController(QObject):
    assetsChanged = Signal()
    employeesChanged = Signal() 

    def __init__(self):
        super().__init__()
        self._assets = []
        self._employees = []
        self.refreshData()

    @Property(list, notify=assetsChanged)
    def assetsModel(self):
        return self._assets

    @Property(list, notify=employeesChanged)
    def employeesModel(self):
        return self._employees

    @Slot()
    def refreshData(self):
        print("🔄 Recargando activos...")
        self._assets = get_all_assets()
        self.assetsChanged.emit()
        
        # Cargamos empleados para el ComboBox
        users = get_all_users()
        # Agregamos opción "Sin Asignar" al principio
        lista_final = [{"id": 0, "nombre": "--- Sin Asignar ---"}]
        for u in users:
            lista_final.append({"id": u["id"], "nombre": f"{u['nombre']} {u['apellido']}"})
            
        self._employees = lista_final
        self.employeesChanged.emit()

    @Slot(str, str, str, str, int)
    def createAsset(self, codigo, nombre, descripcion, ubicacion, id_responsable):
        if create_asset(codigo, nombre, descripcion, ubicacion, id_responsable):
            self.refreshData()
            
            msg = f"Se registró el activo '{nombre}' ({codigo}) en {ubicacion}."
            
            if id_responsable > 0:
                msg += " Se ha asignado a un responsable."
            
            create_notification("Nuevo Activo Fijo", msg, "info", ICON_PATHS["info"])

    @Slot(int, str, str, str, str, int)
    def updateAsset(self, asset_id, codigo, nombre, descripcion, ubicacion, id_responsable):
        if update_asset(asset_id, codigo, nombre, descripcion, ubicacion, id_responsable):
            self.refreshData()
            
            tipo_msg = "info"
            cuerpo_msg = f"Se actualizaron los datos del activo '{nombre}'."
            
            if id_responsable > 0:
                cuerpo_msg += " El activo tiene un responsable asignado."
            else:
                cuerpo_msg += " El activo NO tiene responsable asignado."
                tipo_msg = "warning"
            
            create_notification("Activo Actualizado", cuerpo_msg, tipo_msg, ICON_PATHS[tipo_msg])

    @Slot(int)
    def deleteAsset(self, asset_id):
        if delete_asset(asset_id):
            self.refreshData()
            create_notification(
                "Activo Eliminado",
                f"Se eliminó correctamente el activo con ID {asset_id}.",
                "warning",
                ICON_PATHS["warning"]
            )
        else:
            create_notification(
                "Error Eliminando Activo",
                f"No se pudo eliminar el activo con ID {asset_id}.",
                "critical",
                ICON_PATHS["critical"]
            )
