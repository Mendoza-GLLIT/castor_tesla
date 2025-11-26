from PySide6.QtCore import Qt, QAbstractListModel, QModelIndex

class CartModel(QAbstractListModel):
    NameRole = Qt.UserRole + 1
    PriceRole = Qt.UserRole + 2
    QtyRole = Qt.UserRole + 3
    TotalRole = Qt.UserRole + 4
    CodeRole = Qt.UserRole + 5

    def __init__(self, parent=None):
        super().__init__(parent)
        self._items = []

    def rowCount(self, parent=QModelIndex()):
        return len(self._items)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid():
            return None

        item = self._items[index.row()]
        
        if role == self.NameRole: return item["nombre"]
        if role == self.PriceRole: return f"${item['precio']:.2f}"
        if role == self.QtyRole: return str(item["cantidad"])
        if role == self.TotalRole: return f"${item['subtotal']:.2f}"
        if role == self.CodeRole: return item["codigo"]
        return None

    def roleNames(self):
        return {
            self.NameRole: b"nombre",
            self.PriceRole: b"precio",
            self.QtyRole: b"cantidad",
            self.TotalRole: b"total",
            self.CodeRole: b"codigo"
        }

    # Soporta cantidad personalizada 
    def add_item(self, product, qty=1):
        # Si ya existe, sumar cantidad
        for i, item in enumerate(self._items):
            if item["id"] == product["id"]:
                item["cantidad"] += qty
                item["subtotal"] = item["cantidad"] * item["precio"]
                self.dataChanged.emit(self.index(i), self.index(i))
                return

        # Si no existe, agregarlo
        self.beginInsertRows(QModelIndex(), len(self._items), len(self._items))
        self._items.append({
            "id": product["id"],
            "codigo": product["codigo"],
            "nombre": product["nombre"],
            "precio": product["precio"],
            "cantidad": qty,
            "subtotal": product["precio"] * qty
        })
        self.endInsertRows()

    def remove_item(self, index):
        self.beginRemoveRows(QModelIndex(), index, index)
        del self._items[index]
        self.endRemoveRows()

    def clear_cart(self):
        self.beginResetModel()
        self._items = []
        self.endResetModel()

    def get_items(self):
        return self._items
