
from datetime import datetime, timezone as dt_timezone
from django.utils import timezone

from .repositories import ActividadRepository


TIPOS_VALIDOS = ("tarea", "evaluacion", "actividad")

CAMPOS_OBLIGATORIOS = (
    "estudiante_id",
    "titulo",
    "curso",
    "tipo",
    "fecha_entrega",
)


class DatosInvalidos(Exception):
    def __init__(self, errores):
        super().__init__("Datos de la actividad inválidos")
        self.errores = errores


class ActividadService:

    def __init__(self, repositorio=None, servicio_recordatorios=None):
        self.repositorio = repositorio or ActividadRepository()
        self.recordatorios = servicio_recordatorios

    def validar_datos(self, datos):
        errores = {}

        for campo in CAMPOS_OBLIGATORIOS:
            valor = datos.get(campo)

            if valor is None or (
                isinstance(valor, str) and not valor.strip()
            ):
                errores[campo] = "Este campo es obligatorio."

        titulo = datos.get("titulo")

        if "titulo" not in errores and len(titulo.strip()) > 150:
            errores["titulo"] = "El título no puede pasar de 150 caracteres."

        tipo = datos.get("tipo")

        if "tipo" not in errores and tipo not in TIPOS_VALIDOS:
            errores["tipo"] = "El tipo debe ser tarea, evaluacion o actividad."

        fecha = datos.get("fecha_entrega")

        if "fecha_entrega" not in errores:
            if not isinstance(fecha, datetime):
                errores["fecha_entrega"] = "La fecha de entrega no es válida."
            else:
                if timezone.is_naive(fecha):
                    fecha = timezone.make_aware(fecha)

                if fecha <= timezone.now():
                    errores["fecha_entrega"] = "La fecha de entrega debe ser futura."

        return errores

    def registrar_actividad(self, datos):
        errores = self.validar_datos(datos)

        if errores:
            raise DatosInvalidos(errores)

        datos_guardar = {
            "estudiante_id": datos["estudiante_id"],
            "titulo": datos["titulo"].strip(),
            "curso": datos["curso"].strip(),
            "tipo": datos["tipo"],
            "fecha_entrega": datos["fecha_entrega"],
            "descripcion": (datos.get("descripcion") or "").strip(),
        }

        actividad = self.repositorio.guardar(datos_guardar)

        programados = False

        if self.recordatorios:
            try:
                programados = self.recordatorios.programar_recordatorios(
                    actividad_id=actividad.id,
                    estudiante_id=datos["estudiante_id"],
                    tipo=datos["tipo"],
                    fecha_entrega=datos["fecha_entrega"],
                )
            except Exception:
                programados = False

        return {
            "actividad": actividad,
            "recordatorios_programados": bool(programados),
        }
