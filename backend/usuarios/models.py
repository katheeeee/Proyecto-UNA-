from django.contrib.auth.models import AbstractUser
from django.db import models


class Usuario(AbstractUser):
    email = models.EmailField('correo institucional', unique=True)
    nombre_completo = models.CharField('nombre completo', max_length=150)
    escuela_profesional = models.CharField(
        'escuela profesional', max_length=150, blank=True
    )

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['nombre_completo', 'escuela_profesional']

    class Meta:
        verbose_name = 'usuario'
        verbose_name_plural = 'usuarios'

    def __str__(self):
        return self.email
