
from rest_framework import serializers
from .models import Actividad


class ActividadRegistroSerializer(serializers.Serializer):
    estudiante_id = serializers.IntegerField(min_value=1)
    titulo = serializers.CharField(max_length=150)
    curso = serializers.CharField(max_length=100)
    tipo = serializers.ChoiceField(
        choices=["tarea", "evaluacion", "actividad"]
    )
    fecha_entrega = serializers.DateTimeField()
    descripcion = serializers.CharField(
        required=False,
        allow_blank=True,
        default=""
    )


class ActividadDetalleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Actividad
        fields = "__all__"
