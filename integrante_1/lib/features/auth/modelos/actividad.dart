enum TipoActividad {
  tarea('tarea'),
  evaluacion('evaluacion'),
  trabajoGrupal('trabajo_grupal'),
  proyecto('proyecto');

  const TipoActividad(this.valorApi);

  final String valorApi;

  static TipoActividad desdeApi(String valor) {
    return TipoActividad.values.firstWhere(
      (tipo) => tipo.valorApi == valor,
      orElse: () => TipoActividad.tarea,
    );
  }
}

enum EstadoActividad {
  pendiente('pendiente'),
  entregada('entregada'),
  vencida('vencida');

  const EstadoActividad(this.valorApi);

  final String valorApi;

  static EstadoActividad desdeApi(String valor) {
    return EstadoActividad.values.firstWhere(
      (estado) => estado.valorApi == valor,
      orElse: () => EstadoActividad.pendiente,
    );
  }
}

class Actividad {
  const Actividad({
    required this.id,
    required this.titulo,
    required this.curso,
    required this.tipo,
    required this.fechaEntrega,
    required this.estado,
  });

  final String id;
  final String titulo;
  final String curso;
  final TipoActividad tipo;
  final DateTime fechaEntrega;
  final EstadoActividad estado;

  bool get esPendiente => estado == EstadoActividad.pendiente;

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: '${json['id'] ?? ''}',
      titulo: '${json['titulo'] ?? ''}',
      curso: '${json['curso'] ?? ''}',
      tipo: TipoActividad.desdeApi('${json['tipo'] ?? 'tarea'}'),
      fechaEntrega:
          DateTime.tryParse('${json['fecha_entrega'] ?? ''}') ?? DateTime.now(),
      estado: EstadoActividad.desdeApi('${json['estado'] ?? 'pendiente'}'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'curso': curso,
      'tipo': tipo.valorApi,
      'fecha_entrega': fechaEntrega.toIso8601String(),
      'estado': estado.valorApi,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Actividad &&
            other.id == id &&
            other.titulo == titulo &&
            other.curso == curso &&
            other.tipo == tipo &&
            other.fechaEntrega == fechaEntrega &&
            other.estado == estado;
  }

  @override
  int get hashCode {
    return Object.hash(id, titulo, curso, tipo, fechaEntrega, estado);
  }
}
