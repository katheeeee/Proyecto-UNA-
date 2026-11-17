from datetime import timedelta

from django.contrib.auth import get_user_model
from django.urls import reverse
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework_simplejwt.tokens import RefreshToken

from actividades.models import Actividad

UsuarioModel = get_user_model()


class AutenticacionTests(APITestCase):
    def test_registro_correcto(self):
        respuesta = self.client.post(
            reverse('registro'),
            {
                'nombre_completo': 'Benedicta Callo',
                'correo': 'nueva@una.edu.pe',
                'escuela_profesional': 'Ingeniería de Sistemas',
                'password': '12345678',
            },
            format='json',
        )
        self.assertEqual(respuesta.status_code, status.HTTP_201_CREATED)
        self.assertEqual(respuesta.data['correo'], 'nueva@una.edu.pe')
        self.assertTrue(UsuarioModel.objects.filter(email='nueva@una.edu.pe').exists())

    def test_registro_rechaza_correo_duplicado(self):
        UsuarioModel.objects.create_user(
            username='existe@una.edu.pe',
            email='existe@una.edu.pe',
            password='12345678',
            nombre_completo='Usuario Existente',
        )
        respuesta = self.client.post(
            reverse('registro'),
            {
                'nombre_completo': 'Otro Usuario',
                'correo': 'existe@una.edu.pe',
                'escuela_profesional': 'Sistemas',
                'password': '12345678',
            },
            format='json',
        )
        self.assertEqual(respuesta.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('correo', respuesta.data)

    def test_registro_rechaza_contrasena_corta(self):
        respuesta = self.client.post(
            reverse('registro'),
            {
                'nombre_completo': 'Usuario Prueba',
                'correo': 'corta@una.edu.pe',
                'escuela_profesional': 'Sistemas',
                'password': '123',
            },
            format='json',
        )
        self.assertEqual(respuesta.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('password', respuesta.data)

    def test_login_correcto_devuelve_token_y_usuario(self):
        UsuarioModel.objects.create_user(
            username='login@una.edu.pe',
            email='login@una.edu.pe',
            password='12345678',
            nombre_completo='Usuario Login',
            escuela_profesional='Sistemas',
        )
        respuesta = self.client.post(
            reverse('login'),
            {'correo': 'login@una.edu.pe', 'password': '12345678'},
            format='json',
        )
        self.assertEqual(respuesta.status_code, status.HTTP_200_OK)
        self.assertIn('token', respuesta.data)
        self.assertIn('refresh', respuesta.data)
        self.assertEqual(respuesta.data['usuario']['correo'], 'login@una.edu.pe')

    def test_login_incorrecto(self):
        respuesta = self.client.post(
            reverse('login'),
            {'correo': 'nadie@una.edu.pe', 'password': 'incorrecta'},
            format='json',
        )
        self.assertEqual(respuesta.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(respuesta.data['detail'], 'Correo o contraseña incorrectos.')

    def test_refresh_de_token(self):
        usuario = UsuarioModel.objects.create_user(
            username='refresh@una.edu.pe',
            email='refresh@una.edu.pe',
            password='12345678',
            nombre_completo='Usuario Refresh',
        )
        refresh = RefreshToken.for_user(usuario)
        respuesta = self.client.post(
            reverse('token-refresh'), {'refresh': str(refresh)}, format='json'
        )
        self.assertEqual(respuesta.status_code, status.HTTP_200_OK)
        self.assertIn('access', respuesta.data)


class PerfilTests(APITestCase):
    def setUp(self):
        self.usuario = UsuarioModel.objects.create_user(
            username='perfil@una.edu.pe',
            email='perfil@una.edu.pe',
            password='12345678',
            nombre_completo='Perfil Original',
            escuela_profesional='Sistemas',
        )
        self.client.credentials(
            HTTP_AUTHORIZATION=f'Bearer {RefreshToken.for_user(self.usuario).access_token}'
        )

    def test_perfil_requiere_autenticacion(self):
        self.client.credentials()
        respuesta = self.client.get(reverse('perfil'))
        self.assertEqual(respuesta.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_obtener_y_actualizar_perfil(self):
        respuesta = self.client.get(reverse('perfil'))
        self.assertEqual(respuesta.status_code, status.HTTP_200_OK)
        self.assertEqual(respuesta.data['nombre_completo'], 'Perfil Original')

        respuesta = self.client.put(
            reverse('perfil'),
            {
                'nombre_completo': 'Perfil Actualizado',
                'escuela_profesional': 'Ciencia de Datos',
            },
            format='json',
        )
        self.assertEqual(respuesta.status_code, status.HTTP_200_OK)
        self.usuario.refresh_from_db()
        self.assertEqual(self.usuario.nombre_completo, 'Perfil Actualizado')


class ActividadesTests(APITestCase):
    def test_listado_solo_del_usuario_y_filtrado(self):
        usuario = UsuarioModel.objects.create_user(
            username='actividades@una.edu.pe',
            email='actividades@una.edu.pe',
            password='12345678',
            nombre_completo='Usuario Actividades',
        )
        otro = UsuarioModel.objects.create_user(
            username='otro@una.edu.pe',
            email='otro@una.edu.pe',
            password='12345678',
            nombre_completo='Otro Usuario',
        )
        Actividad.objects.create(
            usuario=usuario,
            titulo='Tarea dentro del rango',
            curso='Curso',
            fecha_entrega=timezone.now() + timedelta(days=2),
        )
        Actividad.objects.create(
            usuario=otro,
            titulo='Tarea ajena',
            curso='Curso',
            fecha_entrega=timezone.now() + timedelta(days=2),
        )
        self.client.credentials(
            HTTP_AUTHORIZATION=f'Bearer {RefreshToken.for_user(usuario).access_token}'
        )
        respuesta = self.client.get(reverse('actividades') + '?estado=pendiente')
        self.assertEqual(respuesta.status_code, status.HTTP_200_OK)
        self.assertEqual(len(respuesta.data), 1)
        self.assertEqual(respuesta.data[0]['titulo'], 'Tarea dentro del rango')
