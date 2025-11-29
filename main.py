import sys
import os
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuickControls2 import QQuickStyle

# Controladores
from src.controllers.controller import Controller
from src.controllers.pos_controller import PosController

# Base de datos
from src.database.product_repo import load_products
from src.database.sales_repo import get_sales_history

# Modelos
from src.models.models import ProductModel
from src.models.sales_model import SalesModel

def main():
    app = QGuiApplication(sys.argv)
    QQuickStyle.setStyle("Fusion")

    engine = QQmlApplicationEngine()
    
    # --- Controladores ---
    controller = Controller(engine)
    engine.rootContext().setContextProperty("Controller", controller)

    pos_controller = PosController()
    engine.rootContext().setContextProperty("posBackend", pos_controller)

    # --- Carga de PRODUCTOS ---
    print("🔄 Cargando productos...")
    products_data = load_products() 
    print(f"📦 Productos encontrados en BD: {len(products_data)}") # DEBUG CRÍTICO
    
    products_model = ProductModel(products_data)
    engine.rootContext().setContextProperty("productsModel", products_model)

    # --- Carga de VENTAS ---
    sales_data = get_sales_history()
    sales_model = SalesModel(sales_data)
    engine.rootContext().setContextProperty("salesModel", sales_model)

    # --- Carga de Interfaz ---
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # Asegúrate de que login.qml esté en src/ui/
    login_path = os.path.join(current_dir, "src", "ui", "login.qml")
    
    if not os.path.exists(login_path):
        print(f"❌ ERROR: No encuentro el archivo: {login_path}")
        sys.exit(-1)

    engine.load(login_path)

    if not engine.rootObjects():
        sys.exit(-1)
    
    sys.exit(app.exec())

if __name__ == "__main__":
    main()