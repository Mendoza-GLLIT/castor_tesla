from PySide6.QtCore import QAbstractListModel, Qt, QModelIndex, Slot

class ProductModel(QAbstractListModel):
    # --- 1. Definición de Roles ---
    CodigoRole = Qt.UserRole + 1
    NombreRole = Qt.UserRole + 2
    DescripcionRole = Qt.UserRole + 3
    PrecioRole = Qt.UserRole + 4
    StockRole = Qt.UserRole + 5
    IdRole = Qt.UserRole + 6 

    def __init__(self, products_data=None, parent=None):
        super().__init__(parent)
        
        # --- [CORRECCIÓN 1: DOBLE LISTA] ---
        # 1. Lista Maestra (Respaldo con TODOS los datos)
        self._all_products = products_data if products_data else []
        
        # 2. Lista Visible (Lo que se ve en la tabla, puede estar filtrada)
        self._products = list(self._all_products)

    def rowCount(self, parent=QModelIndex()):
        return len(self._products) # Contamos los visibles

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self._products):
            return None
        
        # Leemos de la lista visible
        product = self._products[index.row()]

        if role == ProductModel.CodigoRole:
            return str(product.get("codigo", ""))
        elif role == ProductModel.NombreRole:
            return str(product.get("nombre", ""))
        elif role == ProductModel.DescripcionRole:
            return str(product.get("descripcion", ""))
        elif role == ProductModel.PrecioRole:
            try:
                precio = float(product.get("precio", 0.0))
                return f"${precio:.2f}"
            except (ValueError, TypeError):
                return "$0.00"
        elif role == ProductModel.StockRole:
            return int(product.get("stock", 0))
        elif role == ProductModel.IdRole:
            return product.get("id_producto")
        
        return None

    def roleNames(self):
        return {
            ProductModel.CodigoRole: b"codigo",
            ProductModel.NombreRole: b"nombre",
            ProductModel.DescripcionRole: b"descripcion",
            ProductModel.PrecioRole: b"precio",
            ProductModel.StockRole: b"stock",
            ProductModel.IdRole: b"id_producto"
        }

    # --- [CORRECCIÓN 2: FUNCIÓN DE FILTRADO] ---
    # Esta es la que llama el buscador (TextField)
    @Slot(str)
    def filter(self, query):
        self.beginResetModel() # Avisamos a la UI que todo va a cambiar
        
        if not query:
            # Si el buscador está vacío, restauramos todos los productos
            self._products = list(self._all_products)
        else:
            # Filtramos por nombre O código (sin importar mayúsculas)
            q = query.lower()
            self._products = [
                p for p in self._all_products 
                if q in p['nombre'].lower() or q in p['codigo'].lower()
            ]
            
        self.endResetModel()

    # --- MÉTODOS DE ACTUALIZACIÓN (Deben actualizar AMBAS listas) ---

    def add_product_ui(self, product_dict):
        """Inserta un producto visualmente al inicio."""
        # 1. Agregar a la maestra
        self._all_products.insert(0, product_dict)
        
        # 2. Agregar a la visible (y notificar animación)
        self.beginInsertRows(QModelIndex(), 0, 0)
        self._products.insert(0, product_dict)
        self.endInsertRows()

    def update_stock_ui(self, id_producto, new_stock):
        """Actualiza el stock exacto (usado en Inventario)."""
        # 1. Actualizar maestra
        for prod in self._all_products:
            if prod.get("id_producto") == id_producto:
                prod["stock"] = new_stock
                break

        # 2. Actualizar visible
        for i, prod in enumerate(self._products):
            if prod.get("id_producto") == id_producto:
                prod["stock"] = new_stock
                idx = self.index(i)
                self.dataChanged.emit(idx, idx, [ProductModel.StockRole])
                break

    def decrease_stock_ui(self, id_producto, cantidad_vendida):
        """
        Resta stock tras una venta (usado por el POS).
        """
        # 1. Actualizar maestra
        for prod in self._all_products:
            if prod.get("id_producto") == id_producto:
                current = int(prod.get("stock", 0))
                prod["stock"] = max(0, current - cantidad_vendida)
                break

        # 2. Actualizar visible
        for i, prod in enumerate(self._products):
            if prod.get("id_producto") == id_producto:
                curr = int(prod.get("stock", 0))
                prod["stock"] = max(0, curr - cantidad_vendida)
                idx = self.index(i)
                self.dataChanged.emit(idx, idx, [ProductModel.StockRole])
                break