from django.urls import path

from .views import ActividadListView

urlpatterns = [
    path('actividades/', ActividadListView.as_view(), name='actividades'),
]
