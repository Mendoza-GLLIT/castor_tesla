from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.product_repo import get_product_by_code
from src.database.sales_repo import save_sale_transaction, get_sales_history 
from src.models.cart_model import CartModel
from src.database.connection import get_db_connection

class PosController(QObject):
    # Señales para notificar a la interfaz
    totalChanged = Signal()
    notification = Signal(str, bool)  # mensaje, es_error
    historyChanged = Signal()         # Notifica cambios en la lista de ventas

    def __init__(self):
        super().__init__()
        self._cart_model = CartModel()
        self._total = 0.0
        
        # Estado del Cliente seleccionado
        self._selected_client_id = None 
        self._cached_clients = []

        # Estado del Historial de Ventas
        self._sales_history = []
        
        # Cargar datos iniciales
        self.refreshHistory() 

    # ==========================================================
    # PROPIEDADES GENERALES (Usuario y Clientes)
    # ==========================================================
    
    @Property(str, constant=True)
    def currentUserName(self):
        return "Emmanuel M. (Admin)"

    @Property(list, constant=True)
    def clientsModel(self):
        qml_data = []
        self._cached_clients = [] 

        conn = get_db_connection()
        if conn:
            try:
                cur = conn.cursor()
                # Usamos nombre_empresa según tu esquema
                cur.execute('SELECT id_cliente, nombre_empresa FROM "CLIENTE" ORDER BY nombre_empresa ASC')
                rows = cur.fetchall()
                
                for row in rows:
                    id_db = row[0]
                    nombre = row[1]
                    qml_data.append({"nombre": nombre})
                    self._cached_clients.append({"id": id_db, "nombre": nombre})

                cur.close()
                conn.close()
                
                # Seleccionar por defecto el primero si existe
                if self._cached_clients:
                    self._selected_client_id = self._cached_clients[0]["id"]
                    
            except Exception as e:
                print(f"❌ Error cargando clientes: {e}")
                self.notification.emit("Error cargando clientes", True)
        
        return qml_data

    @Slot(int)
    def selectClient(self, index):
        if 0 <= index < len(self._cached_clients):
            selected = self._cached_clients[index]
            self._selected_client_id = selected["id"]
            print(f"👤 Cliente cambiado a: {selected['nombre']} (ID: {self._selected_client_id})")

    # ==========================================================
    # CARRITO Y PRODUCTOS
    # ==========================================================

    @Property(QObject, constant=True)
    def cartModel(self):
        return self._cart_model

    @Property(float, notify=totalChanged)
    def total(self):
        return self._total

    def calculate_total(self):
        self._total = sum(item["subtotal"] for item in self._cart_model.get_items())
        self.totalChanged.emit()

    @Slot(str, int)
    def addProductToCart(self, code, quantity):
        if quantity <= 0:
            self.notification.emit("⚠️ Cantidad inválida", True)
            return

        clean_code = str(code).strip()
        print(f"🔎 Buscando código: '{clean_code}'")

        product = get_product_by_code(clean_code)

        if product:
            stock_actual = int(product['stock'])
            
            if stock_actual >= quantity:
                self._cart_model.add_item(product, quantity)
                self.calculate_total()
                self.notification.emit(f"✅ Agregado: {product['nombre']}", False)
            else:
                self.notification.emit(f"⚠️ Stock insuficiente (Quedan {stock_actual})", True)
        else:
            self.notification.emit(f"❌ Producto '{clean_code}' no encontrado", True)

    @Slot(int)
    def removeFromCart(self, index):
        self._cart_model.remove_item(index)
        self.calculate_total()

    # ==========================================================
    # HISTORIAL DE VENTAS (LISTA SIMPLE)
    # ==========================================================
    
    @Property(list, notify=historyChanged)
    def salesHistoryModel(self):
        """Devuelve la lista simple de diccionarios para QML"""
        return self._sales_history

    @Slot()
    def refreshHistory(self):
        """Consulta la base de datos y actualiza la lista local"""
        print("🔄 Actualizando historial de ventas...")
        self._sales_history = get_sales_history()
        self.historyChanged.emit()

    # ==========================================================
    # CHECKOUT
    # ==========================================================
    @Slot()
    def checkout(self):
        items = self._cart_model.get_items()
        if not items:
            self.notification.emit("⚠️ Carrito vacío", True)
            return

        # Si no hay cliente seleccionado, intenta usar el primero o deja que la DB maneje nulos
        client_id_final = self._selected_client_id
        user_id = 1 

        print(f"🚀 Iniciando cobro. Cliente: {client_id_final}, Total: {self._total}")

        success, msg = save_sale_transaction(user_id, client_id_final, self._total, items) 

        if success:
            self._cart_model.clear_cart()
            self.calculate_total()
            self.notification.emit("✅ Venta exitosa", False)
            
            # 🔥 RECARGAR HISTORIAL AUTOMÁTICAMENTE
            self.refreshHistory()
        else:
            self.notification.emit(f"❌ Error: {msg}", True)