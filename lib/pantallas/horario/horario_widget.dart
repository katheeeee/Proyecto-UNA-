import 'package:flutter/material.dart';
import '../../servicios/notificaciones_service.dart';

class HorarioWidget extends StatefulWidget {
  const HorarioWidget({super.key});

  @override
  State<HorarioWidget> createState() => _HorarioWidgetState();
}

class _HorarioWidgetState extends State<HorarioWidget> {
  final Color colorPrincipal = const Color(0xFF4F46E5);
  final NotificacionesService notificaciones = NotificacionesService();

  int diaSeleccionado = 0;

  final Set<String> recordatoriosActivos = {};

  final List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
  ];

  final List<Map<String, String>> cursos = [
    {
      'dia': 'Lunes',
      'curso': 'Ingeniería de Software',
      'hora': '08:00 - 10:00',
      'aula': 'Aula 204',
    },
    {
      'dia': 'Lunes',
      'curso': 'Sistemas Operativos',
      'hora': '10:00 - 12:00',
      'aula': 'Laboratorio 3',
    },
    {
      'dia': 'Martes',
      'curso': 'Base de Datos',
      'hora': '14:00 - 16:00',
      'aula': 'Aula 105',
    },
    {
      'dia': 'Miércoles',
      'curso': 'Ingeniería de Software',
      'hora': '08:00 - 10:00',
      'aula': 'Aula 204',
    },
    {
      'dia': 'Jueves',
      'curso': 'Sistemas Operativos',
      'hora': '10:00 - 12:00',
      'aula': 'Laboratorio 3',
    },
    {
      'dia': 'Viernes',
      'curso': 'Base de Datos',
      'hora': '14:00 - 16:00',
      'aula': 'Aula 105',
    },
  ];

  Future<void> gestionarRecordatorio(
    Map<String, String> curso,
    String diaActual,
  ) async {
    final nombre = curso['curso']!;
    final clave = '$diaActual-$nombre';
    final id = 100 + cursos.indexOf(curso);

    try {
      if (recordatoriosActivos.contains(clave)) {
        await notificaciones.desactivarRecordatorio(id);

        setState(() {
          recordatoriosActivos.remove(clave);
        });

        mostrarMensaje('Recordatorio desactivado');
        return;
      }

      final permiso = await notificaciones.solicitarPermiso();

      if (!permiso) {
        mostrarMensaje('Debes permitir las notificaciones en tu dispositivo');
        return;
      }

      final partesHora = curso['hora']!.split(' - ')[0].split(':');
      final hora = int.parse(partesHora[0]);
      final minuto = int.parse(partesHora[1]);
      final dia = dias.indexOf(diaActual) + 1;

      await notificaciones.activarRecordatorio(
        id: id,
        curso: nombre,
        aula: curso['aula']!,
        dia: dia,
        hora: hora,
        minuto: minuto,
      );

      setState(() {
        recordatoriosActivos.add(clave);
      });

      mostrarMensaje('Notificación programada para $nombre');
    } catch (e) {
      mostrarMensaje('No se pudo programar la notificación: $e');
    }
  }

  void mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorPrincipal,
        centerTitle: true,
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      color: seleccionado ? Colors.white : Colors.black87,
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
            child: cursosDelDia.isEmpty
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
                      final nombre = curso['curso']!;
                      final clave = '$diaActual-$nombre';
                      final activo = recordatoriosActivos.contains(clave);

                      return Card(
                        elevation: 2,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Text(curso['hora']!),
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
                                  Text(curso['aula']!),
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
                                    gestionarRecordatorio(curso, diaActual);
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
