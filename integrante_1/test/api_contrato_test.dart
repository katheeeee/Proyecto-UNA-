import 'package:flutter_test/flutter_test.dart';
import 'package:integrante_1/core/almacen_sesion.dart';
import 'package:integrante_1/core/cliente_dio.dart';
import 'package:integrante_1/features/auth/providers/auth_provider.dart';
import 'package:integrante_1/features/auth/repositorios/repositorio_auth_api.dart';

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
  test(
    'login real contra Django devuelve token, perfil y actividades',
    () async {
      final almacen = _AlmacenSesionMemoria();
      final repositorio = RepositorioAuthApi(ClienteDio(almacen));
      final auth = AuthProvider(repositorio, almacen);
      await auth.init();

      final exito = await auth.iniciarSesion(
        correo: 'estudiante@una.edu.pe',
        contrasena: '12345678',
      );

      expect(exito, isTrue);
      expect(auth.token, isNotEmpty);
      expect(auth.usuario?.nombreCompleto, 'Ana Quispe Mamani');
      expect(await almacen.leerRefresh(), isNotNull);

      final perfil = await repositorio.obtenerPerfil();
      expect(perfil.correo, 'estudiante@una.edu.pe');

      final actividades = await repositorio.obtenerActividadesPendientes();
      expect(actividades.length, 5);
      expect(actividades.first.titulo, 'Resolver ejercicios de límites');
    },
    skip: !const bool.fromEnvironment('API_TEST', defaultValue: false),
  );
}
