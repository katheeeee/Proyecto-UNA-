import 'package:intl/intl.dart';

class FormatoFechas {
  static final DateFormat _fechaLarga = DateFormat("EEEE d 'de' MMMM", 'es');
  static final DateFormat _fechaCorta = DateFormat('d MMM', 'es');
  static final DateFormat _hora = DateFormat('HH:mm', 'es');
  static final DateFormat _fechaHora = DateFormat('d MMM, HH:mm', 'es');

  static String fechaLarga(DateTime fecha) {
    return _capitalizar(_fechaLarga.format(fecha));
  }

  static String fechaCorta(DateTime fecha) {
    return _capitalizar(_fechaCorta.format(fecha));
  }

  static String hora(DateTime fecha) {
    return _hora.format(fecha);
  }

  static String fechaHora(DateTime fecha) {
    return _fechaHora.format(fecha);
  }

  static String _capitalizar(String valor) {
    if (valor.isEmpty) {
      return valor;
    }
    return '${valor[0].toUpperCase()}${valor.substring(1)}';
  }
}
