"""
UNA+ - Gestion de Servicios (componente que PROPORCIONA el servicio)
Responsabilidad: administrar los servicios universitarios y decir si estan activos.
Autor : Mendoza Coila Jamiel Romario
"""


class Servicio:
    """Representa un servicio universitario (transporte, comedor, etc.)."""

    def __init__(self, nombre, activo=True):
        self.nombre = nombre
        self.activo = activo


class ServicioService:
    """Servicio publico del componente Gestion de Servicios."""

    def __init__(self, servicios=None):
        self._servicios = {s.nombre: s for s in (servicios or [])}

    def verificar_servicio_activo(self, nombre):
        """Devuelve True si el servicio existe y esta activo; si no, False."""
        if not isinstance(nombre, str):
            return False
        servicio = self._servicios.get(nombre.strip().lower())
        return servicio is not None and servicio.activo


def crear_servicios_piloto():
    """Configuracion de prueba: el servicio medico aun no se incorpora al piloto."""
    return ServicioService([
        Servicio("transporte", activo=True),
        Servicio("comedor", activo=True),
        Servicio("servicio medico", activo=False),
    ])