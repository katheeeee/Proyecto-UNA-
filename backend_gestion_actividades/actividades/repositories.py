
from .models import Actividad


class ActividadRepository:

    def guardar(self, datos):
        return Actividad.objects.create(**datos)

    def obtener_por_id(self, actividad_id):
        return Actividad.objects.filter(
            id=actividad_id
        ).first()

    def obtener_por_estudiante(self, estudiante_id):
        return Actividad.objects.filter(
            estudiante_id=estudiante_id
        ).order_by("fecha_entrega")

    def obtener_todas(self):
        return Actividad.objects.all()
