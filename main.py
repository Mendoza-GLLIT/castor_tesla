import sys, os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

# Controladores
from src.controllers.auth_controller import AuthController
from src.controllers.pos_controller import PosController

# Repositorios (Bases de datos)
from src.database.product_repo import load_products
from src.database.sales_repo import get_sales_history 

# Modelos
from src.models.models import ProductModel
from src.models.sales_model import SalesModel

def main():
    app = QGuiApplication(sys.argv)
    QQuickStyle.setStyle("Fusion")
    
    # Nombre de organización para QSettings (Recordarme)
    app.setOrganizationName("CastorTesla")
    app.setOrganizationDomain("castor.com")

    engine = QQmlApplicationEngine()
    
    # --- AQUI ESTÁ EL CAMBIO IMPORTANTE ---
    # Usamos AuthController en lugar del viejo Controller
    auth_controller = AuthController(engine)
    engine.rootContext().setContextProperty("auth", auth_controller)

    # Backend del POS
    pos_controller = PosController()
    engine.rootContext().setContextProperty("posBackend", pos_controller)

    # Cargar Modelos de Datos
    products_data = load_products()
    products_model = ProductModel(products_data)
    engine.rootContext().setContextProperty("productsModel", products_model)

    sales_data = get_sales_history()
    sales_model = SalesModel(sales_data)
    engine.rootContext().setContextProperty("salesModel", sales_model)

    # Cargar vista inicial (Login)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    login_path = os.path.join(current_dir, "src", "ui", "login.qml")
    
    engine.load(login_path)

    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())

if __name__ == "__main__":
    main()