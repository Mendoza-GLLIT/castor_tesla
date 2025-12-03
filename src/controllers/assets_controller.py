from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.assets_repo import get_all_assets, create_asset, update_asset, delete_asset
from src.database.user_repo import get_all_users 

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

    @Slot(int, str, str, str, str, int)
    def updateAsset(self, asset_id, codigo, nombre, descripcion, ubicacion, id_responsable):
        if update_asset(asset_id, codigo, nombre, descripcion, ubicacion, id_responsable):
            self.refreshData()

    @Slot(int)
    def deleteAsset(self, asset_id):
        if delete_asset(asset_id):
            self.refreshData()