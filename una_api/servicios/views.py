from rest_framework import mixins, viewsets

from .models import Servicio
from .serializers import ServicioSerializer


class ServicioViewSet(
    mixins.ListModelMixin,
    mixins.CreateModelMixin,
    mixins.UpdateModelMixin,
    viewsets.GenericViewSet,
):
    """Listar, crear y activar/desactivar servicios desde el panel de administracion."""

    queryset = Servicio.objects.all().order_by("id")
    serializer_class = ServicioSerializer
