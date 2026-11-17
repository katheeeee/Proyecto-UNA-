import 'package:flutter/foundation.dart';

import '../../auth/modelos/actividad.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/repositorios/excepcion_auth.dart';
import '../../auth/repositorios/repositorio_auth.dart';

class InicioProvider extends ChangeNotifier {
  InicioProvider(this._repositorio, this._auth);

  final RepositorioAuth _repositorio;
  final AuthProvider _auth;

  bool _cargando = false;
  String? _error;
  List<Actividad> _actividades = const [];

  bool get cargando => _cargando;
  String? get error => _error;
  List<Actividad> get actividades => List.unmodifiable(_actividades);

  int get cantidadHoy {
    final ahora = DateTime.now();
    return _actividades.where((actividad) {
      final fecha = actividad.fechaEntrega;
      return fecha.year == ahora.year &&
          fecha.month == ahora.month &&
          fecha.day == ahora.day;
    }).length;
  }

  int get cantidadSemana => _actividades.length;

  Future<void> cargar() async {
    if (_cargando || !_auth.autenticado) {
      return;
    }
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _actividades = await _repositorio.obtenerActividadesPendientes();
    } on ExcepcionAuth catch (excepcion) {
      _error = excepcion.mensaje;
      _actividades = const [];
    } catch (_) {
      _error = 'No se pudo cargar el resumen. Inténtalo de nuevo.';
      _actividades = const [];
    } finally {
      _cargando = false;
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
