from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.product_repo import get_product_by_code
from src.database.sales_repo import save_sale_transaction, get_sales_history 
from src.models.cart_model import CartModel
from src.database.connection import get_db_connection

class PosController(QObject):
    totalChanged = Signal()
    notification = Signal(str, bool)
    historyChanged = Signal()
    userNameChanged = Signal()

    def __init__(self, auth_controller, products_model):
        super().__init__()
        self._auth = auth_controller
        self._product_model = products_model # Referencia al modelo para actualizar UI
        
        self._auth.userChanged.connect(self.userNameChanged.emit)

        self._cart_model = CartModel()
        self._total = 0.0
        
        self._selected_client_id = None 
        self._cached_clients = []
        self._sales_history = []
        
        self.refreshHistory() 

    # --- PROPIEDADES ---

    @Property(str, notify=userNameChanged)
    def currentUserName(self):
        name = self._auth.fullName
        return name if name else "Sin Cajero Asignado"

    @Property(list, constant=True)
    def clientsModel(self):
        qml_data = []
        self._cached_clients = [] 
        conn = get_db_connection()
        if conn:
            try:
                cur = conn.cursor()
                cur.execute('SELECT id_cliente, nombre_empresa FROM "CLIENTE" ORDER BY nombre_empresa ASC')
                rows = cur.fetchall()
                for row in rows:
                    id_db = row[0]
                    nombre = row[1]
                    qml_data.append({"nombre": nombre})
                    self._cached_clients.append({"id": id_db, "nombre": nombre})
                cur.close()
                conn.close()
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
            print(f"👤 Cliente: {selected['nombre']} (ID: {self._selected_client_id})")

    # --- CARRITO ---

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

    # --- HISTORIAL ---

    @Property(list, notify=historyChanged)
    def salesHistoryModel(self):
        return self._sales_history

    @Slot()
    def refreshHistory(self):
        self._sales_history = get_sales_history()
        self.historyChanged.emit()

    # --- CHECKOUT (COBRO) ---

    @Slot()
    def checkout(self):
        items_sold = self._cart_model.get_items()
        
        if not items_sold:
            self.notification.emit("⚠️ Carrito vacío", True)
            return

        client_id_final = self._selected_client_id
        user_id = self._auth._user_session.get("id", 0)

        if user_id == 0:
            self.notification.emit("⚠️ Error: No hay un cajero logueado válido", True)
            return

        print(f"🚀 Cobrando. Cliente: {client_id_final}, Cajero: {user_id}, Total: {self._total}")

        success, msg = save_sale_transaction(user_id, client_id_final, self._total, items_sold) 

        if success:
            # ACTUALIZAR UI AL MOMENTO
            for item in items_sold:
                # Restamos el stock visualmente usando el modelo
                self._product_model.decrease_stock_ui(item['id'], item['cantidad'])

            self._cart_model.clear_cart()
            self.calculate_total()
            self.notification.emit("✅ Venta exitosa", False)
            self.refreshHistory()
        else:
            self.notification.emit(f"❌ Error: {msg}", True)