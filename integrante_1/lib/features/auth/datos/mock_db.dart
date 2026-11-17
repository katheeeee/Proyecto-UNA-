import '../modelos/actividad.dart';
import '../modelos/usuario.dart';

class MockDb {
  MockDb({DateTime? ahora}) {
    final referencia = ahora ?? DateTime.now();
    _usuarios[normalizarCorreo(usuarioPrueba.correo)] = usuarioPrueba;
    _contrasenas[normalizarCorreo(usuarioPrueba.correo)] = contrasenaPrueba;
    _actividades.addAll(_crearActividades(referencia));
  }

  final Usuario usuarioPrueba = const Usuario(
    id: '1',
    nombreCompleto: 'Ana Quispe Mamani',
    correo: 'estudiante@una.edu.pe',
    escuelaProfesional: 'Ingeniería de Sistemas',
  );

  static const String contrasenaPrueba = '12345678';

  final Map<String, Usuario> _usuarios = {};
  final Map<String, String> _contrasenas = {};
  final List<Actividad> _actividades = [];
  int _siguienteId = 2;

  String normalizarCorreo(String correo) => correo.trim().toLowerCase();

  Usuario? buscarPorCorreo(String correo) {
    return _usuarios[normalizarCorreo(correo)];
  }

  bool existeCorreo(String correo) {
    return _usuarios.containsKey(normalizarCorreo(correo));
  }

  bool validarContrasena(String correo, String contrasena) {
    return _contrasenas[normalizarCorreo(correo)] == contrasena;
  }

  Usuario? buscarPorId(String id) {
    for (final usuario in _usuarios.values) {
      if (usuario.id == id) {
        return usuario;
      }
    }
    return null;
  }

  Usuario agregarUsuario({
    required String nombreCompleto,
    required String correo,
    required String escuelaProfesional,
    required String contrasena,
  }) {
    final clave = normalizarCorreo(correo);
    final usuario = Usuario(
      id: '${_siguienteId++}',
      nombreCompleto: nombreCompleto.trim(),
      correo: clave,
      escuelaProfesional: escuelaProfesional.trim(),
    );
    _usuarios[clave] = usuario;
    _contrasenas[clave] = contrasena;
    return usuario;
  }

  Usuario actualizarUsuario({
    required String id,
    required String nombreCompleto,
    required String escuelaProfesional,
  }) {
    final actual = buscarPorId(id);
    if (actual == null) {
      throw StateError('Usuario no encontrado');
    }
    final actualizado = actual.copyWith(
      nombreCompleto: nombreCompleto.trim(),
      escuelaProfesional: escuelaProfesional.trim(),
    );
    _usuarios[normalizarCorreo(actualizado.correo)] = actualizado;
    return actualizado;
  }

  List<Actividad> actividadesPendientes() {
    final pendientes =
        _actividades
            .where((actividad) => actividad.estado == EstadoActividad.pendiente)
            .toList()
          ..sort((a, b) => a.fechaEntrega.compareTo(b.fechaEntrega));
    return List.unmodifiable(pendientes);
  }

  String generarToken(Usuario usuario) => 'mock-token-${usuario.id}';

  Usuario? usuarioDesdeToken(String token) {
    if (!token.startsWith('mock-token-')) {
      return null;
    }
    return buscarPorId(token.substring('mock-token-'.length));
  }

  List<Actividad> _crearActividades(DateTime referencia) {
    DateTime enDia(int dias, int hora, [int minuto = 0]) {
      final base = DateTime(
        referencia.year,
        referencia.month,
        referencia.day,
      ).add(Duration(days: dias));
      return DateTime(base.year, base.month, base.day, hora, minuto);
    }

    return [
      Actividad(
        id: 'a1',
        titulo: 'Resolver ejercicios de límites',
        curso: 'Cálculo Diferencial',
        tipo: TipoActividad.tarea,
        fechaEntrega: enDia(0, 23, 59),
        estado: EstadoActividad.pendiente,
      ),
      Actividad(
        id: 'a2',
        titulo: 'Examen parcial de cinemática',
        curso: 'Física I',
        tipo: TipoActividad.evaluacion,
        fechaEntrega: enDia(1, 8),
        estado: EstadoActividad.pendiente,
      ),
      Actividad(
        id: 'a3',
        titulo: 'Avance del trabajo grupal',
        curso: 'Estadística Aplicada',
        tipo: TipoActividad.trabajoGrupal,
        fechaEntrega: enDia(2, 14),
        estado: EstadoActividad.pendiente,
      ),
      Actividad(
        id: 'a4',
        titulo: 'Entrega del proyecto final',
        curso: 'Programación Web',
        tipo: TipoActividad.proyecto,
        fechaEntrega: enDia(4, 18),
        estado: EstadoActividad.pendiente,
      ),
      Actividad(
        id: 'a5',
        titulo: 'Informe de laboratorio',
        curso: 'Química General',
        tipo: TipoActividad.tarea,
        fechaEntrega: enDia(6, 10),
        estado: EstadoActividad.pendiente,
      ),
      Actividad(
        id: 'a6',
        titulo: 'Evaluación de comprensión',
        curso: 'Inglés Técnico',
        tipo: TipoActividad.evaluacion,
        fechaEntrega: enDia(9, 16),
        estado: EstadoActividad.pendiente,
      ),
    ];
  }
}
