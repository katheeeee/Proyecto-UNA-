class Validadores {
  static final RegExp _correo = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

  static String? obligatorio(String? valor, {required String campo}) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresa $campo';
    }
    return null;
  }

  static String? correo(String? valor) {
    final requerido = obligatorio(valor, campo: 'tu correo institucional');
    if (requerido != null) {
      return requerido;
    }
    if (!_correo.hasMatch(valor!.trim())) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  static String? contrasena(String? valor) {
    final requerido = obligatorio(valor, campo: 'tu contraseña');
    if (requerido != null) {
      return requerido;
    }
    if (valor!.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  static String? confirmarContrasena(String? valor, String contrasena) {
    final requerido = obligatorio(valor, campo: 'la confirmación');
    if (requerido != null) {
      return requerido;
    }
    if (valor != contrasena) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }
}
