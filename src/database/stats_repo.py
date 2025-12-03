from src.database.connection import get_db_connection
from datetime import datetime

def get_monthly_revenue():
    """Devuelve una lista de 12 valores (uno por mes) del año actual."""
    conn = get_db_connection()
    if not conn: return [0]*12, 0.0

    try:
        cur = conn.cursor()
        current_year = datetime.now().year
        
        # Consulta para sumar ventas agrupadas por mes
        query = """
            SELECT EXTRACT(MONTH FROM fecha_venta) as mes, SUM(total_venta)
            FROM "VENTA"
            WHERE EXTRACT(YEAR FROM fecha_venta) = %s
            GROUP BY mes
            ORDER BY mes ASC
        """
        cur.execute(query, (current_year,))
        rows = cur.fetchall()
        
        # Inicializamos lista de 12 ceros
        revenue = [0.0] * 12
        max_val = 0.0
        
        for r in rows:
            mes_idx = int(r[0]) - 1 # Mes 1 es índice 0
            total = float(r[1])
            revenue[mes_idx] = total
            if total > max_val: max_val = total
            
        return revenue, max_val
    except Exception as e:
        print(f"❌ Error Stats Revenue: {e}")
        return [0]*12, 0.0
    finally:
        conn.close()

def get_top_products():
    """Top 5 productos más vendidos."""
    conn = get_db_connection()
    if not conn: return []
    try:
        cur = conn.cursor()
        query = """
            SELECT p.nombre, SUM(dv.cantidad) as total_vendido
            FROM "DETALLE_VENTA" dv
            JOIN "PRODUCTO" p ON dv.id_producto = p.id_producto
            GROUP BY p.nombre
            ORDER BY total_vendido DESC
            LIMIT 5
        """
        cur.execute(query)
        rows = cur.fetchall()
        return [{"nombre": r[0], "cantidad": int(r[1])} for r in rows]
    except Exception as e:
        print(f"❌ Error Stats Productos: {e}")
        return []
    finally:
        conn.close()

def get_top_clients():
    """Top 5 clientes que más dinero han gastado."""
    conn = get_db_connection()
    if not conn: return []
    try:
        cur = conn.cursor()
        query = """
            SELECT c.nombre_empresa, SUM(v.total_venta) as total_gastado
            FROM "VENTA" v
            JOIN "CLIENTE" c ON v.id_cliente = c.id_cliente
            GROUP BY c.nombre_empresa
            ORDER BY total_gastado DESC
            LIMIT 5
        """
        cur.execute(query)
        rows = cur.fetchall()
        return [{"nombre": r[0], "total": float(r[1])} for r in rows]
    except Exception as e:
        print(f"❌ Error Stats Clientes: {e}")
        return []
    finally:
        conn.close()

def get_kpis():
    """KPIs rápidos: Ventas de hoy, Total Productos, etc."""
    conn = get_db_connection()
    if not conn: return {"ventas_hoy": 0, "total_stock": 0}
    try:
        cur = conn.cursor()
        # Ventas Hoy
        cur.execute("SELECT SUM(total_venta) FROM \"VENTA\" WHERE date(fecha_venta) = CURRENT_DATE")
        row_sales = cur.fetchone()
        sales_today = float(row_sales[0]) if row_sales and row_sales[0] else 0.0
        
        # Stock Total
        cur.execute("SELECT SUM(stock) FROM \"PRODUCTO\"")
        row_stock = cur.fetchone()
        total_stock = int(row_stock[0]) if row_stock and row_stock[0] else 0
        
        return {"ventas_hoy": sales_today, "total_stock": total_stock}
    except Exception as e:
        return {"ventas_hoy": 0, "total_stock": 0}
    finally:
        conn.close()
        
def get_sales_comparison():
    """Retorna: (Ventas Mes Actual, Ventas Mes Pasado)"""
    conn = get_db_connection()
    if not conn: return 0.0, 0.0
    try:
        cur = conn.cursor()
        today = datetime.now()
        current_month = today.month
        current_year = today.year
        
        # Calcular mes anterior
        last_month = current_month - 1
        last_month_year = current_year
        if last_month == 0:
            last_month = 12
            last_month_year = current_year - 1

        # 1. Ventas Mes Actual
        query_curr = """
            SELECT SUM(total_venta) FROM "VENTA" 
            WHERE EXTRACT(MONTH FROM fecha_venta) = %s AND EXTRACT(YEAR FROM fecha_venta) = %s
        """
        cur.execute(query_curr, (current_month, current_year))
        res_curr = cur.fetchone()
        total_curr = float(res_curr[0]) if res_curr and res_curr[0] else 0.0

        # 2. Ventas Mes Anterior
        query_last = """
            SELECT SUM(total_venta) FROM "VENTA" 
            WHERE EXTRACT(MONTH FROM fecha_venta) = %s AND EXTRACT(YEAR FROM fecha_venta) = %s
        """
        cur.execute(query_last, (last_month, last_month_year))
        res_last = cur.fetchone()
        total_last = float(res_last[0]) if res_last and res_last[0] else 0.0

        return total_curr, total_last
    except Exception as e:
        print(f"❌ Error comparando ventas: {e}")
        return 0.0, 0.0
    finally:
        conn.close()