from django.urls import path
from .views import ServicioListView, ServicioDetailView

urlpatterns = [
    path('', ServicioListView.as_view(), name='servicios-lista'),
    path('<int:pk>/', ServicioDetailView.as_view(), name='servicio-detalle'),
]