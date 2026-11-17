import 'package:flutter_test/flutter_test.dart';
import 'package:integrante_1/core/almacen_sesion.dart';
import 'package:integrante_1/features/auth/datos/mock_db.dart';
import 'package:integrante_1/features/auth/providers/auth_provider.dart';
import 'package:integrante_1/features/auth/repositorios/repositorio_auth_mock.dart';
import 'package:integrante_1/features/perfil/providers/perfil_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDb db;
  late RepositorioAuthMock repositorio;
  late AuthProvider auth;
  late PerfilProvider perfil;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = MockDb();
    repositorio = RepositorioAuthMock(db: db, retraso: Duration.zero);
    auth = AuthProvider(repositorio, AlmacenSesion());
    perfil = PerfilProvider(repositorio, auth);
    await auth.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: '12345678',
    );
  });

  test('expone el usuario autenticado', () {
    expect(perfil.usuario, isNotNull);
    expect(perfil.usuario?.correo, 'estudiante@una.edu.pe');
  });

  test('actualiza el perfil y sincroniza el usuario de auth', () async {
    final exito = await perfil.actualizar(
      nombreCompleto: 'Ana Quispe Mamani',
      escuelaProfesional: 'Ingeniería de Software',
    );

    expect(exito, isTrue);
    expect(perfil.error, isNull);
    expect(perfil.usuario?.escuelaProfesional, 'Ingeniería de Software');
    expect(auth.usuario?.escuelaProfesional, 'Ingeniería de Software');
  });

  test('rechaza campos vacíos al actualizar', () async {
    final exito = await perfil.actualizar(
      nombreCompleto: '   ',
      escuelaProfesional: 'Ingeniería de Software',
    );

    expect(exito, isFalse);
    expect(perfil.error, 'Nombre y escuela son obligatorios');
  });

  test('cargar no hace nada si auth ya tiene usuario', () async {
    await perfil.cargar();

    expect(perfil.cargando, isFalse);
    expect(perfil.usuario?.nombreCompleto, 'Ana Quispe Mamani');
  });
}
