from django.contrib.auth import authenticate
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import (
    LoginSerializer,
    PerfilActualizarSerializer,
    RegistroSerializer,
    UsuarioSerializer,
)


class RegistroView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializador = RegistroSerializer(data=request.data)
        serializador.is_valid(raise_exception=True)
        usuario = serializador.save()
        return Response(UsuarioSerializer(usuario).data, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializador = LoginSerializer(data=request.data)
        serializador.is_valid(raise_exception=True)
        correo = serializador.validated_data['correo'].strip().lower()
        password = serializador.validated_data['password']

        usuario = authenticate(request, username=correo, password=password)
        if usuario is None:
            return Response(
                {'detail': 'Correo o contraseña incorrectos.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        refresh = RefreshToken.for_user(usuario)
        return Response(
            {
                'token': str(refresh.access_token),
                'refresh': str(refresh),
                'usuario': UsuarioSerializer(usuario).data,
            },
            status=status.HTTP_200_OK,
        )


class PerfilView(APIView):
    def get(self, request):
        return Response(UsuarioSerializer(request.user).data)

    def put(self, request):
        serializador = PerfilActualizarSerializer(request.user, data=request.data)
        serializador.is_valid(raise_exception=True)
        usuario = serializador.save()
        return Response(UsuarioSerializer(usuario).data)
