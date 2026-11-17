import 'package:dio/dio.dart';

import '../../../core/cliente_dio.dart';
import '../../../core/constantes.dart';
import '../modelos/actividad.dart';
import '../modelos/sesion.dart';
import '../modelos/usuario.dart';
import 'excepcion_auth.dart';
import 'repositorio_auth.dart';

class RepositorioAuthApi implements RepositorioAuth {
  const RepositorioAuthApi(this._cliente);

  final ClienteDio _cliente;

  @override
  Future<Sesion> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final respuesta = await _cliente.dio.post<Map<String, dynamic>>(
        Constantes.rutaLogin,
        data: {
          'correo': correo.trim().toLowerCase(),
          'password': contrasena,
        },
      );
      return Sesion.fromJson(_mapa(respuesta.data));
    } on DioException catch (error) {
      throw _convertir(error);
    } catch (_) {
      throw const ExcepcionAuth(
        'No se pudo conectar con el servidor. Inténtalo de nuevo.',
        codigo: 'sin_conexion',
      );
    }
  }

  @override
  Future<void> registrar({
    required String nombreCompleto,
    required String correo,
    required String escuelaProfesional,
    required String contrasena,
  }) async {
    try {
      await _cliente.dio.post<Map<String, dynamic>>(
        Constantes.rutaRegistro,
        data: {
          'nombre_completo': nombreCompleto.trim(),
          'correo': correo.trim().toLowerCase(),
          'escuela_profesional': escuelaProfesional.trim(),
          'password': contrasena,
        },
      );
    } on DioException catch (error) {
      throw _convertir(error);
    } catch (_) {
      throw const ExcepcionAuth(
        'No se pudo completar el registro. Inténtalo de nuevo.',
        codigo: 'sin_conexion',
      );
    }
  }

  @override
  Future<Usuario> restaurarSesion(String token) async {
    try {
      final respuesta = await _cliente.dio.get<Map<String, dynamic>>(
        Constantes.rutaPerfil,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return Usuario.fromJson(_mapa(respuesta.data));
    } on DioException catch (error) {
      throw _convertir(error);
    }
  }

  @override
  Future<Usuario> obtenerPerfil() async {
    try {
      final respuesta = await _cliente.dio.get<Map<String, dynamic>>(
        Constantes.rutaPerfil,
      );
      return Usuario.fromJson(_mapa(respuesta.data));
    } on DioException catch (error) {
      throw _convertir(error);
    }
  }

  @override
  Future<Usuario> actualizarPerfil({
    required String nombreCompleto,
    required String escuelaProfesional,
  }) async {
    try {
      final respuesta = await _cliente.dio.put<Map<String, dynamic>>(
        Constantes.rutaPerfil,
        data: {
          'nombre_completo': nombreCompleto.trim(),
          'escuela_profesional': escuelaProfesional.trim(),
        },
      );
      return Usuario.fromJson(_mapa(respuesta.data));
    } on DioException catch (error) {
      throw _convertir(error);
    }
  }

  @override
  Future<List<Actividad>> obtenerActividadesPendientes() async {
    try {
      final respuesta = await _cliente.dio.get<List<dynamic>>(
        Constantes.rutaActividades,
      );
      final datos = respuesta.data ?? const <dynamic>[];
      return datos
          .whereType<Map>()
          .map((item) => Actividad.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (error) {
      throw _convertir(error);
    }
  }

  @override
  Future<void> cerrarSesion() async {}

  Map<String, dynamic> _mapa(Object? datos) {
    if (datos is Map<String, dynamic>) {
      return datos;
    }
    if (datos is Map) {
      return Map<String, dynamic>.from(datos);
    }
    return const <String, dynamic>{};
  }

  ExcepcionAuth _convertir(DioException error) {
    final datos = error.response?.data;
    String? mensaje;
    if (datos is Map) {
      final detalle = datos['detail'];
      if (detalle is String && detalle.isNotEmpty) {
        mensaje = detalle;
      }
      if (mensaje == null) {
        for (final valor in datos.values) {
          if (valor is List && valor.isNotEmpty && valor.first is String) {
            mensaje = valor.first as String;
            break;
          }
          if (valor is String) {
            mensaje = valor;
            break;
          }
        }
      }
    }

    final codigo = error.response?.statusCode;
    if (mensaje != null && mensaje.isNotEmpty) {
      return ExcepcionAuth(mensaje, codigo: 'http_$codigo');
    }
    switch (codigo) {
      case 401:
        return const ExcepcionAuth(
          'Correo o contraseña incorrectos.',
          codigo: 'credenciales_invalidas',
        );
      case 403:
        return const ExcepcionAuth(
          'No tienes permiso para realizar esta acción.',
          codigo: 'sin_permiso',
        );
      case null:
        return const ExcepcionAuth(
          'No se pudo conectar con el servidor. Inténtalo de nuevo.',
          codigo: 'sin_conexion',
        );
      default:
        return ExcepcionAuth(
          'Error del servidor ($codigo). Inténtalo de nuevo.',
          codigo: 'http_$codigo',
        );
    }
  }
}
