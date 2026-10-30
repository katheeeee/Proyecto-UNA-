import 'package:dio/dio.dart';

import 'almacen_sesion.dart';
import 'constantes.dart';

class ClienteDio {
  ClienteDio(this._almacen) {
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
      ),
    );
  }

  final AlmacenSesion _almacen;

  late final Dio _dio;

  Dio get dio => _dio;
}
