from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.product_repo import get_product_by_code
from src.database.sales_repo import save_sale_transaction, get_sales_history 
from src.models.cart_model import CartModel
from src.database.connection import get_db_connection
from src.database.messages_repo import create_notification


class PosController(QObject):
    totalChanged = Signal()
    notification = Signal(str, bool, str)   # mensaje, esError, iconPath
    historyChanged = Signal()
    userNameChanged = Signal()

    def __init__(self, auth_controller, products_model):
        super().__init__()
        self._auth = auth_controller
        self._product_model = products_model
        self._auth.userChanged.connect(self.userNameChanged.emit)

        self._cart_model = CartModel()
        self._total = 0.0
        self._selected_client_id = None
        self._cached_clients = []
        self._sales_history = []

        self.refreshHistory()

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
                    qml_data.append({"nombre": row[1]})
                    self._cached_clients.append({"id": row[0], "nombre": row[1]})

                cur.close()
                conn.close()

                if self._cached_clients:
                    self._selected_client_id = self._cached_clients[0]["id"]

            except Exception as e:
                print(f"Error cargando clientes: {e}")

        return qml_data

    @Slot(int)
    def selectClient(self, index):
        if 0 <= index < len(self._cached_clients):
            self._selected_client_id = self._cached_clients[index]["id"]

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
            self.notification.emit("Cantidad inválida", True, "resources/icons/error.png")
            return

        clean_code = str(code).strip()
        product = get_product_by_code(clean_code)

        if product:
            stock_real_bd = int(product['stock'])

            cantidad_ya_en_carrito = 0
            for item in self._cart_model.get_items():
                if item['id'] == product['id_producto']:
                    cantidad_ya_en_carrito += item['cantidad']

            cantidad_total_deseada = cantidad_ya_en_carrito + quantity

            if stock_real_bd >= cantidad_total_deseada:
                self._cart_model.add_item(product, quantity)
                self.calculate_total()
                self.notification.emit(
                    f"Agregado: {product['nombre']}",
                    False,
                    "resources/icons/success.png"
                )
            else:
                disponible_real = max(0, stock_real_bd - cantidad_ya_en_carrito)
                self.notification.emit(
                    f"Stock insuficiente. Solo puedes agregar {disponible_real} más.",
                    True,
                    "resources/icons/warning.png"
                )
        else:
            self.notification.emit(
                f"Producto '{clean_code}' no encontrado",
                True,
                "resources/icons/error.png"
            )

    @Slot(int)
    def removeFromCart(self, index):
        self._cart_model.remove_item(index)
        self.calculate_total()

    @Property(list, notify=historyChanged)
    def salesHistoryModel(self):
        return self._sales_history

    @Slot()
    def refreshHistory(self):
        self._sales_history = get_sales_history()
        self.historyChanged.emit()

    @Slot()
    def checkout(self):
        items_sold = self._cart_model.get_items()

        if not items_sold:
            self.notification.emit("Carrito vacío", True, "resources/icons/warning.png")
            return

        client_id_final = self._selected_client_id
        user_id = self._auth._user_session.get("id", 0)

        if user_id == 0:
            self.notification.emit("Error: No hay cajero logueado", True, "resources/icons/error.png")
            return

        total_final = self._total

        nombre_cliente = "Público General"
        if client_id_final:
            for c in self._cached_clients:
                if c["id"] == client_id_final:
                    nombre_cliente = c["nombre"]
                    break

        try:
            # Revisar stock
            for item in items_sold:
                nombre_prod = item['nombre']

                stock_en_memoria = 0
                for p in self._product_model._all_products:
                    if p['id_producto'] == item['id']:
                        stock_en_memoria = int(p['stock'])
                        break

                nuevo_stock = max(0, stock_en_memoria - item['cantidad'])

                if nuevo_stock < 500:
                    create_notification(
                        "STOCK CRÍTICO",
                        f"'{nombre_prod}' quedó con {nuevo_stock} u.",
                        "critical",
                        "resources/icons/alert.png"
                    )
                elif nuevo_stock < 1000:
                    create_notification(
                        "Advertencia Stock",
                        f"'{nombre_prod}' bajó a {nuevo_stock} u.",
                        "warning",
                        "resources/icons/warning.png"
                    )

            # Guardar venta
            success, msg = save_sale_transaction(user_id, client_id_final, total_final, items_sold)

            if success:
                for item in items_sold:
                    self._product_model.decrease_stock_ui(item['id'], item['cantidad'])

                self._cart_model.clear_cart()
                self.calculate_total()

                self.notification.emit("Venta exitosa", False, "resources/icons/success.png")

                create_notification(
                    "Venta Realizada",
                    f"Venta por ${total_final:.2f} a {nombre_cliente}.",
                    "success",
                    "resources/icons/success.png"
                )

                self.refreshHistory()
            else:
                self.notification.emit(f"Error: {msg}", True, "resources/icons/error.png")

        except Exception as e:
            print(f"Error en checkout: {e}")
            self.notification.emit("Error crítico procesando venta", True, "resources/icons/error.png")
