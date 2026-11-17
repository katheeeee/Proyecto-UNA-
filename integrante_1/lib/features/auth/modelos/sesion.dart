import 'usuario.dart';

class Sesion {
  const Sesion({required this.token, required this.usuario, this.refresh});

  final String token;
  final Usuario usuario;
  final String? refresh;

  factory Sesion.fromJson(Map<String, dynamic> json) {
    final datosUsuario = json['usuario'];
    return Sesion(
      token: '${json['access'] ?? json['token'] ?? ''}',
      refresh: json['refresh'] as String?,
      usuario: datosUsuario is Map
          ? Usuario.fromJson(Map<String, dynamic>.from(datosUsuario))
          : Usuario.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'refresh': refresh,
      'usuario': usuario.toJson(),
    };
  }
}
