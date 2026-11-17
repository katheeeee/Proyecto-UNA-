
class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final bool estado;
  final String fechaActualizacion;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    required this.fechaActualizacion,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      estado: json['estado'],
      fechaActualizacion: json['fecha_actualizacion'],
    );
  }
}
