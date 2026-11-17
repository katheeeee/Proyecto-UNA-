import 'package:flutter_test/flutter_test.dart';
import 'package:integrante_1/core/almacen_sesion.dart';
import 'package:integrante_1/features/auth/datos/mock_db.dart';
import 'package:integrante_1/features/auth/providers/auth_provider.dart';
import 'package:integrante_1/features/auth/repositorios/repositorio_auth_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDb db;
  late RepositorioAuthMock repositorio;
  late AlmacenSesion almacen;
  late AuthProvider auth;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = MockDb();
    repositorio = RepositorioAuthMock(db: db, retraso: Duration.zero);
    almacen = AlmacenSesion();
    auth = AuthProvider(repositorio, almacen);
  });

  test('init sin token deja la sesión cerrada', () async {
    await auth.init();

    expect(auth.autenticado, isFalse);
    expect(auth.cargando, isFalse);
    expect(auth.usuario, isNull);
  });

  test('login correcto autentica y guarda el token', () async {
    await auth.init();

    final exito = await auth.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: '12345678',
    );

    expect(exito, isTrue);
    expect(auth.autenticado, isTrue);
    expect(auth.usuario?.correo, 'estudiante@una.edu.pe');
    expect(await almacen.leerToken(), isNotNull);
  });

  test('login incorrecto expone el mensaje de error', () async {
    await auth.init();

    final exito = await auth.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: 'incorrecta',
    );

    expect(exito, isFalse);
    expect(auth.autenticado, isFalse);
    expect(auth.error, 'Correo o contraseña incorrectos');
  });

  test('registro duplicado expone el mensaje de error', () async {
    await auth.init();

    final exito = await auth.registrar(
      nombreCompleto: 'Otra Persona',
      correo: 'estudiante@una.edu.pe',
      escuelaProfesional: 'Ingeniería Civil',
      contrasena: '87654321',
    );

    expect(exito, isFalse);
    expect(auth.error, 'El correo ya está registrado');
  });

  test('restaura la sesión desde el token guardado', () async {
    await auth.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: '12345678',
    );

    final otroAuth = AuthProvider(
      RepositorioAuthMock(db: db, retraso: Duration.zero),
      almacen,
    );
    await otroAuth.init();

    expect(otroAuth.autenticado, isTrue);
    expect(otroAuth.usuario?.correo, 'estudiante@una.edu.pe');
  });

  test('cerrar sesión elimina el token', () async {
    await auth.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: '12345678',
    );

    await auth.cerrarSesion();

    expect(auth.autenticado, isFalse);
    expect(auth.usuario, isNull);
    expect(await almacen.leerToken(), isNull);
  });
}
