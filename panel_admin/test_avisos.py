import pytest
from avisos import registrar_aviso


def test_caso_valido():
    lista = []
    aviso = registrar_aviso(
        "Suspension de ruta 2",
        "La ruta 2 no tendra servicio hoy por mantenimiento.",
        "transporte",
        lista,
    )
    assert aviso.titulo == "Suspension de ruta 2"
    assert aviso.servicio == "transporte"
    assert len(lista) == 1


def test_caso_invalido_titulo_vacio():
    lista = []
    with pytest.raises(ValueError) as error:
        registrar_aviso("", "Mensaje de prueba largo.", "comedor", lista)
    assert "titulo" in str(error.value).lower()
    assert len(lista) == 0
