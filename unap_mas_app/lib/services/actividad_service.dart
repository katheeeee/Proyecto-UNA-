import '../models/actividad.dart';
export '../models/actividad.dart';

/// Error de validación con un mensaje apto para mostrar al usuario.
class ValidacionException implements Exception {
  final String mensaje;
  ValidacionException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Presentación de la fecha: 2026-12-15 -> 15/12/2026.
String formatearFechaLatina(DateTime fecha) {
  final dia = fecha.day.toString().padLeft(2, '0');
  final mes = fecha.month.toString().padLeft(2, '0');
  return '$dia/$mes/${fecha.year}';
}

/// Lógica y validaciones del registro de actividades.
class ActividadService {
  static const int longitudMaxTitulo = 100;
  static const List<String> tiposValidos = [
    'tarea',
    'examen',
    'proyecto',
    'trabajo grupal',
  ];

  /// Valida y procesa los datos. Lanza [ValidacionException] si algo falla.
  /// El parámetro [hoy] permite fijar la fecha de referencia en las pruebas.
  Actividad registrarActividad({
    required String? titulo,
    required String? tipo,
    required String? curso,
    required String? fechaEntrega,
    DateTime? hoy,
  }) {
    final ahora = hoy ?? DateTime.now();
    final fechaHoy = DateTime(ahora.year, ahora.month, ahora.day);

    final tituloLimpio = (titulo ?? '').trim();
    if (tituloLimpio.isEmpty) {
      throw ValidacionException('El título es obligatorio.');
    }
    if (tituloLimpio.length > longitudMaxTitulo) {
      throw ValidacionException(
        'El título no puede superar $longitudMaxTitulo caracteres.',
      );
    }

    final tipoLimpio = (tipo ?? '').trim().toLowerCase();
    if (!tiposValidos.contains(tipoLimpio)) {
      throw ValidacionException(
        'El tipo debe ser uno de: ${tiposValidos.join(', ')}.',
      );
    }

    final cursoLimpio = (curso ?? '').trim();
    if (cursoLimpio.isEmpty) {
      throw ValidacionException('El curso es obligatorio.');
    }

    final fecha = _convertirFecha(fechaEntrega);
    if (fecha.isBefore(fechaHoy)) {
      throw ValidacionException(
        'La fecha de entrega no puede estar en el pasado.',
      );
    }

    return Actividad(
      titulo: tituloLimpio,
      tipo: tipoLimpio,
      curso: cursoLimpio,
      fechaEntrega: fecha,
    );
  }

  /// Convierte "AAAA-MM-DD" a DateTime, rechazando formatos incorrectos
  /// y fechas inexistentes (por ejemplo, 31 de febrero).
  DateTime _convertirFecha(String? texto) {
    final valor = (texto ?? '').trim();
    final formato = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final m = formato.firstMatch(valor);
    if (m == null) {
      throw ValidacionException('La fecha debe tener el formato AAAA-MM-DD.');
    }
    final anio = int.parse(m.group(1)!);
    final mes = int.parse(m.group(2)!);
    final dia = int.parse(m.group(3)!);

    final fecha = DateTime(anio, mes, dia);
    // DateTime "desborda" fechas inválidas (31/02 -> 03/03), así que se compara.
    if (fecha.year != anio || fecha.month != mes || fecha.day != dia) {
      throw ValidacionException('La fecha ingresada no existe.');
    }
    return fecha;
  }
}
