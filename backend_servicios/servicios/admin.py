from django.contrib import admin
from .models import Servicio

@admin.register(Servicio)
class ServicioAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'categoria', 'estado', 'fecha_actualizacion')
    list_filter = ('categoria', 'estado')
    search_fields = ('nombre', 'descripcion')