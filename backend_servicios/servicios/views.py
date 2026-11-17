from rest_framework import generics
from rest_framework.permissions import AllowAny, IsAdminUser

from .models import Servicio
from .serializers import ServicioSerializer


class ServicioListView(generics.ListAPIView):
    queryset = Servicio.objects.filter(estado=True)
    serializer_class = ServicioSerializer
    permission_classes = [AllowAny]


class ServicioDetailView(generics.RetrieveUpdateAPIView):
    queryset = Servicio.objects.all()
    serializer_class = ServicioSerializer

    def get_permissions(self):
        if self.request.method in ['PUT', 'PATCH']:
            return [IsAdminUser()]

        return [AllowAny()]