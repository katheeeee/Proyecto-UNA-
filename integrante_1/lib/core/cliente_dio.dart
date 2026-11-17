import 'package:dio/dio.dart';

import 'almacen_sesion.dart';
import 'constantes.dart';

class ClienteDio {
  ClienteDio(this._almacen, {this.onTokenExpirado}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: Constantes.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: const {'Accept': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opciones, manejador) async {
          final token = await _almacen.leerToken();
          if (token != null && token.isNotEmpty) {
            opciones.headers['Authorization'] = 'Bearer $token';
          }
          manejador.next(opciones);
        },
        onError: (error, manejador) async {
          if (!_es401Renovable(error) || _refresciendo) {
            manejador.next(error);
            return;
          }
          _refresciendo = true;
          try {
            final refresh = await _almacen.leerRefresh();
            if (refresh == null || refresh.isEmpty) {
              throw StateError('No hay refresh token');
            }
            final respuesta = await _dio.post<Map<String, dynamic>>(
              Constantes.rutaRefresh,
              data: {'refresh': refresh},
            );
            final access = respuesta.data?['access'] as String?;
            if (access == null || access.isEmpty) {
              throw StateError('El servidor no devolvió un access token');
            }
            await _almacen.guardarToken(access);
            error.requestOptions.headers['Authorization'] = 'Bearer $access';
            manejador.resolve(await _dio.fetch(error.requestOptions));
          } catch (_) {
            await _almacen.eliminarToken();
            await _almacen.eliminarRefresh();
            if (onTokenExpirado != null) {
              await onTokenExpirado!();
            }
            manejador.next(error);
          } finally {
            _refresciendo = false;
          }
        },
      ),
    );
  }

  final AlmacenSesion _almacen;
  Future<void> Function()? onTokenExpirado;

  bool _refresciendo = false;

  late final Dio _dio;

  Dio get dio => _dio;

  bool _es401Renovable(DioException error) {
    if (error.response?.statusCode != 401) {
      return false;
    }
    final ruta = error.requestOptions.path;
    return !ruta.endsWith(Constantes.rutaLogin) &&
        !ruta.endsWith(Constantes.rutaRegistro) &&
        !ruta.endsWith(Constantes.rutaRefresh);
  }
}
