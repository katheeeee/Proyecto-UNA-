import '../modelos/actividad.dart';
import '../modelos/sesion.dart';
import '../modelos/usuario.dart';

abstract class RepositorioAuth {
  Future<Sesion> iniciarSesion({
    required String correo,
    required String contrasena,
  });

  Future<void> registrar({
    required String nombreCompleto,
    required String correo,
    required String escuelaProfesional,
    required String contrasena,
  });

  Future<Usuario> restaurarSesion(String token);

  Future<Usuario> obtenerPerfil();

  Future<Usuario> actualizarPerfil({
    required String nombreCompleto,
    required String escuelaProfesional,
  });

  Future<List<Actividad>> obtenerActividadesPendientes();

  Future<void> cerrarSesion();
}
