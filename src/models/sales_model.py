from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex

class SalesModel(QAbstractListModel):
    # Definición de Roles (identificadores numéricos)
    IdVentaRole = Qt.UserRole + 1
    FechaRole = Qt.UserRole + 2
    VendedorRole = Qt.UserRole + 3
    TotalRole = Qt.UserRole + 4
    DetallesRole = Qt.UserRole + 5
    ClienteRole = Qt.UserRole + 6  # <--- NUEVO ROL AGREGADO

    def __init__(self, sales_data=None, parent=None):
        super().__init__(parent)
        self._sales = sales_data if sales_data else []

    def rowCount(self, parent=QModelIndex()):
        return len(self._sales)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self._sales):
            return None
        
        sale = self._sales[index.row()]

        if role == SalesModel.IdVentaRole:
            return str(sale.get("id_venta", ""))
        elif role == SalesModel.FechaRole:
            return str(sale.get("fecha", ""))
        elif role == SalesModel.VendedorRole:
            return str(sale.get("vendedor", ""))
        elif role == SalesModel.TotalRole:
            # Si el string ya viene con $ desde el repo, retornalo directo, si no, formatealo.
            # Asumiremos que viene formateado o es float. Aquí aseguro string.
            val = sale.get('total', 0.0)
            return str(val) 
        elif role == SalesModel.DetallesRole:
            return sale.get("detalles", [])
        
        # --- NUEVO: Retornar el cliente ---
        elif role == SalesModel.ClienteRole:
            return str(sale.get("cliente", "Desconocido"))
        
        return None

    def roleNames(self):
        # Mapeo de nombres para QML (bytes : bytes)
        return {
            SalesModel.IdVentaRole: b"idVenta",
            SalesModel.FechaRole: b"fecha",
            SalesModel.VendedorRole: b"vendedor",
            SalesModel.TotalRole: b"total",
            SalesModel.DetallesRole: b"detalles",
            SalesModel.ClienteRole: b"cliente" # <--- ASÍ LO LLAMARÁS EN QML
        }