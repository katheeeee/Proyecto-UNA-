from django.db import models


class Servicio(models.Model):
    """Servicio universitario (transporte, comedor, servicio medico)."""

    nombre = models.CharField(max_length=50, unique=True)
    activo = models.BooleanField(default=True)

    def __str__(self):
        return self.nombre
