from rest_framework import serializers

from .models import Servicio


class ServicioSerializer(serializers.ModelSerializer):
    nombre = serializers.CharField(max_length=50)

    class Meta:
        model = Servicio
        fields = ["id", "nombre", "activo"]

    def validate_nombre(self, valor):
        """Guarda el nombre normalizado (minusculas, sin espacios sobrantes) y evita repetidos."""
        nombre = valor.strip().lower()
        repetidos = Servicio.objects.filter(nombre=nombre)
        if self.instance is not None:
            repetidos = repetidos.exclude(pk=self.instance.pk)
        if repetidos.exists():
            raise serializers.ValidationError("Ya existe un servicio con ese nombre.")
        return nombre