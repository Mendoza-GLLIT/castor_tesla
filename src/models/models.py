from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex

class ProductModel(QAbstractListModel):
    # Roles que usará el QML
    CodigoRole = Qt.UserRole + 1
    NombreRole = Qt.UserRole + 2
    DescripcionRole = Qt.UserRole + 3
    PrecioRole = Qt.UserRole + 4
    StockRole = Qt.UserRole + 5

    def __init__(self, products_data=None, parent=None):
        super().__init__(parent)
        # Recibimos la lista de diccionarios
        self._products = products_data if products_data else []

    def rowCount(self, parent=QModelIndex()):
        return len(self._products)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self._products):
            return None
        
        # Obtenemos el diccionario del producto
        product = self._products[index.row()]

        # Mapeamos los roles a las llaves de tu diccionario de BD
        if role == ProductModel.CodigoRole:
            return str(product.get("codigo", ""))
        elif role == ProductModel.NombreRole:
            return str(product.get("nombre", ""))
        elif role == ProductModel.DescripcionRole:
            return str(product.get("descripcion", ""))
        elif role == ProductModel.PrecioRole:
            # Formateamos precio
            precio = product.get("precio", 0.0)
            return f"${precio:.2f}"
        elif role == ProductModel.StockRole:
            # Aseguramos que stock sea número
            return int(product.get("stock", 0))
        
        return None

    def roleNames(self):
        # Nombres que usas en el QML
        return {
            ProductModel.CodigoRole: b"codigo",
            ProductModel.NombreRole: b"nombre",
            ProductModel.DescripcionRole: b"descripcion",
            ProductModel.PrecioRole: b"precio",
            ProductModel.StockRole: b"stock"
        }