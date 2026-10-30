import 'package:flutter_test/flutter_test.dart';
import 'package:unap_mas_app/services/actividad_service.dart';

void main() {
  final service = ActividadService();
  // Fecha fija de referencia para que las pruebas sean repetibles.
  final hoy = DateTime(2026, 10, 30);

  Actividad registrar({
    String? titulo = 'Informe de laboratorio',
    String? tipo = 'tarea',
    String? curso = 'Ingeniería de Software',
    String? fecha = '2026-12-15',
  }) =>
      service.registrarActividad(
        titulo: titulo,
        tipo: tipo,
        curso: curso,
        fechaEntrega: fecha,
        hoy: hoy,
      );

  test('Caso válido: registra la actividad', () {
    final a = registrar();
    expect(a.titulo, 'Informe de laboratorio');
    expect(a.tipo, 'tarea');
    expect(a.curso, 'Ingeniería de Software');
    expect(a.fechaEntrega, DateTime(2026, 12, 15));
    expect(formatearFechaLatina(a.fechaEntrega), '15/12/2026');
  });

  test('Caso inválido: fecha en el pasado', () {
    expect(
      () => registrar(fecha: '2026-10-01'),
      throwsA(isA<ValidacionException>().having((e) => e.mensaje, 'mensaje',
          'La fecha de entrega no puede estar en el pasado.')),
    );
  });

  test('Título vacío rechazado', () {
    expect(() => registrar(titulo: '   '),
        throwsA(isA<ValidacionException>()));
  });

  test('Tipo no permitido rechazado', () {
    expect(() => registrar(tipo: 'quiz'),
        throwsA(isA<ValidacionException>()));
  });

  test('Fecha con formato incorrecto rechazada', () {
    expect(() => registrar(fecha: '15/12/2026'),
        throwsA(isA<ValidacionException>()));
  });

  test('Fecha inexistente (31 de febrero) rechazada', () {
    expect(() => registrar(fecha: '2027-02-31'),
        throwsA(isA<ValidacionException>()));
  });

  test('La fecha de hoy es válida', () {
    expect(registrar(fecha: '2026-10-30'), isNotNull);
  });
}