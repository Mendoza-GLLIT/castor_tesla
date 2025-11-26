from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex

class SalesModel(QAbstractListModel):
    IdRole = Qt.UserRole + 1
    DateRole = Qt.UserRole + 2
    TotalRole = Qt.UserRole + 3
    SellerRole = Qt.UserRole + 4
    DetailsRole = Qt.UserRole + 5 

    def __init__(self, sales=None):
        super().__init__()
        self._sales = sales or []

    def rowCount(self, parent=QModelIndex()):
        return len(self._sales)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None

        sale = self._sales[index.row()]

        if role == self.IdRole:
            return sale["id_venta"]
        elif role == self.DateRole:
            return sale["fecha"]
        elif role == self.TotalRole:
            return sale["total"]
        elif role == self.SellerRole:
            return sale["vendedor"]
        elif role == self.DetailsRole:
            return sale["detalles"]  

        return None

    def roleNames(self):
        return {
            self.IdRole: b"idVenta",
            self.DateRole: b"fecha",
            self.TotalRole: b"total",
            self.SellerRole: b"vendedor",
            self.DetailsRole: b"detalles",
        }
