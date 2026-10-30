/// Modelo de datos de una tarea o evaluación.
class Actividad {
  final String titulo;
  final String tipo; // tarea, examen, proyecto, trabajo grupal
  final String curso;
  final DateTime fechaEntrega;

  const Actividad({
    required this.titulo,
    required this.tipo,
    required this.curso,
    required this.fechaEntrega,
  });
}