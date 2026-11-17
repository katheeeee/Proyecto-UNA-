class ExcepcionAuth implements Exception {
  const ExcepcionAuth(this.mensaje, {this.codigo});

  final String mensaje;
  final String? codigo;

  @override
  String toString() => mensaje;
}
