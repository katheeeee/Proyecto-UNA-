import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/formato_fechas.dart';
import '../../../core/tema.dart';
import '../../auth/modelos/actividad.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/inicio_provider.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InicioProvider>().cargar();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final inicio = context.watch<InicioProvider>();
    final nombre = auth.usuario?.nombreCompleto ?? 'estudiante';
    final primerNombre = nombre.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: TemaApp.azulInstitucional,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('UNA+'),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.dashboard_outlined,
                      size: 56,
                      color: TemaApp.azulInstitucional,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Resumen de actividades',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hola, $primerNombre',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: TemaApp.textoSecundario,
                          ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _Contador(
                            icono: Icons.today_outlined,
                            etiqueta: 'Para hoy',
                            cantidad: inicio.cantidadHoy,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _Contador(
                            icono: Icons.event_outlined,
                            etiqueta: 'Próximos 7 días',
                            cantidad: inicio.cantidadSemana,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (inicio.cargando)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      )
                    else if (inicio.error != null)
                      Text(
                        inicio.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      )
                    else if (inicio.actividades.isEmpty)
                      const Text('No tienes actividades pendientes.')
                    else
                      ..._items(inicio.actividades),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _items(List<Actividad> actividades) {
    final widgets = <Widget>[];
    for (final actividad in actividades) {
      widgets.add(
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.assignment_outlined, color: TemaApp.azulInstitucional),
          title: Text(actividad.titulo),
          subtitle: Text(
            '${actividad.curso} · ${_etiqueta(actividad.tipo)}',
          ),
          trailing: Text(
            FormatoFechas.fechaCorta(actividad.fechaEntrega),
            style: const TextStyle(color: TemaApp.textoSecundario),
          ),
        ),
      );
      widgets.add(const Divider(height: 1));
    }
    return widgets;
  }

  String _etiqueta(TipoActividad tipo) {
    switch (tipo) {
      case TipoActividad.evaluacion:
        return 'Evaluación';
      case TipoActividad.trabajoGrupal:
        return 'Trabajo grupal';
      case TipoActividad.proyecto:
        return 'Proyecto';
      case TipoActividad.tarea:
        return 'Tarea';
    }
  }
}

class _Contador extends StatelessWidget {
  const _Contador({
    required this.icono,
    required this.etiqueta,
    required this.cantidad,
  });

  final IconData icono;
  final String etiqueta;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TemaApp.azulClaro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icono, color: TemaApp.azulInstitucional),
          const SizedBox(height: 6),
          Text(
            '$cantidad',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: TemaApp.azulInstitucional,
            ),
          ),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: TemaApp.textoSecundario),
          ),
        ],
      ),
    );
  }
}
