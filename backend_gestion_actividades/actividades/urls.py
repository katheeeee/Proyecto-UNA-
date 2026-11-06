
from django.urls import path
from .views import ActividadRegistroView

urlpatterns = [
    path(
        "actividades/",
        ActividadRegistroView.as_view(),
        name="registrar_actividad"
    ),
]
