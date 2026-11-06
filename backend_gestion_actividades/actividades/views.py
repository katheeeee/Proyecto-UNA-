
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from .serializers import (
    ActividadRegistroSerializer,
    ActividadDetalleSerializer
)
from .services import ActividadService, DatosInvalidos


class ActividadRegistroView(APIView):

    def post(self, request):
        serializer = ActividadRegistroSerializer(data=request.data)

        if not serializer.is_valid():
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )

        servicio = ActividadService()

        try:
            resultado = servicio.registrar_actividad(
                serializer.validated_data
            )

            return Response({
                "mensaje": "Actividad registrada correctamente",
                "actividad": ActividadDetalleSerializer(
                    resultado["actividad"]
                ).data,
                "recordatorios_programados": resultado[
                    "recordatorios_programados"
                ]
            }, status=status.HTTP_201_CREATED)

        except DatosInvalidos as error:
            return Response(
                error.errores,
                status=status.HTTP_400_BAD_REQUEST
            )
