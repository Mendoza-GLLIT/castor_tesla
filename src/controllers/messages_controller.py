import sys
import os
from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.messages_repo import get_notifications

def resource_path(relative_path):
    """Devuelve la ruta absoluta de un recurso, compatible con PyInstaller."""
    try:
        base_path = sys._MEIPASS  # Si estamos en .exe
    except AttributeError:
        base_path = os.path.abspath(".")  # Si estamos en desarrollo
    return os.path.join(base_path, relative_path)

class MessagesController(QObject):
    messagesChanged = Signal()

    def __init__(self):
        super().__init__()
        self._messages = []
        self.refreshData()

    @Property(list, notify=messagesChanged)
    def messagesModel(self):
        return self._messages

    @Slot()
    def refreshData(self):
        raw_messages = get_notifications()
        for msg in raw_messages:
            if "icon" in msg:
                # Convierte la ruta a absoluta para el .exe
                msg["icon"] = resource_path(msg["icon"])
        self._messages = raw_messages
        self.messagesChanged.emit()
