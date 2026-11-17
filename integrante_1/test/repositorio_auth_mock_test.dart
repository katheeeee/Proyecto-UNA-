import 'package:flutter_test/flutter_test.dart';
import 'package:integrante_1/features/auth/datos/mock_db.dart';
import 'package:integrante_1/features/auth/modelos/actividad.dart';
import 'package:integrante_1/features/auth/modelos/usuario.dart';
import 'package:integrante_1/features/auth/repositorios/excepcion_auth.dart';
import 'package:integrante_1/features/auth/repositorios/repositorio_auth_mock.dart';

void main() {
  late RepositorioAuthMock repositorio;

  setUp(() {
    repositorio = RepositorioAuthMock(db: MockDb(), retraso: Duration.zero);
  });

  test('inicia sesión con el usuario de prueba', () async {
    final sesion = await repositorio.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: '12345678',
    );

    expect(sesion.token, isNotEmpty);
    expect(sesion.usuario.correo, 'estudiante@una.edu.pe');
    expect(sesion.usuario.nombreCompleto, 'Ana Quispe Mamani');
  });

  test('rechaza credenciales incorrectas', () async {
    await expectLater(
      repositorio.iniciarSesion(
        correo: 'estudiante@una.edu.pe',
        contrasena: 'incorrecta',
      ),
      throwsA(isA<ExcepcionAuth>()),
    );
  });

  test('rechaza correo duplicado en el registro', () async {
    await expectLater(
      repositorio.registrar(
        nombreCompleto: 'Otra Persona',
        correo: 'estudiante@una.edu.pe',
        escuelaProfesional: 'Ingeniería Civil',
        contrasena: '87654321',
      ),
      throwsA(isA<ExcepcionAuth>()),
    );
  });

  test('permite registrarse y luego iniciar sesión', () async {
    await repositorio.registrar(
      nombreCompleto: 'Luis Condori',
      correo: 'luis@una.edu.pe',
      escuelaProfesional: 'Ingeniería Civil',
      contrasena: '87654321',
    );

    final sesion = await repositorio.iniciarSesion(
      correo: 'luis@una.edu.pe',
      contrasena: '87654321',
    );

    expect(sesion.usuario.nombreCompleto, 'Luis Condori');
    expect(sesion.usuario.escuelaProfesional, 'Ingeniería Civil');
  });

  test('actualiza el perfil del usuario autenticado', () async {
    await repositorio.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: '12345678',
    );

    final actualizado = await repositorio.actualizarPerfil(
      nombreCompleto: 'Ana Quispe Mamani',
      escuelaProfesional: 'Ingeniería de Software',
    );

    expect(actualizado.escuelaProfesional, 'Ingeniería de Software');
    final perfil = await repositorio.obtenerPerfil();
    expect(perfil.escuelaProfesional, 'Ingeniería de Software');
  });

  test('devuelve 6 actividades pendientes ordenadas por fecha', () async {
    await repositorio.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: '12345678',
    );

    final actividades = await repositorio.obtenerActividadesPendientes();

    expect(actividades, hasLength(6));
    expect(
      actividades.every(
        (actividad) => actividad.estado == EstadoActividad.pendiente,
      ),
      isTrue,
    );
    for (var i = 1; i < actividades.length; i++) {
      expect(
        actividades[i].fechaEntrega.isBefore(actividades[i - 1].fechaEntrega),
        isFalse,
      );
    }
  });

  test('restaura la sesión con un token válido', () async {
    final sesion = await repositorio.iniciarSesion(
      correo: 'estudiante@una.edu.pe',
      contrasena: '12345678',
    );

    final otroRepositorio = RepositorioAuthMock(
      db: MockDb(),
      retraso: Duration.zero,
    );
    final usuario = await otroRepositorio.restaurarSesion(sesion.token);

    expect(usuario.correo, 'estudiante@una.edu.pe');
  });

  test('rechaza un token inválido', () async {
    await expectLater(
      repositorio.restaurarSesion('token-invalido'),
      throwsA(isA<ExcepcionAuth>()),
    );
  });

  test('serializa y deserializa modelos', () {
    final usuario = Usuario.fromJson({
      'id': 7,
      'nombre_completo': 'Ana Quispe',
      'correo': 'ana@una.edu.pe',
      'escuela_profesional': 'Ingeniería de Sistemas',
    });
    expect(usuario.id, '7');
    expect(usuario.toJson()['nombre_completo'], 'Ana Quispe');

    final actividad = Actividad.fromJson({
      'id': 'a1',
      'titulo': 'Tarea',
      'curso': 'Curso',
      'tipo': 'trabajo_grupal',
      'fecha_entrega': '2026-11-10T14:30:00.000',
      'estado': 'pendiente',
    });

    expect(actividad.tipo, TipoActividad.trabajoGrupal);
    expect(actividad.fechaEntrega.hour, 14);
    expect(actividad.toJson()['tipo'], 'trabajo_grupal');
  });
}
