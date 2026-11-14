
import 'package:flutter/material.dart';
import '../../servicios/notificaciones_service.dart';
import '../../servicios/horario_service.dart';

class HorarioWidget extends StatefulWidget {
  const HorarioWidget({super.key});

  @override
  State<HorarioWidget> createState() => _HorarioWidgetState();
}

class _HorarioWidgetState extends State<HorarioWidget> {
  final Color colorPrincipal = const Color(0xFF4F46E5);

  final NotificacionesService notificaciones =
      NotificacionesService();

  final HorarioService horarioService = HorarioService();

  // ID del estudiante registrado en la base de datos.
  final int usuarioId = 1;

  int diaSeleccionado = 0;

  bool cargando = true;
  String? error;

  List<Map<String, dynamic>> cursos = [];

  final Set<int> recordatoriosActivos = {};

  final List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
  ];

  @override
  void initState() {
    super.initState();
    cargarHorarios();
  }

  Future<void> cargarHorarios() async {
    setState(() {
      cargando = true;
      error = null;
    });

    try {
      final resultado =
          await horarioService.obtenerHorarios(usuarioId);

      if (!mounted) return;

      setState(() {
        cursos = resultado;
        cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString();
        cargando = false;
      });
    }
  }

  String formatearHora(String hora) {
    final partes = hora.split(':');
    return '${partes[0]}:${partes[1]}';
  }

  int obtenerDia(String dia) {
    return dias.indexOf(dia) + 1;
  }

  Future<void> gestionarRecordatorio(
    Map<String, dynamic> curso,
  ) async {
    final int id = 1000 + int.parse(curso['id'].toString());
    final nombre = curso['curso'].toString();

    try {
      if (recordatoriosActivos.contains(id)) {
        await notificaciones.desactivarRecordatorio(id);

        setState(() {
          recordatoriosActivos.remove(id);
        });

        mostrarMensaje('Recordatorio desactivado');
        return;
      }

      final permiso = await notificaciones.solicitarPermiso();

      if (!permiso) {
        mostrarMensaje(
          'Debes permitir las notificaciones en tu dispositivo',
        );
        return;
      }

      final horaInicio = curso['hora_inicio'].toString();
      final partesHora = horaInicio.split(':');

      final int hora = int.parse(partesHora[0]);
      final int minuto = int.parse(partesHora[1]);

      final int dia = obtenerDia(curso['dia'].toString());

      if (dia < 1 || dia > 7) {
        mostrarMensaje('El día del curso no es válido');
        return;
      }

      await notificaciones.activarRecordatorio(
        id: id,
        curso: nombre,
        aula: curso['aula'].toString(),
        dia: dia,
        hora: hora,
        minuto: minuto,
      );

      setState(() {
        recordatoriosActivos.add(id);
      });

      mostrarMensaje('Notificación programada para $nombre');
    } catch (e) {
      mostrarMensaje('No se pudo programar: $e');
    }
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(mensaje)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final String diaActual = dias[diaSeleccionado];

    final cursosDelDia = cursos
        .where((curso) => curso['dia'] == diaActual)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        title: const Text(
          'Mi horario',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorPrincipal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: cargarHorarios,
            tooltip: 'Actualizar horario',
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 20),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Organiza tu semana académica',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: dias.length,
              itemBuilder: (context, index) {
                final seleccionado = diaSeleccionado == index;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(dias[index]),
                    selected: seleccionado,
                    selectedColor: colorPrincipal,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: seleccionado
                          ? Colors.white
                          : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (_) {
                      setState(() {
                        diaSeleccionado = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          Expanded(
            child: cargando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 45,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No se pudieron cargar los horarios',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error!,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton.icon(
                                onPressed: cargarHorarios,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : cursosDelDia.isEmpty
                        ? const Center(
                            child: Text(
                              'No tienes clases programadas.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: cursosDelDia.length,
                            itemBuilder: (context, index) {
                              final curso = cursosDelDia[index];

                              final int id = 1000 +
                                  int.parse(curso['id'].toString());

                              final nombre =
                                  curso['curso'].toString();

                              final activo =
                                  recordatoriosActivos.contains(id);

                              final hora =
                                  '${formatearHora(curso['hora_inicio'].toString())}'
                                  ' - '
                                  '${formatearHora(curso['hora_fin'].toString())}';

                              return Card(
                                elevation: 2,
                                color: Colors.white,
                                margin: const EdgeInsets.only(
                                  bottom: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombre,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: colorPrincipal,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(hora),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: colorPrincipal,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              curso['aula'].toString(),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const Divider(height: 24),

                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          icon: Icon(
                                            activo
                                                ? Icons.notifications_active
                                                : Icons.notifications_none,
                                          ),
                                          label: Text(
                                            activo
                                                ? 'Desactivar recordatorio'
                                                : 'Activar recordatorio',
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: colorPrincipal,
                                          ),
                                          onPressed: () {
                                            gestionarRecordatorio(curso);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
