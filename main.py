import sys, os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

# Controladores
from src.controllers.controller import Controller
from src.controllers.pos_controller import PosController

# Base de datos
from src.database.database import load_products, get_sales_history 

# Modelos
from src.models.models import ProductModel
from src.models.sales_model import SalesModel

def main():
    app = QGuiApplication(sys.argv)
    QQuickStyle.setStyle("Fusion")

    engine = QQmlApplicationEngine()
    
    # Controladores principales
    controller = Controller(engine)
    engine.rootContext().setContextProperty("Controller", controller)

    pos_controller = PosController()
    engine.rootContext().setContextProperty("posBackend", pos_controller)

    # Modelos de datos
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
