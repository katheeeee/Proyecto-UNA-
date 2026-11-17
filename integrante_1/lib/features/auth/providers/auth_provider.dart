import 'package:flutter/foundation.dart';

import '../../../core/almacen_sesion.dart';
import '../modelos/usuario.dart';
import '../repositorios/excepcion_auth.dart';
import '../repositorios/repositorio_auth.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repositorio, this._almacen);

  final RepositorioAuth _repositorio;
  final AlmacenSesion _almacen;

  bool _autenticado = false;
  bool _cargando = true;
  bool _procesando = false;
  String? _token;
  Usuario? _usuario;
  String? _error;

  bool get autenticado => _autenticado;
  bool get cargando => _cargando;
  bool get procesando => _procesando;
  String? get token => _token;
  Usuario? get usuario => _usuario;
  String? get error => _error;

  Future<void> init() async {
    _cargando = true;
    notifyListeners();

    final token = await _almacen.leerToken();
    if (token == null || token.isEmpty) {
      _cargando = false;
      _autenticado = false;
      notifyListeners();
      return;
    }

    try {
      final usuario = await _repositorio.restaurarSesion(token);
      _token = token;
      _usuario = usuario;
      _autenticado = true;
    } on ExcepcionAuth {
      await _almacen.eliminarToken();
      _token = null;
      _usuario = null;
      _autenticado = false;
    } catch (_) {
      _token = null;
      _usuario = null;
      _autenticado = false;
    }

    _cargando = false;
    notifyListeners();
  }

  Future<bool> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    _procesando = true;
    _error = null;
    notifyListeners();

    try {
      final sesion = await _repositorio.iniciarSesion(
        correo: correo.trim(),
        contrasena: contrasena,
      );
      await _almacen.guardarToken(sesion.token);
      if (sesion.refresh != null && sesion.refresh!.isNotEmpty) {
        await _almacen.guardarRefresh(sesion.refresh!);
      }
      _token = sesion.token;
      _usuario = sesion.usuario;
      _autenticado = true;
      return true;
    } on ExcepcionAuth catch (excepcion) {
      _error = excepcion.mensaje;
      return false;
    } catch (_) {
      _error = 'No se pudo conectar con el servidor. Inténtalo de nuevo.';
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<bool> registrar({
    required String nombreCompleto,
    required String correo,
    required String escuelaProfesional,
    required String contrasena,
  }) async {
    _procesando = true;
    _error = null;
    notifyListeners();

    try {
      await _repositorio.registrar(
        nombreCompleto: nombreCompleto.trim(),
        correo: correo.trim(),
        escuelaProfesional: escuelaProfesional.trim(),
        contrasena: contrasena,
      );
      return true;
    } on ExcepcionAuth catch (excepcion) {
      _error = excepcion.mensaje;
      return false;
    } catch (_) {
      _error = 'No se pudo completar el registro. Inténtalo de nuevo.';
      return false;
    } finally {
      _procesando = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    await _repositorio.cerrarSesion();
    await _almacen.eliminarToken();
    await _almacen.eliminarRefresh();
    _token = null;
    _usuario = null;
    _autenticado = false;
    _error = null;
    notifyListeners();
  }

  void actualizarUsuario(Usuario usuario) {
    _usuario = usuario;
    notifyListeners();
  }

  void limpiarError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }
}
