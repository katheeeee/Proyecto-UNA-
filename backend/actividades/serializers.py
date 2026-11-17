from rest_framework import serializers

from .models import Actividad


class ActividadSerializer(serializers.ModelSerializer):
    class Meta:
        model = Actividad
        fields = ('id', 'titulo', 'curso', 'tipo', 'fecha_entrega', 'estado')
