from sqlalchemy import (
    create_engine, Column, Integer, String, Text, ForeignKey,
    DECIMAL, Date, DateTime
)
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy.sql import func

Base = declarative_base()

# ROL
class Rol(Base):
    __tablename__ = "ROL"
    id_rol = Column(Integer, primary_key=True)
    nombre_rol = Column(String(50), unique=True, nullable=False)
    descripcion = Column(Text)

    usuarios = relationship("Usuario", back_populates="rol")

# UBICACION
class Ubicacion(Base):
    __tablename__ = "UBICACION"
    id_ubicacion = Column(Integer, primary_key=True)
    nombre_ubicacion = Column(String(100), unique=True, nullable=False)
    descripcion = Column(Text)

    activos = relationship("ActivoFijo", back_populates="ubicacion")

# USUARIO
class Usuario(Base):
    __tablename__ = "USUARIO"
    id_usuario = Column(Integer, primary_key=True)
    nombre = Column(String(100), nullable=False)
    apellido = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    id_rol = Column(Integer, ForeignKey("ROL.id_rol"), nullable=False)

    rol = relationship("Rol", back_populates="usuarios")
    ventas_realizadas = relationship("Venta", back_populates="vendedor")
    activos_responsables = relationship("ActivoFijo", back_populates="responsable")

# PRODUCTO
class Producto(Base):
    __tablename__ = "PRODUCTO"
    id_producto = Column(Integer, primary_key=True)
    codigo_producto = Column(String(50), unique=True, nullable=False)
    nombre = Column(String(100), nullable=False)
    descripcion = Column(Text)
    precio_unitario = Column(DECIMAL(10, 2))
    unidad_medida = Column(String(20))
    stock = Column(Integer, default=0, nullable=False)

    detalles_venta = relationship("DetalleVenta", back_populates="producto")

# VENTA
class Venta(Base):
    __tablename__ = "VENTA"
    id_venta = Column(Integer, primary_key=True)
    id_usuario = Column(Integer, ForeignKey("USUARIO.id_usuario"), nullable=False)
    
    fecha_venta = Column(DateTime(timezone=True), server_default=func.now())
    total_venta = Column(DECIMAL(10, 2), default=0.00)
    metodo_pago = Column(String(50), default="Efectivo")
    sucursal = Column(String(100), default="Tonalá")
    
    vendedor = relationship("Usuario", back_populates="ventas_realizadas")
    detalles = relationship("DetalleVenta", back_populates="venta", cascade="all, delete-orphan")

# DETALLE DE VENTA
class DetalleVenta(Base):
    __tablename__ = "DETALLE_VENTA"
    id_detalle = Column(Integer, primary_key=True)
    id_venta = Column(Integer, ForeignKey("VENTA.id_venta"), nullable=False)
    id_producto = Column(Integer, ForeignKey("PRODUCTO.id_producto"), nullable=False)
    
    cantidad = Column(Integer, nullable=False)
    precio_unitario = Column(DECIMAL(10, 2), nullable=False)
    subtotal = Column(DECIMAL(10, 2), nullable=False)
    
    venta = relationship("Venta", back_populates="detalles")
    producto = relationship("Producto", back_populates="detalles_venta")

# ACTIVO FIJO
class ActivoFijo(Base):
    __tablename__ = "ACTIVO_FIJO"
    id_activo = Column(Integer, primary_key=True)
    codigo_activo = Column(String(50), unique=True, nullable=False)
    nombre = Column(String(100), nullable=False)
    descripcion = Column(Text)
    fecha_adquisicion = Column(Date)
    costo_adquisicion = Column(DECIMAL(10, 2))
    vida_util_meses = Column(Integer)
    valor_residual = Column(DECIMAL(10, 2))
    id_ubicacion = Column(Integer, ForeignKey("UBICACION.id_ubicacion"))
    id_responsable = Column(Integer, ForeignKey("USUARIO.id_usuario"), nullable=False)

    ubicacion = relationship("Ubicacion", back_populates="activos")
    responsable = relationship("Usuario", back_populates="activos_responsables")
    mantenimientos = relationship("MantenimientoActivo", back_populates="activo")

# MANTENIMIENTO
class MantenimientoActivo(Base):
    __tablename__ = "MANTENIMIENTO_ACTIVO"
    id_mantenimiento = Column(Integer, primary_key=True)
    id_activo = Column(Integer, ForeignKey("ACTIVO_FIJO.id_activo"), nullable=False)
    fecha_mantenimiento = Column(Date)
    tipo_mantenimiento = Column(String(50))
    costo = Column(DECIMAL(10, 2))
    observaciones = Column(Text)

    activo = relationship("ActivoFijo", back_populates="mantenimientos")

# CONEXIÓN
engine = create_engine("postgresql://postgres:160603@localhost:5432/CastorTesla")

# CREAR TABLAS
Base.metadata.create_all(engine)

print("✅ Tablas actualizadas correctamente")
