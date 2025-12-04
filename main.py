import sys, os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtCore import QUrl

# Controladores
from src.controllers.auth_controller import AuthController
from src.controllers.pos_controller import PosController
from src.controllers.employers_controller import EmployersController
from src.controllers.inventory_controller import InventoryController
from src.controllers.clients_controller import ClientsController
from src.controllers.assets_controller import AssetsController
from src.controllers.stats_controller import StatsController
from src.controllers.messages_controller import MessagesController

# Repositorios y Modelos
from src.database.product_repo import load_products
from src.database.sales_repo import get_sales_history 
from src.models.models import ProductModel
from src.models.sales_model import SalesModel

def main():
    app = QGuiApplication(sys.argv)
    QQuickStyle.setStyle("Fusion")
    
    app.setOrganizationName("CastorTesla")
    app.setOrganizationDomain("castor.com")

    engine = QQmlApplicationEngine()

    # --- RUTAS ---
    current_dir = os.path.dirname(os.path.abspath(__file__))
    icons_path = os.path.join(current_dir, "resources", "icons")
    icons_url = QUrl.fromLocalFile(icons_path).toString()
    engine.rootContext().setContextProperty("iconBasePath", icons_url)
    
    # --- MODELOS ---
    products_data = load_products()
    products_model = ProductModel(products_data)
    engine.rootContext().setContextProperty("productsModel", products_model)

    sales_data = get_sales_history()
    sales_model = SalesModel(sales_data)
    engine.rootContext().setContextProperty("salesModel", sales_model)

    # --- CONTROLADORES ---
    auth_controller = AuthController(engine)
    engine.rootContext().setContextProperty("auth", auth_controller)

    pos_controller = PosController(auth_controller, products_model)
    engine.rootContext().setContextProperty("posBackend", pos_controller)

    employers_controller = EmployersController()
    engine.rootContext().setContextProperty("employersBackend", employers_controller)

    inventory_controller = InventoryController(products_model) 
    engine.rootContext().setContextProperty("inventoryCtrl", inventory_controller)
    
    clients_controller = ClientsController()
    engine.rootContext().setContextProperty("clientsBackend", clients_controller)
    
    assets_controller = AssetsController()
    engine.rootContext().setContextProperty("assetsBackend", assets_controller)
    
    stats_controller = StatsController()
    engine.rootContext().setContextProperty("statsBackend", stats_controller)
    
    messages_controller = MessagesController()
    engine.rootContext().setContextProperty("messagesBackend", messages_controller)

    # --- ESCANEO AUTOMÁTICO DE INICIO ---
    # Esto llena las notificaciones si hay stock bajo al abrir la app
    inventory_controller.scan_all_low_stock()

    # --- CARGA DE UI ---
    login_path = os.path.join(current_dir, "src", "ui", "login.qml")
    engine.load(login_path)

    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())

if __name__ == "__main__":
    main()