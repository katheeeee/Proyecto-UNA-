"""
Gestion de Servicios - interfaz publica del componente (PROVEEDOR).
Los demas componentes solo deben usar estas funciones, no las tablas internas.
"""
from .models import Servicio


class ServicioService:
    @staticmethod
    def verificar_servicio_activo(nombre):
        """Devuelve el Servicio si existe y esta activo; si no, devuelve None."""
        if not isinstance(nombre, str):
            return None
        return Servicio.objects.filter(nombre=nombre.strip().lower(), activo=True).first()
