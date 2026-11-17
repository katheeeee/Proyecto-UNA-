from django.conf import settings
from django.db import models


class Actividad(models.Model):
    TIPO_TAREA = 'tarea'
    TIPO_EVALUACION = 'evaluacion'
    TIPO_TRABAJO_GRUPAL = 'trabajo_grupal'
    TIPO_PROYECTO = 'proyecto'
    TIPO_CHOICES = [
        (TIPO_TAREA, 'Tarea'),
        (TIPO_EVALUACION, 'Evaluación'),
        (TIPO_TRABAJO_GRUPAL, 'Trabajo grupal'),
        (TIPO_PROYECTO, 'Proyecto'),
    ]

    ESTADO_PENDIENTE = 'pendiente'
    ESTADO_ENTREGADA = 'entregada'
    ESTADO_VENCIDA = 'vencida'
    ESTADO_CHOICES = [
        (ESTADO_PENDIENTE, 'Pendiente'),
        (ESTADO_ENTREGADA, 'Entregada'),
        (ESTADO_VENCIDA, 'Vencida'),
    ]

    usuario = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='actividades',
    )
    titulo = models.CharField(max_length=200)
    curso = models.CharField(max_length=120)
    tipo = models.CharField(max_length=20, choices=TIPO_CHOICES, default=TIPO_TAREA)
    fecha_entrega = models.DateTimeField()
    estado = models.CharField(
        max_length=12, choices=ESTADO_CHOICES, default=ESTADO_PENDIENTE
    )
    creado_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'actividad'
        verbose_name_plural = 'actividades'
        ordering = ['fecha_entrega']

    def __str__(self):
        return self.titulo
