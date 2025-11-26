from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.database import get_product_by_code, save_sale_transaction
from src.models.cart_model import CartModel

class PosController(QObject):
    totalChanged = Signal()
    notification = Signal(str, bool)  # mensaje, es_error

    def __init__(self):
        super().__init__()
        self._cart_model = CartModel()
        self._total = 0.0

    @Property(QObject, constant=True)
    def cartModel(self):
        return self._cart_model

    @Property(float, notify=totalChanged)
    def total(self):
        return self._total

    def calculate_total(self):
        self._total = sum(item["subtotal"] for item in self._cart_model.get_items())
        self.totalChanged.emit()

    @Slot(str)
    def addToCart(self, raw_input):
        code = raw_input.strip()
        quantity = 1

        # Soporte para codigo*cantidad
        if "*" in raw_input:
            try:
                parts = raw_input.split("*")
                code = parts[0].strip()
                quantity_str = parts[1].strip()

                if not quantity_str.isdigit():
                    raise ValueError

                quantity = int(quantity_str)

                if quantity <= 0:
                    self.notification.emit("⚠️ La cantidad debe ser mayor a 0", True)
                    return

            except ValueError:
                self.notification.emit("⚠️ Formato incorrecto. Usa: CODIGO*CANTIDAD", True)
                return

        product = get_product_by_code(code)

        if product:
            # Validación de stock
            if product['stock'] >= quantity:
                self._cart_model.add_item(product, quantity)
                self.calculate_total()

                if quantity > 1:
                    self.notification.emit(f"Agregados: {quantity}x {product['nombre']}", False)
                else:
                    self.notification.emit(f"Agregado: {product['nombre']}", False)
            else:
                self.notification.emit(f"❌ Stock insuficiente (Disponible: {product['stock']})", True)
        else:
            self.notification.emit("❌ Producto no encontrado", True)

    @Slot(int)
    def removeFromCart(self, index):
        self._cart_model.remove_item(index)
        self.calculate_total()

    @Slot()
    def checkout(self):
        items = self._cart_model.get_items()
        if not items:
            self.notification.emit("⚠️ El carrito está vacío", True)
            return

        user_id = 1  # Temporal
        success, msg = save_sale_transaction(user_id, self._total, items)

        if success:
            self._cart_model.clear_cart()
            self.calculate_total()
            self.notification.emit("✅ Venta realizada con éxito", False)
        else:
            self.notification.emit(f"❌ Error: {msg}", True)
