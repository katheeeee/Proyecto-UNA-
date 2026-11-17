from datetime import datetime, time, timedelta

from django.core.management.base import BaseCommand
from django.utils import timezone

from actividades.models import Actividad
from usuarios.models import Usuario


class Command(BaseCommand):
    help = 'Crea el estudiante de prueba y sus actividades pendientes.'

    def handle(self, *args, **opciones):
        correo = 'estudiante@una.edu.pe'
        usuario, creado = Usuario.objects.get_or_create(
            email=correo,
            defaults={
                'username': correo,
                'nombre_completo': 'Ana Quispe Mamani',
                'escuela_profesional': 'Ingeniería de Sistemas',
            },
        )
        usuario.set_password('12345678')
        usuario.save()

        hoy = timezone.localdate()
        base = datetime.combine(hoy, time.min)
        datos = [
            ('Resolver ejercicios de límites', 'Cálculo Diferencial', 'tarea', 0, 23, 59),
            ('Examen parcial de cinemática', 'Física I', 'evaluacion', 1, 8, 0),
            ('Avance del trabajo grupal', 'Estadística Aplicada', 'trabajo_grupal', 2, 14, 0),
            ('Entrega del proyecto final', 'Programación Web', 'proyecto', 4, 18, 0),
            ('Informe de laboratorio', 'Química General', 'tarea', 6, 10, 0),
            ('Evaluación de comprensión', 'Inglés Técnico', 'evaluacion', 9, 16, 0),
        ]
        for titulo, curso, tipo, dias, hora, minuto in datos:
            fecha = timezone.make_aware(
                base + timedelta(days=dias, hours=hora, minutes=minuto)
            )
            Actividad.objects.get_or_create(
                usuario=usuario,
                titulo=titulo,
                defaults={
                    'curso': curso,
                    'tipo': tipo,
                    'fecha_entrega': fecha,
                    'estado': Actividad.ESTADO_PENDIENTE,
                },
            )

        self.stdout.write(
            self.style.SUCCESS(
                f'Datos listos: {correo} / 12345678 '
                f'({Actividad.objects.filter(usuario=usuario).count()} actividades)'
            )
        )
