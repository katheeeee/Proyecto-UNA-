"""
UNA+ - Configuracion minima del proyecto (API + panel de administracion).
Por defecto usa SQLite para poder ejecutarse sin instalar nada mas.
"""
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = "una-plus-clave-solo-para-desarrollo"
DEBUG = True
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "testserver"]

INSTALLED_APPS = [
    "django.contrib.contenttypes",
    "django.contrib.auth",
    "django.contrib.staticfiles",
    "rest_framework",
    "servicios",   # componente Gestion de Servicios
    "avisos",      # componente Gestion de Avisos
]

MIDDLEWARE = [
    "django.middleware.common.CommonMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "APP_DIRS": True,
        "OPTIONS": {"context_processors": ["django.template.context_processors.request"]},
    }
]

# --- Base de datos ---------------------------------------------------------
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": BASE_DIR / "db.sqlite3",
    }
}
# Para usar MySQL (requiere: pip install mysqlclient), reemplazar por:
# DATABASES = {
#     "default": {
#         "ENGINE": "django.db.backends.mysql",
#         "NAME": "una_plus",
#         "USER": "root",
#         "PASSWORD": "tu_clave",
#         "HOST": "127.0.0.1",
#         "PORT": "3306",
#     }
# }

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
LANGUAGE_CODE = "es"
TIME_ZONE = "America/Lima"
USE_TZ = True
STATIC_URL = "static/"

REST_FRAMEWORK = {
    # Pendiente (Sprint 1): exigir autenticacion de administrador en el panel.
    "DEFAULT_PERMISSION_CLASSES": ["rest_framework.permissions.AllowAny"],
    "DEFAULT_AUTHENTICATION_CLASSES": [],
}
