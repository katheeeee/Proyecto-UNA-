import 'dart:developer' as developer;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlmacenSesion {
  static const String _claveToken = 'unaplus_token';
  static const String _claveRefresh = 'unaplus_refresh';

  final FlutterSecureStorage _seguro = const FlutterSecureStorage();
  bool _usarRespaldo = false;

  bool get usaRespaldo => _usarRespaldo;

  Future<String?> leerToken() => _leer(_claveToken);

  Future<void> guardarToken(String token) => _guardar(_claveToken, token);

  Future<void> eliminarToken() => _eliminar(_claveToken);

  Future<String?> leerRefresh() => _leer(_claveRefresh);

  Future<void> guardarRefresh(String refresh) => _guardar(_claveRefresh, refresh);

  Future<void> eliminarRefresh() => _eliminar(_claveRefresh);

  Future<String?> _leer(String clave) async {
    if (!_usarRespaldo) {
      try {
        final valor = await _seguro.read(key: clave);
        if (valor != null && valor.isNotEmpty) {
          return valor;
        }
      } catch (error) {
        await _activarRespaldo(error);
      }
    }
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(clave);
  }

  Future<void> _guardar(String clave, String valor) async {
    if (!_usarRespaldo) {
      try {
        await _seguro.write(key: clave, value: valor);
        return;
      } catch (error) {
        await _activarRespaldo(error);
      }
    }
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(clave, valor);
  }

  Future<void> _eliminar(String clave) async {
    try {
      await _seguro.delete(key: clave);
    } catch (_) {}
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(clave);
  }

  Future<void> _activarRespaldo(Object error) async {
    _usarRespaldo = true;
    developer.log(
      'flutter_secure_storage no disponible, se usa shared_preferences. $error',
      name: 'AlmacenSesion',
    );
  }
}
