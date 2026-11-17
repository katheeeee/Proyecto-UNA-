import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integrante_1/core/almacen_sesion.dart';
import 'package:integrante_1/core/tema.dart';
import 'package:integrante_1/features/auth/datos/mock_db.dart';
import 'package:integrante_1/features/auth/pantallas/login_screen.dart';
import 'package:integrante_1/features/auth/pantallas/registro_screen.dart';
import 'package:integrante_1/features/auth/providers/auth_provider.dart';
import 'package:integrante_1/features/auth/repositorios/repositorio_auth_mock.dart';
import 'package:provider/provider.dart';

Widget _app(AuthProvider auth, Widget pantalla) {
  return ChangeNotifierProvider<AuthProvider>.value(
    value: auth,
    child: MaterialApp(theme: TemaApp.claro, home: pantalla),
  );
}

void main() {
  late AuthProvider auth;

  setUp(() {
    auth = AuthProvider(
      RepositorioAuthMock(db: MockDb(), retraso: Duration.zero),
      AlmacenSesion(),
    );
  });

  testWidgets('login valida los campos obligatorios', (tester) async {
    await tester.pumpWidget(_app(auth, const LoginScreen()));

    final boton = find.widgetWithText(FilledButton, 'Ingresar');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pump();

    expect(find.text('Ingresa tu correo institucional'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('login muestra credenciales incorrectas', (tester) async {
    await tester.pumpWidget(_app(auth, const LoginScreen()));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'estudiante@una.edu.pe',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'incorrecta');

    final boton = find.widgetWithText(FilledButton, 'Ingresar');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pumpAndSettle();

    expect(find.text('Correo o contraseña incorrectos'), findsWidgets);
  });

  testWidgets('registro valida correo y confirmación', (tester) async {
    await tester.pumpWidget(_app(auth, const RegistroScreen()));

    final boton = find.widgetWithText(FilledButton, 'Registrarme');
    await tester.ensureVisible(boton);
    await tester.tap(boton);
    await tester.pump();

    expect(find.text('Ingresa tu nombre completo'), findsOneWidget);
    expect(find.text('Ingresa tu correo institucional'), findsOneWidget);
    expect(find.text('Ingresa tu escuela profesional'), findsOneWidget);
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
    expect(find.text('Ingresa la confirmación'), findsOneWidget);
  });
}
