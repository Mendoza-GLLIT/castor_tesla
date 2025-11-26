from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex

class ProductModel(QAbstractListModel):
    CodeRole = Qt.UserRole + 1
    NameRole = Qt.UserRole + 2
    PriceRole = Qt.UserRole + 3
    StockRole = Qt.UserRole + 4
    DescRole = Qt.UserRole + 5 

    def __init__(self, products=None):
        super().__init__()
        self._products = products or []

    def rowCount(self, parent=QModelIndex()):
        return len(self._products)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None

        product = self._products[index.row()]
        
        if role == self.CodeRole:
            return product["codigo"]
        elif role == self.NameRole:
            return product["nombre"]
        elif role == self.PriceRole:
            return f"${product['precio']:.2f}"
        elif role == self.StockRole:
            return str(product["stock"])
        elif role == self.DescRole:
            return product.get("descripcion") or "Sin descripción"
            
        return None

    def roleNames(self):
        return {
            self.CodeRole: b"codigo",
            self.NameRole: b"nombre",
            self.PriceRole: b"precio",
            self.StockRole: b"stock",
            self.DescRole: b"descripcion",
        }
