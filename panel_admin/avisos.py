"""
UNA+ - Panel de administracion web
Funcionalidad: Registrar un aviso institucional
Autor: Mendoza Coila Jamiel Romario
"""

from datetime import datetime

SERVICIOS_PERMITIDOS = ["transporte", "comedor", "servicio medico"]
MAX_TITULO = 80
MIN_MENSAJE = 10


class Aviso:
    """Representa un aviso institucional que ve el estudiante."""

    def __init__(self, titulo, mensaje, servicio):
        self.titulo = titulo
        self.mensaje = mensaje
        self.servicio = servicio
        self.fecha_actualizacion = datetime.now().strftime("%d/%m/%Y %H:%M")


def validar_aviso(titulo, mensaje, servicio):
    """Revisa los datos. Si algo esta mal, lanza ValueError con el motivo."""
    if titulo.strip() == "":
        raise ValueError("El titulo no puede estar vacio.")
    if len(titulo.strip()) > MAX_TITULO:
        raise ValueError("El titulo no puede pasar de 80 caracteres.")
    if len(mensaje.strip()) < MIN_MENSAJE:
        raise ValueError("El mensaje debe tener al menos 10 caracteres.")
    if servicio.strip().lower() not in SERVICIOS_PERMITIDOS:
        raise ValueError(
            "Servicio no valido. Opciones: " + ", ".join(SERVICIOS_PERMITIDOS) + "."
        )


def registrar_aviso(titulo, mensaje, servicio, lista_avisos):
    """Valida los datos, crea el aviso y lo guarda en la lista."""
    validar_aviso(titulo, mensaje, servicio)
    aviso = Aviso(titulo.strip(), mensaje.strip(), servicio.strip().lower())
    lista_avisos.append(aviso)
    return aviso


def main():
    avisos = []
    print("=== UNA+ | Panel de administracion | Registrar aviso ===")
    print("Servicios: " + ", ".join(SERVICIOS_PERMITIDOS))

    titulo = input("Titulo del aviso: ")
    mensaje = input("Mensaje: ")
    servicio = input("Servicio: ")

    try:
        aviso = registrar_aviso(titulo, mensaje, servicio, avisos)
        print("Aviso registrado correctamente.")
        print("Servicio: " + aviso.servicio)
        print("Titulo: " + aviso.titulo)
        print("Ultima actualizacion: " + aviso.fecha_actualizacion)
    except ValueError as error:
        print("Error: " + str(error))


if __name__ == "__main__":
    main()
