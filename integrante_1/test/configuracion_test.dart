import 'package:flutter_test/flutter_test.dart';
import 'package:integrante_1/core/constantes.dart';
import 'package:integrante_1/core/tema.dart';

void main() {
  test('la configuracion base es valida', () {
    expect(Constantes.usarDatosMock, isTrue);
    expect(Constantes.longitudMinimaContrasena, 8);
    expect(Constantes.apiBaseUrl, isNotEmpty);
    expect(TemaApp.claro.useMaterial3, isTrue);
    expect(TemaApp.claro.colorScheme.primary, isNotNull);
  });
}
