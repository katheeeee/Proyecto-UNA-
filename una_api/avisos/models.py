from django.db import models

from servicios.models import Servicio


class Aviso(models.Model):
    """Aviso institucional que ve el estudiante."""

    titulo = models.CharField(max_length=80)
    mensaje = models.TextField()
    servicio = models.ForeignKey(Servicio, on_delete=models.PROTECT, related_name="avisos")
    fecha_actualizacion = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.titulo
