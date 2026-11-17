"""Pruebas de integracion: Gestion de Avisos <-> Gestion de Servicios (via API)."""
import pytest
from rest_framework.test import APIClient

from avisos.models import Aviso
from servicios.models import Servicio

MENSAJE = "La ruta 2 no tendra servicio hoy por mantenimiento."


@pytest.fixture
def api():
    return APIClient()


@pytest.fixture
def servicios(db):
    Servicio.objects.create(nombre="transporte", activo=True)
    Servicio.objects.create(nombre="comedor", activo=True)
    return Servicio.objects.create(nombre="servicio medico", activo=False)


def registrar(api, titulo, mensaje, servicio):
    return api.post("/api/avisos/",
                    {"titulo": titulo, "mensaje": mensaje, "servicio": servicio}, format="json")


# ---- las dos pruebas exigidas por la practica ----
def test_integracion_funcionamiento_esperado(api, servicios):
    r = registrar(api, "Suspension de ruta 2", MENSAJE, "transporte")
    assert r.status_code == 201
    assert r.data["mensaje"] == "Aviso registrado correctamente."
    assert r.data["aviso"]["servicio"] == "transporte"
    aviso = Aviso.objects.get()
    assert aviso.servicio.nombre == "transporte"      # quedo guardado y enlazado


def test_integracion_rechazo_servicio_inactivo(api, servicios):
    r = registrar(api, "Horario de atencion", MENSAJE, "servicio medico")
    assert r.status_code == 400
    assert r.data["error"] == "El servicio no existe o no esta activo."
    assert Aviso.objects.count() == 0                  # no se guardo nada


# ---- pruebas adicionales ----
def test_servicio_inexistente(api, servicios):
    assert registrar(api, "Titulo", MENSAJE, "biblioteca").status_code == 400


def test_titulo_vacio(api, servicios):
    r = registrar(api, "   ", MENSAJE, "comedor")
    assert r.status_code == 400 and "vacio" in r.data["error"]
    assert Aviso.objects.count() == 0


def test_limites_titulo_y_mensaje(api, servicios):
    assert registrar(api, "a" * 80, MENSAJE, "comedor").status_code == 201
    assert registrar(api, "a" * 81, MENSAJE, "comedor").status_code == 400
    assert registrar(api, "Titulo", "x" * 10, "comedor").status_code == 201
    assert registrar(api, "Titulo", "x" * 9, "comedor").status_code == 400


def test_faltan_datos(api, servicios):
    r = api.post("/api/avisos/", {"titulo": "Solo titulo"}, format="json")
    assert r.status_code == 400


def test_activar_servicio_permite_registrar(api, servicios):
    """Integracion en dos sentidos: al activar el servicio medico, ya se acepta el aviso."""
    assert registrar(api, "Atencion", MENSAJE, "servicio medico").status_code == 400
    r = api.patch(f"/api/servicios/{servicios.id}/", {"activo": True}, format="json")
    assert r.status_code == 200
    assert registrar(api, "Atencion", MENSAJE, "servicio medico").status_code == 201


def test_listar_avisos_por_servicio(api, servicios):
    registrar(api, "Aviso transporte", MENSAJE, "transporte")
    registrar(api, "Aviso comedor", MENSAJE, "comedor")
    r = api.get("/api/avisos/", {"servicio": "comedor"})
    assert r.status_code == 200
    assert [a["titulo"] for a in r.data] == ["Aviso comedor"]
