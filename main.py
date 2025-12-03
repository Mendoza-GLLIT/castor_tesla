import sys, os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle
from PySide6.QtCore import QUrl # <--- IMPORTANTE: Necesario para la ruta de iconos

# Controladores
from src.controllers.auth_controller import AuthController
from src.controllers.pos_controller import PosController
from src.controllers.employers_controller import EmployersController
from src.controllers.inventory_controller import InventoryController
from src.controllers.clients_controller import ClientsController
from src.controllers.assets_controller import AssetsController
from src.controllers.stats_controller import StatsController

# Repositorios
from src.database.product_repo import load_products
from src.database.sales_repo import get_sales_history 

# Modelos
from src.models.models import ProductModel
from src.models.sales_model import SalesModel

def main():
    app = QGuiApplication(sys.argv)
    QQuickStyle.setStyle("Fusion")
    
    app.setOrganizationName("CastorTesla")
    app.setOrganizationDomain("castor.com")

    engine = QQmlApplicationEngine()

    # ============================================================
    # 👇👇👇 CONFIGURACIÓN DE RUTAS DE ICONOS 👇👇👇
    # ============================================================
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 1. Calculamos la ruta: carpeta_del_proyecto/resources/icons
    icons_path = os.path.join(current_dir, "resources", "icons")
    
    # 2. Convertimos a URL compatible con QML (file:///C:/...)
    icons_url = QUrl.fromLocalFile(icons_path).toString()
    
    # 3. Inyectamos la variable global a QML para que SidebarButton la use
    engine.rootContext().setContextProperty("iconBasePath", icons_url)
    # ============================================================
    
    # --- 1. Modelos de Datos (Deben cargarse primero) ---
    products_data = load_products()
    products_model = ProductModel(products_data)
    engine.rootContext().setContextProperty("productsModel", products_model)

    sales_data = get_sales_history()
    sales_model = SalesModel(sales_data)
    engine.rootContext().setContextProperty("salesModel", sales_model)

    # --- 2. Controladores ---
    
    # Auth Controller
    auth_controller = AuthController(engine)
    engine.rootContext().setContextProperty("auth", auth_controller)

    # POS Controller
    pos_controller = PosController(auth_controller, products_model)
    engine.rootContext().setContextProperty("posBackend", pos_controller)

    # Employers Controller
    employers_controller = EmployersController()
    engine.rootContext().setContextProperty("employersBackend", employers_controller)

    # Inventory Controller
    inventory_controller = InventoryController(products_model) 
    engine.rootContext().setContextProperty("inventoryCtrl", inventory_controller)
    
    # 👇👇👇 NUEVO: CLIENTS CONTROLLER 👇👇👇
    clients_controller = ClientsController()
    engine.rootContext().setContextProperty("clientsBackend", clients_controller)
    # 👆👆👆
    
    # 👇👇👇 REGISTRO DEL CONTROLADOR DE ACTIVOS 👇👇👇
    assets_controller = AssetsController()
    engine.rootContext().setContextProperty("assetsBackend", assets_controller)
    # 👆👆👆
    
    # 👇👇👇 NUEVO: STATS CONTROLLER 👇👇👇
    stats_controller = StatsController()
    engine.rootContext().setContextProperty("statsBackend", stats_controller)
    # 👆👆👆

    # --- 3. Cargar UI ---
    login_path = os.path.join(current_dir, "src", "ui", "login.qml")
    
    engine.load(login_path)

    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())

if __name__ == "__main__":
    main()