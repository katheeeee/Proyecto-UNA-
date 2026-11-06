from django.db import models


class Actividad(models.Model):

    TIPOS_ACTIVIDAD = [
        ("tarea", "Tarea"),
        ("evaluacion", "Evaluación"),
        ("actividad", "Actividad"),
    ]

    estudiante_id = models.IntegerField()
    titulo = models.CharField(max_length=150)
    curso = models.CharField(max_length=100)
    tipo = models.CharField(
        max_length=20,
        choices=TIPOS_ACTIVIDAD
    )
    fecha_entrega = models.DateTimeField()
    descripcion = models.TextField(blank=True, null=True)

    fecha_registro = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.titulo