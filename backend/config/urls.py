from django.contrib import admin
from django.urls import include, path

from usuarios.views import PerfilView

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/v1/auth/', include('usuarios.urls')),
    path('api/v1/perfil/', PerfilView.as_view(), name='perfil'),
    path('api/v1/', include('actividades.urls')),
]
