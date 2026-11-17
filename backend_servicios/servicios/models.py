from django.db import models


class Servicio(models.Model):

    CATEGORIAS = [
        ('comedor', 'Comedor universitario'),
        ('transporte', 'Transporte universitario'),
        ('medico', 'Servicio médico'),
        ('avisos', 'Avisos institucionales'),
    ]

    nombre = models.CharField(max_length=100)

    descripcion = models.TextField()

    categoria = models.CharField(
        max_length=20,
        choices=CATEGORIAS
    )

    estado = models.BooleanField(default=True)

    fecha_actualizacion = models.DateTimeField(
        auto_now=True
    )

    def __str__(self):
        return self.nombre

    class Meta:
        verbose_name = 'Servicio'
        verbose_name_plural = 'Servicios'
        ordering = ['nombre']