from django.core.management.base import BaseCommand

from servicios.models import Servicio

PILOTO = [("transporte", True), ("comedor", True), ("servicio medico", False)]


class Command(BaseCommand):
    help = "Carga los servicios iniciales (el servicio medico queda inactivo)."

    def handle(self, *args, **options):
        for nombre, activo in PILOTO:
            Servicio.objects.update_or_create(nombre=nombre, defaults={"activo": activo})
        self.stdout.write(self.style.SUCCESS("Servicios piloto cargados."))
