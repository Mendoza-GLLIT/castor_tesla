from PySide6.QtCore import QObject, Slot, Signal, Property
from src.database.stats_repo import get_monthly_revenue, get_top_products, get_top_clients, get_kpis, get_sales_comparison

class StatsController(QObject):
    dataChanged = Signal()

    def __init__(self):
        super().__init__()
        self._revenue_data = [] 
        self._max_revenue = 1.0 
        self._top_products = []
        self._top_clients = []
        self._kpis = {"ventas_hoy": 0.0, "total_stock": 0}
        
        # Nuevos datos de comparación
        self._sales_curr_month = 0.0
        self._sales_last_month = 0.0
        self._growth_percent = 0.0
        
        self.refreshData()

    @Property(list, notify=dataChanged)
    def revenueData(self): return self._revenue_data

    @Property(float, notify=dataChanged)
    def maxRevenue(self): return self._max_revenue

    @Property(list, notify=dataChanged)
    def topProductsModel(self): return self._top_products

    @Property(list, notify=dataChanged)
    def topClientsModel(self): return self._top_clients
    
    @Property(float, notify=dataChanged)
    def salesToday(self): return self._kpis["ventas_hoy"]
    
    @Property(int, notify=dataChanged)
    def stockTotal(self): return self._kpis["total_stock"]

    # --- NUEVAS PROPIEDADES PARA EL DASHBOARD MEJORADO ---
    @Property(float, notify=dataChanged)
    def salesCurrentMonth(self): return self._sales_curr_month

    @Property(float, notify=dataChanged)
    def growthPercent(self): return self._growth_percent

    @Slot()
    def refreshData(self):
        print("📊 Calculando estadísticas...")
        rev, max_rev = get_monthly_revenue()
        self._revenue_data = rev
        self._max_revenue = max_rev if max_rev > 0 else 100.0 
        
        self._top_products = get_top_products()
        self._top_clients = get_top_clients()
        self._kpis = get_kpis()
        
        # Calcular comparación
        curr, last = get_sales_comparison()
        self._sales_curr_month = curr
        self._sales_last_month = last
        
        if last > 0:
            self._growth_percent = ((curr - last) / last) * 100
        else:
            self._growth_percent = 100.0 if curr > 0 else 0.0
        
        self.dataChanged.emit()