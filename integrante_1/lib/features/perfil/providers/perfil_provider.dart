import 'package:flutter/foundation.dart';

import '../../auth/modelos/usuario.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/repositorios/excepcion_auth.dart';
import '../../auth/repositorios/repositorio_auth.dart';

class PerfilProvider extends ChangeNotifier {
  PerfilProvider(this._repositorio, this._auth);

  final RepositorioAuth _repositorio;
  final AuthProvider _auth;

  bool _cargando = false;
  bool _guardando = false;
  String? _error;
  Usuario? _usuario;

  Usuario? get usuario => _auth.usuario ?? _usuario;
  bool get cargando => _cargando;
  bool get guardando => _guardando;
  String? get error => _error;

  Future<void> cargar() async {
    if (_auth.usuario != null) {
      return;
    }

    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final usuario = await _repositorio.obtenerPerfil();
      _usuario = usuario;
      _auth.actualizarUsuario(usuario);
    } on ExcepcionAuth catch (excepcion) {
      _error = excepcion.mensaje;
    } catch (_) {
      _error = 'No se pudo cargar el perfil. Inténtalo de nuevo.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> actualizar({
    required String nombreCompleto,
    required String escuelaProfesional,
  }) async {
    _guardando = true;
    _error = null;
    notifyListeners();

    try {
      final usuario = await _repositorio.actualizarPerfil(
        nombreCompleto: nombreCompleto.trim(),
        escuelaProfesional: escuelaProfesional.trim(),
      );
      _usuario = usuario;
      _auth.actualizarUsuario(usuario);
      return true;
    } on ExcepcionAuth catch (excepcion) {
      _error = excepcion.mensaje;
      return false;
    } catch (_) {
      _error = 'No se pudo actualizar el perfil. Inténtalo de nuevo.';
      return false;
    } finally {
      _guardando = false;
      notifyListeners();
    }
  }

  void limpiarError() {
    if (_error == null) {
      return;
    }
    _error = null;
    notifyListeners();
  }
}
