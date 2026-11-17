import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:integrante_1/core/almacen_sesion.dart';
import 'package:integrante_1/features/auth/datos/mock_db.dart';
import 'package:integrante_1/features/auth/providers/auth_provider.dart';
import 'package:integrante_1/features/auth/repositorios/repositorio_auth_mock.dart';
import 'package:integrante_1/main.dart';

class _AlmacenSesionMemoria extends AlmacenSesion {
  final Map<String, String> _datos = {};

  @override
  Future<String?> leerToken() async => _datos['token'];

  @override
  Future<void> guardarToken(String token) async => _datos['token'] = token;

  @override
  Future<void> eliminarToken() async => _datos.remove('token');

  @override
  Future<String?> leerRefresh() async => _datos['refresh'];

  @override
  Future<void> guardarRefresh(String refresh) async =>
      _datos['refresh'] = refresh;

  @override
  Future<void> eliminarRefresh() async => _datos.remove('refresh');
}

void main() {
  testWidgets(
    'después del login navega a Inicio y muestra el resumen',
    (tester) async {
      await initializeDateFormatting('es');
      final almacen = _AlmacenSesionMemoria();
      final repositorio = RepositorioAuthMock(
        db: MockDb(),
        retraso: Duration.zero,
      );
      final auth = AuthProvider(repositorio, almacen);
      await auth.init();

      await tester.pumpWidget(
        UNAPlusApp(almacen: almacen, auth: auth, repositorio: repositorio),
      );
      await tester.pumpAndSettle();

      expect(find.text('Iniciar sesión'), findsOneWidget);

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'estudiante@una.edu.pe',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '12345678');
      await tester.tap(find.text('Ingresar'));
      await tester.pumpAndSettle();

      expect(find.text('Resumen de actividades'), findsOneWidget);
      expect(find.textContaining('Hola, Ana'), findsOneWidget);
      expect(find.text('Resolver ejercicios de límites'), findsOneWidget);
      expect(find.text('Para hoy'), findsOneWidget);
      expect(find.text('Próximos 7 días'), findsOneWidget);
    },
  );
}
