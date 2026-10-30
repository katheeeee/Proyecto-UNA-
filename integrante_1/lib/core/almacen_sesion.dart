import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlmacenSesion {
  static const String _claveToken = 'unaplus_token';

  final FlutterSecureStorage _seguro = const FlutterSecureStorage();
  bool _usarRespaldo = false;

  bool get usaRespaldo => _usarRespaldo;

  Future<String?> leerToken() async {
    if (!_usarRespaldo) {
      try {
        final token = await _seguro.read(key: _claveToken);
        if (token != null && token.isNotEmpty) {
          return token;
        }
      } catch (error) {
        await _activarRespaldo(error);
      }
    }
    final preferencias = await SharedPreferences.getInstance();
    return preferencias.getString(_claveToken);
  }

  Future<void> guardarToken(String token) async {
    if (!_usarRespaldo) {
      try {
        await _seguro.write(key: _claveToken, value: token);
        return;
      } catch (error) {
        await _activarRespaldo(error);
      }
    }
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.setString(_claveToken, token);
  }

  Future<void> eliminarToken() async {
    try {
      await _seguro.delete(key: _claveToken);
    } catch (_) {}
    final preferencias = await SharedPreferences.getInstance();
    await preferencias.remove(_claveToken);
  }

  Future<void> _activarRespaldo(Object error) async {
    _usarRespaldo = true;
    debugPrint(
      'AlmacenSesion: flutter_secure_storage no disponible, se usa shared_preferences. $error',
    );
  }
}
