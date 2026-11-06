
import pytest
from datetime import timedelta
from django.utils import timezone

from actividades.models import Actividad
from actividades.services import ActividadService, DatosInvalidos


@pytest.fixture
def servicio():
    return ActividadService()


@pytest.fixture
def datos_validos():
    return {
        "estudiante_id": 7,
        "titulo": "Informe de laboratorio 3",
        "curso": "Ingeniería de Software",
        "tipo": "tarea",
        "fecha_entrega": timezone.now() + timedelta(days=5),
        "descripcion": "Desarrollar el informe de laboratorio.",
    }


@pytest.mark.django_db
def test_registrar_actividad_correctamente(servicio, datos_validos):
    resultado = servicio.registrar_actividad(datos_validos)

    assert resultado["actividad"].id is not None
    assert resultado["actividad"].titulo == "Informe de laboratorio 3"
    assert resultado["recordatorios_programados"] is False
    assert Actividad.objects.count() == 1


@pytest.mark.django_db
def test_rechazar_titulo_vacio(servicio, datos_validos):
    datos_validos["titulo"] = ""

    with pytest.raises(DatosInvalidos) as error:
        servicio.registrar_actividad(datos_validos)

    assert "titulo" in error.value.errores
    assert Actividad.objects.count() == 0


@pytest.mark.django_db
def test_rechazar_fecha_pasada(servicio, datos_validos):
    datos_validos["fecha_entrega"] = timezone.now() - timedelta(days=1)

    with pytest.raises(DatosInvalidos) as error:
        servicio.registrar_actividad(datos_validos)

    assert "fecha_entrega" in error.value.errores
    assert Actividad.objects.count() == 0


@pytest.mark.django_db
def test_rechazar_tipo_invalido(servicio, datos_validos):
    datos_validos["tipo"] = "examen"

    with pytest.raises(DatosInvalidos) as error:
        servicio.registrar_actividad(datos_validos)

    assert "tipo" in error.value.errores
    assert Actividad.objects.count() == 0


@pytest.mark.django_db
def test_rechazar_titulo_mayor_a_150_caracteres(servicio, datos_validos):
    datos_validos["titulo"] = "A" * 151

    with pytest.raises(DatosInvalidos) as error:
        servicio.registrar_actividad(datos_validos)

    assert "titulo" in error.value.errores
    assert Actividad.objects.count() == 0


@pytest.mark.django_db
def test_fallo_de_recordatorios_no_impide_registro(datos_validos):

    class RecordatoriosFallidos:
        def programar_recordatorios(self, **kwargs):
            raise Exception("Error al programar recordatorios")

    servicio = ActividadService(
        servicio_recordatorios=RecordatoriosFallidos()
    )

    resultado = servicio.registrar_actividad(datos_validos)

    assert resultado["actividad"].id is not None
    assert resultado["recordatorios_programados"] is False
    assert Actividad.objects.count() == 1
