from django.urls import path

from .views import AvisoListCreateView

urlpatterns = [
    path("avisos/", AvisoListCreateView.as_view(), name="avisos"),
]
