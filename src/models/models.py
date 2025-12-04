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
        
        # 1. Lista Maestra (Respaldo con TODOS los datos)
        self._all_products = products_data if products_data else []
        
        # 2. Lista Visible (Lo que se ve en la tabla, puede estar filtrada)
        self._products = list(self._all_products)

    def rowCount(self, parent=QModelIndex()):
        return len(self._products)

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or index.row() >= len(self._products):
            return None
        
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

    @Slot(str)
    def filter(self, query):
        self.beginResetModel()
        if not query:
            self._products = list(self._all_products)
        else:
            q = query.lower()
            self._products = [
                p for p in self._all_products 
                if q in p['nombre'].lower() or q in p['codigo'].lower()
            ]
        self.endResetModel()

    # --- MÉTODOS DE ACTUALIZACIÓN CORREGIDOS ---

    def add_product_ui(self, product_dict):
        """Inserta un producto visualmente al inicio."""
        # Agregamos a la maestra
        self._all_products.insert(0, product_dict)
        
        # Agregamos a la visible y notificamos
        self.beginInsertRows(QModelIndex(), 0, 0)
        self._products.insert(0, product_dict)
        self.endInsertRows()

    def update_stock_ui(self, id_producto, new_stock):
        """Actualiza el stock exacto (usado en Inventario)."""
        
        # 1. Actualizar el dato en la lista maestra (que es la fuente de verdad)
        # Al ser diccionarios, la referencia se actualiza automáticamente en ambas listas.
        for prod in self._all_products:
            if prod.get("id_producto") == id_producto:
                prod["stock"] = new_stock
                break # Ya encontramos y actualizamos el objeto en memoria

        # 2. Solo buscamos el índice en la lista visible para notificar a la UI
        # NO volvemos a asignar el valor, porque ya cambió en el paso 1.
        for i, prod in enumerate(self._products):
            if prod.get("id_producto") == id_producto:
                idx = self.index(i)
                self.dataChanged.emit(idx, idx, [ProductModel.StockRole])
                break

    def decrease_stock_ui(self, id_producto, cantidad_vendida):
        """
        Resta stock tras una venta (usado por el POS).
        """
        # 1. Calcular y actualizar el dato real UNA SOLA VEZ en la lista maestra
        stock_actualizado = False
        for prod in self._all_products:
            if prod.get("id_producto") == id_producto:
                current = int(prod.get("stock", 0))
                prod["stock"] = max(0, current - cantidad_vendida)
                stock_actualizado = True
                break
        
        # Si no encontramos el producto (ej. bug raro), no hacemos nada
        if not stock_actualizado:
            return

        # 2. Avisar a la vista (si el producto es visible actualmente)
        # El valor ya es el correcto porque 'prod' es una referencia al mismo objeto
        for i, prod in enumerate(self._products):
            if prod.get("id_producto") == id_producto:
                idx = self.index(i)
                self.dataChanged.emit(idx, idx, [ProductModel.StockRole])
                break
            
    def update_product_ui(self, id_producto, nombre, descripcion, precio):
        """Actualiza nombre, descripción y precio en tiempo real."""
        # 1. Actualizar memoria maestra
        for prod in self._all_products:
            if prod.get("id_producto") == id_producto:
                prod["nombre"] = nombre
                prod["descripcion"] = descripcion
                prod["precio"] = str(precio) # Guardamos como string o float según tu lógica
                break

        # 2. Actualizar vista visible
        for i, prod in enumerate(self._products):
            if prod.get("id_producto") == id_producto:
                idx = self.index(i)
                # Avisamos que cambiaron Nombre, Descripción y Precio
                self.dataChanged.emit(idx, idx, [
                    ProductModel.NombreRole, 
                    ProductModel.DescripcionRole, 
                    ProductModel.PrecioRole
                ])
                break

    def delete_product_ui(self, id_producto):
        """Elimina la fila visualmente con animación."""
        # 1. Eliminar de la maestra
        self._all_products = [p for p in self._all_products if p.get("id_producto") != id_producto]

        # 2. Eliminar de la visible (buscando el índice)
        for i, prod in enumerate(self._products):
            if prod.get("id_producto") == id_producto:
                self.beginRemoveRows(QModelIndex(), i, i)
                self._products.pop(i)
                self.endRemoveRows()
                break