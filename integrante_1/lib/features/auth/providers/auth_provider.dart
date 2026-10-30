import 'package:flutter/foundation.dart';

import '../../../core/almacen_sesion.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._almacen);

  final AlmacenSesion _almacen;

  bool _autenticado = false;
  bool _cargando = true;
  String? _token;

  bool get autenticado => _autenticado;
  bool get cargando => _cargando;
  String? get token => _token;

  Future<void> init() async {
    _token = await _almacen.leerToken();
    _autenticado = _token != null && _token!.isNotEmpty;
    _cargando = false;
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    await _almacen.eliminarToken();
    _token = null;
    _autenticado = false;
    notifyListeners();
  }
}
