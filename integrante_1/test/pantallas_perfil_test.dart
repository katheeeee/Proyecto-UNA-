import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integrante_1/core/almacen_sesion.dart';
import 'package:integrante_1/core/tema.dart';
import 'package:integrante_1/features/auth/datos/mock_db.dart';
import 'package:integrante_1/features/auth/providers/auth_provider.dart';
import 'package:integrante_1/features/auth/repositorios/repositorio_auth_mock.dart';
import 'package:integrante_1/features/perfil/pantallas/editar_perfil_screen.dart';
import 'package:integrante_1/features/perfil/pantallas/perfil_screen.dart';
import 'package:integrante_1/features/perfil/providers/perfil_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RepositorioAuthMock repositorio;
  late AuthProvider auth;
  late PerfilProvider perfil;
  late GoRouter router;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repositorio = RepositorioAuthMock(db: MockDb(), retraso: Duration.zero);
    auth = AuthProvider(repositorio, AlmacenSesion());
    perfil = PerfilProvider(repositorio, auth);
    await auth.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: '12345678',
    );
    router = GoRouter(
      initialLocation: '/perfil',
      routes: [
        GoRoute(
          path: '/perfil',
          builder: (context, state) => const PerfilScreen(),
        ),
        GoRoute(
          path: '/perfil/editar',
          builder: (context, state) => const EditarPerfilScreen(),
        ),
      ],
    );
  });

  testWidgets('muestra los datos del estudiante', (tester) async {
    await tester.pumpWidget(_app(router, auth, perfil));
    await tester.pumpAndSettle();

    expect(find.text('Ana Quispe Mamani'), findsOneWidget);
    expect(find.text('estudiante@una.edu.pe'), findsWidgets);
    expect(find.text('Ingeniería de Sistemas'), findsOneWidget);
  });

  testWidgets('edita el perfil y regresa a la pantalla anterior', (
    tester,
  ) async {
    await tester.pumpWidget(_app(router, auth, perfil));
    await tester.pumpAndSettle();

    final botonEditar = find.widgetWithText(FilledButton, 'Editar perfil');
    await tester.ensureVisible(botonEditar);
    await tester.tap(botonEditar);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Ana Quispe Actualizada',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'Ingeniería de Software',
    );

    final botonGuardar = find.widgetWithText(FilledButton, 'Guardar cambios');
    await tester.ensureVisible(botonGuardar);
    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(auth.usuario?.nombreCompleto, 'Ana Quispe Actualizada');
    expect(auth.usuario?.escuelaProfesional, 'Ingeniería de Software');
    expect(find.text('Ana Quispe Actualizada'), findsOneWidget);
  });
}

Widget _app(GoRouter router, AuthProvider auth, PerfilProvider perfil) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthProvider>.value(value: auth),
      ChangeNotifierProvider<PerfilProvider>.value(value: perfil),
    ],
    child: MaterialApp.router(theme: TemaApp.claro, routerConfig: router),
  );
}
