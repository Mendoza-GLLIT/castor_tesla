import os
from PySide6.QtCore import QObject, Slot
from src.database.database import check_user_login

class Controller(QObject):
    def __init__(self, engine):
        super().__init__()
        self.engine = engine

    @Slot(str, str, result=bool)  
    def login(self, username, password):
        is_valid = check_user_login(username, password)
        
        if is_valid:
            print("✅ Login exitoso")

            if self.engine.rootObjects():
                window = self.engine.rootObjects()[0]
                window.close()
                self.engine.clearComponentCache()

            current_dir = os.path.dirname(__file__)
            dashboard_path = os.path.join(current_dir, "../ui/views/dashboard.qml")
            
            if not os.path.exists(dashboard_path):
                dashboard_path = os.path.join(current_dir, "../ui/dashboard.qml")

            self.engine.load(dashboard_path)
            return True
        
        print("❌ Login fallido")
        return False
