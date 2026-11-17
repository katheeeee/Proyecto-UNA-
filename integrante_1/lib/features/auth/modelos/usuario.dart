class Usuario {
  const Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.correo,
    required this.escuelaProfesional,
  });

  final String id;
  final String nombreCompleto;
  final String correo;
  final String escuelaProfesional;

  Usuario copyWith({
    String? id,
    String? nombreCompleto,
    String? correo,
    String? escuelaProfesional,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      correo: correo ?? this.correo,
      escuelaProfesional: escuelaProfesional ?? this.escuelaProfesional,
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: '${json['id'] ?? ''}',
      nombreCompleto: '${json['nombre_completo'] ?? ''}',
      correo: '${json['correo'] ?? ''}',
      escuelaProfesional: '${json['escuela_profesional'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre_completo': nombreCompleto,
      'correo': correo,
      'escuela_profesional': escuelaProfesional,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Usuario &&
            other.id == id &&
            other.nombreCompleto == nombreCompleto &&
            other.correo == correo &&
            other.escuelaProfesional == escuelaProfesional;
  }

  @override
  int get hashCode {
    return Object.hash(id, nombreCompleto, correo, escuelaProfesional);
  }
}
