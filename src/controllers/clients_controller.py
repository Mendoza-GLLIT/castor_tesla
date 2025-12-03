from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.clients_repo import get_all_clients, create_client, update_client, delete_client

class ClientsController(QObject):
    # Señal para avisar a QML que la lista cambió
    clientsChanged = Signal()

    def __init__(self):
        super().__init__()
        self._clients = []
        self.refreshData() # Cargar al iniciar

    # Propiedad que lee QML (Lista de diccionarios)
    @Property(list, notify=clientsChanged)
    def clientsModel(self):
        return self._clients

    @Slot()
    def refreshData(self):
        print("🔄 Recargando clientes...")
        self._clients = get_all_clients()
        self.clientsChanged.emit()

    @Slot(str, str, str, str, str)
    def createClient(self, nombre, rfc, direccion, telefono, email):
        if create_client(nombre, rfc, direccion, telefono, email):
            print(f"✅ Cliente creado: {nombre}")
            self.refreshData()
        else:
            print("❌ Error creando cliente")

    @Slot(int, str, str, str, str, str)
    def updateClient(self, client_id, nombre, rfc, direccion, telefono, email):
        if update_client(client_id, nombre, rfc, direccion, telefono, email):
            print(f"✅ Cliente actualizado ID: {client_id}")
            self.refreshData()
        else:
            print("❌ Error actualizando")

    @Slot(int)
    def deleteClient(self, client_id):
        if delete_client(client_id):
            print(f"🗑️ Cliente eliminado ID: {client_id}")
            self.refreshData()
        else:
            print("❌ Error eliminando (posiblemente tiene ventas asociadas)")