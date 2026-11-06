"""
UNA+ - Panel de administracion web | Componente: Gestion de Avisos
Funcionalidad : Registrar un aviso institucional (RF-05)
Autor         : Mendoza Coila Jamiel Romario
"""

from datetime import datetime

from servicios import crear_servicios_piloto

MAX_TITULO = 80
MIN_MENSAJE = 10


class Aviso:
    """Aviso institucional que ve el estudiante."""

    def __init__(self, titulo, mensaje, servicio):
        self.titulo = titulo
        self.mensaje = mensaje
        self.servicio = servicio
        self.fecha_actualizacion = datetime.now()

    def fecha_formateada(self):
        return self.fecha_actualizacion.strftime("%d/%m/%Y %H:%M")


class AvisoRepository:
    """Guarda y lista avisos (en el proyecto sera la base de datos MySQL)."""

    def __init__(self):
        self._avisos = []

    def guardar(self, aviso):
        self._avisos.append(aviso)

    def listar(self):
        return list(self._avisos)


class AvisoService:
    """Logica de Gestion de Avisos. Pide a Gestion de Servicios que verifique el servicio."""

    def __init__(self, repositorio, servicio_service):
        self._repositorio = repositorio
        self._servicio_service = servicio_service

    def validar_aviso(self, titulo, mensaje, servicio):
        """Valida el formato de los datos. Lanza ValueError con el motivo."""
        if not all(isinstance(dato, str) for dato in (titulo, mensaje, servicio)):
            raise ValueError("Los datos del aviso deben ser texto.")
        if titulo.strip() == "":
            raise ValueError("El titulo no puede estar vacio.")
        if len(titulo.strip()) > MAX_TITULO:
            raise ValueError("El titulo no puede pasar de 80 caracteres.")
        if len(mensaje.strip()) < MIN_MENSAJE:
            raise ValueError("El mensaje debe tener al menos 10 caracteres.")

    def registrar_aviso(self, titulo, mensaje, servicio):
        """Valida, verifica el servicio, crea el aviso y lo guarda."""
        self.validar_aviso(titulo, mensaje, servicio)
        if not self._servicio_service.verificar_servicio_activo(servicio):
            raise ValueError("El servicio no existe o no esta activo.")
        aviso = Aviso(titulo.strip(), mensaje.strip(), servicio.strip().lower())
        self._repositorio.guardar(aviso)
        return aviso


def main():
    servicio_avisos = AvisoService(AvisoRepository(), crear_servicios_piloto())
    print("=== UNA+ | Panel de administracion | Registrar aviso ===")
    print("Servicios: transporte, comedor, servicio medico")

    titulo = input("Titulo del aviso: ")
    mensaje = input("Mensaje: ")
    servicio = input("Servicio: ")

    try:
        aviso = servicio_avisos.registrar_aviso(titulo, mensaje, servicio)
        print("Aviso registrado correctamente.")
        print("Servicio: " + aviso.servicio)
        print("Titulo: " + aviso.titulo)
        print("Ultima actualizacion: " + aviso.fecha_formateada())
    except ValueError as error:
        print("Error: " + str(error))


if __name__ == "__main__":
    main()