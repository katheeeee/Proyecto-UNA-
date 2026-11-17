"""
Gestion de Avisos - logica del componente (REQUIERE el servicio de Gestion de Servicios).
Solo usa ServicioService.verificar_servicio_activo(); no consulta la tabla de servicios.
"""
from servicios.services import ServicioService

from .models import Aviso

MAX_TITULO = 80
MIN_MENSAJE = 10


class AvisoService:
    @staticmethod
    def validar_aviso(titulo, mensaje, servicio):
        """Valida el formato de los datos. Lanza ValueError con el motivo."""
        if not all(isinstance(dato, str) for dato in (titulo, mensaje, servicio)):
            raise ValueError("Los datos del aviso deben ser texto.")
        if titulo.strip() == "":
            raise ValueError("El titulo no puede estar vacio.")
        if len(titulo.strip()) > MAX_TITULO:
            raise ValueError("El titulo no puede pasar de 80 caracteres.")
        if len(mensaje.strip()) < MIN_MENSAJE:
            raise ValueError("El mensaje debe tener al menos 10 caracteres.")

    @staticmethod
    def registrar_aviso(titulo, mensaje, servicio):
        """Valida, pide a Gestion de Servicios verificar el servicio y guarda el aviso."""
        AvisoService.validar_aviso(titulo, mensaje, servicio)
        servicio_activo = ServicioService.verificar_servicio_activo(servicio)  # <-- integracion
        if servicio_activo is None:
            raise ValueError("El servicio no existe o no esta activo.")
        return Aviso.objects.create(
            titulo=titulo.strip(), mensaje=mensaje.strip(), servicio=servicio_activo
        )
