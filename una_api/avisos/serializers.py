from rest_framework import serializers

from .models import Aviso


class AvisoEntradaSerializer(serializers.Serializer):
    """Solo comprueba que lleguen los tres campos; las reglas estan en AvisoService."""

    titulo = serializers.CharField(allow_blank=True)
    mensaje = serializers.CharField(allow_blank=True)
    servicio = serializers.CharField(allow_blank=True)


class AvisoSerializer(serializers.ModelSerializer):
    servicio = serializers.CharField(source="servicio.nombre", read_only=True)
    fecha_actualizacion = serializers.DateTimeField(format="%d/%m/%Y %H:%M", read_only=True)

    class Meta:
        model = Aviso
        fields = ["id", "titulo", "mensaje", "servicio", "fecha_actualizacion"]
