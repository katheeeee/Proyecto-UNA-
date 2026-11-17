from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Aviso
from .serializers import AvisoEntradaSerializer, AvisoSerializer
from .services import AvisoService


class AvisoListCreateView(APIView):
    """GET: lista avisos (?servicio=nombre). POST: registra un aviso."""

    def get(self, request):
        avisos = Aviso.objects.select_related("servicio").order_by("-id")
        nombre = request.query_params.get("servicio")
        if nombre:
            avisos = avisos.filter(servicio__nombre=nombre.strip().lower())
        return Response(AvisoSerializer(avisos, many=True).data)

    def post(self, request):
        entrada = AvisoEntradaSerializer(data=request.data)
        if not entrada.is_valid():
            return Response({"error": "Faltan datos: titulo, mensaje y servicio."},
                            status=status.HTTP_400_BAD_REQUEST)
        try:
            aviso = AvisoService.registrar_aviso(**entrada.validated_data)
        except ValueError as error:
            return Response({"error": str(error)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(
            {"mensaje": "Aviso registrado correctamente.", "aviso": AvisoSerializer(aviso).data},
            status=status.HTTP_201_CREATED,
        )
