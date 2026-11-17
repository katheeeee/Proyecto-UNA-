from datetime import timedelta

from django.utils import timezone
from rest_framework.generics import ListAPIView

from .models import Actividad
from .serializers import ActividadSerializer


class ActividadListView(ListAPIView):
    serializer_class = ActividadSerializer

    def get_queryset(self):
        queryset = Actividad.objects.filter(usuario=self.request.user)
        estado = self.request.query_params.get('estado')
        if estado:
            queryset = queryset.filter(estado=estado)
        if estado == Actividad.ESTADO_PENDIENTE:
            hoy = timezone.localdate()
            queryset = queryset.filter(
                fecha_entrega__date__gte=hoy,
                fecha_entrega__date__lte=hoy + timedelta(days=7),
            )
        return queryset.order_by('fecha_entrega')
