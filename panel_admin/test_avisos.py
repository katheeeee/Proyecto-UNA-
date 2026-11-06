import pytest

from avisos import Aviso, AvisoRepository, AvisoService
from servicios import crear_servicios_piloto

MENSAJE = "La ruta 2 no tendra servicio hoy por mantenimiento."


@pytest.fixture
def repo():
    return AvisoRepository()


@pytest.fixture
def servicio_avisos(repo):
    return AvisoService(repo, crear_servicios_piloto())


def test_caso_valido(servicio_avisos, repo):
    aviso = servicio_avisos.registrar_aviso("Suspension de ruta 2", MENSAJE, "transporte")
    assert isinstance(aviso, Aviso)
    assert aviso.servicio == "transporte"
    assert repo.listar() == [aviso]


def test_caso_rechazado_servicio_inactivo(servicio_avisos, repo):
    with pytest.raises(ValueError, match="no existe o no esta activo"):
        servicio_avisos.registrar_aviso("Horario de atencion", MENSAJE, "servicio medico")
    assert repo.listar() == []


# ---- pruebas adicionales de validacion ----
def test_titulo_vacio(servicio_avisos, repo):
    with pytest.raises(ValueError, match="titulo no puede estar vacio"):
        servicio_avisos.registrar_aviso("   ", MENSAJE, "comedor")
    assert repo.listar() == []


def test_titulo_limite_80_y_81(servicio_avisos):
    servicio_avisos.registrar_aviso("a" * 80, MENSAJE, "comedor")
    with pytest.raises(ValueError, match="80 caracteres"):
        servicio_avisos.registrar_aviso("a" * 81, MENSAJE, "comedor")


def test_mensaje_limite_10_y_9(servicio_avisos):
    servicio_avisos.registrar_aviso("Titulo", "x" * 10, "comedor")
    with pytest.raises(ValueError, match="al menos 10"):
        servicio_avisos.registrar_aviso("Titulo", "x" * 9, "comedor")


def test_servicio_inexistente(servicio_avisos):
    with pytest.raises(ValueError, match="no existe o no esta activo"):
        servicio_avisos.registrar_aviso("Titulo", MENSAJE, "biblioteca")


def test_servicio_se_normaliza(servicio_avisos):
    aviso = servicio_avisos.registrar_aviso("Titulo", MENSAJE, "  COMEDOR ")
    assert aviso.servicio == "comedor"


def test_dato_que_no_es_texto(servicio_avisos):
    with pytest.raises(ValueError, match="deben ser texto"):
        servicio_avisos.registrar_aviso("Titulo", MENSAJE, None)


# ---- bajo acoplamiento: AvisoService solo usa verificar_servicio_activo() ----
class ServicioFalso:
    def verificar_servicio_activo(self, nombre):
        return True


def test_funciona_con_cualquier_proveedor_del_servicio(repo):
    servicio_avisos = AvisoService(repo, ServicioFalso())
    aviso = servicio_avisos.registrar_aviso("Titulo", MENSAJE, "lo-que-sea")
    assert aviso in repo.listar()