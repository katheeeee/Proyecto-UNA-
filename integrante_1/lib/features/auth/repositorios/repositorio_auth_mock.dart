import '../../../core/constantes.dart';
import '../datos/mock_db.dart';
import '../modelos/actividad.dart';
import '../modelos/sesion.dart';
import '../modelos/usuario.dart';
import 'excepcion_auth.dart';
import 'repositorio_auth.dart';

class RepositorioAuthMock implements RepositorioAuth {
  RepositorioAuthMock({MockDb? db, Duration? retraso})
    : _db = db ?? MockDb(),
      _retraso = retraso ?? Constantes.retrasoMock;

  final MockDb _db;
  final Duration _retraso;
  Usuario? _usuarioActual;

  Future<void> _esperar() => Future<void>.delayed(_retraso);

  Usuario _requerirUsuario() {
    final usuario = _usuarioActual;
    if (usuario == null) {
      throw const ExcepcionAuth(
        'No hay una sesión activa',
        codigo: 'sin_sesion',
      );
    }
    return usuario;
  }

  @override
  Future<Sesion> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    await _esperar();
    final usuario = _db.buscarPorCorreo(correo);
    if (usuario == null || !_db.validarContrasena(correo, contrasena)) {
      throw const ExcepcionAuth(
        'Correo o contraseña incorrectos',
        codigo: 'credenciales_invalidas',
      );
    }
    _usuarioActual = usuario;
    return Sesion(token: _db.generarToken(usuario), usuario: usuario);
  }

  @override
  Future<void> registrar({
    required String nombreCompleto,
    required String correo,
    required String escuelaProfesional,
    required String contrasena,
  }) async {
    await _esperar();
    if (nombreCompleto.trim().isEmpty ||
        correo.trim().isEmpty ||
        escuelaProfesional.trim().isEmpty ||
        contrasena.isEmpty) {
      throw const ExcepcionAuth(
        'Todos los campos son obligatorios',
        codigo: 'campos_vacios',
      );
    }
    if (_db.existeCorreo(correo)) {
      throw const ExcepcionAuth(
        'El correo ya está registrado',
        codigo: 'correo_duplicado',
      );
    }
    if (contrasena.length < Constantes.longitudMinimaContrasena) {
      throw const ExcepcionAuth(
        'La contraseña debe tener al menos 8 caracteres',
        codigo: 'contrasena_corta',
      );
    }
    _db.agregarUsuario(
      nombreCompleto: nombreCompleto,
      correo: correo,
      escuelaProfesional: escuelaProfesional,
      contrasena: contrasena,
    );
  }

  @override
  Future<Usuario> restaurarSesion(String token) async {
    await _esperar();
    final usuario = _db.usuarioDesdeToken(token);
    if (usuario == null) {
      throw const ExcepcionAuth(
        'La sesión expiró, vuelve a iniciar sesión',
        codigo: 'sesion_expirada',
      );
    }
    _usuarioActual = usuario;
    return usuario;
  }

  @override
  Future<Usuario> obtenerPerfil() async {
    await _esperar();
    return _requerirUsuario();
  }

  @override
  Future<Usuario> actualizarPerfil({
    required String nombreCompleto,
    required String escuelaProfesional,
  }) async {
    await _esperar();
    final usuario = _requerirUsuario();
    if (nombreCompleto.trim().isEmpty || escuelaProfesional.trim().isEmpty) {
      throw const ExcepcionAuth(
        'Nombre y escuela son obligatorios',
        codigo: 'campos_vacios',
      );
    }
    final actualizado = _db.actualizarUsuario(
      id: usuario.id,
      nombreCompleto: nombreCompleto,
      escuelaProfesional: escuelaProfesional,
    );
    _usuarioActual = actualizado;
    return actualizado;
  }

  @override
  Future<List<Actividad>> obtenerActividadesPendientes() async {
    await _esperar();
    _requerirUsuario();
    return _db.actividadesPendientes();
  }

  @override
  Future<void> cerrarSesion() async {
    await _esperar();
    _usuarioActual = null;
  }
}
