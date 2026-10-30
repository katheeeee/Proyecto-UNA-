import 'package:flutter/material.dart';

import '../models/actividad.dart';
import '../services/actividad_service.dart';

/// Pantalla con el formulario de registro y la lista de actividades.
class RegistrarActividadScreen extends StatefulWidget {
  const RegistrarActividadScreen({super.key});

  @override
  State<RegistrarActividadScreen> createState() =>
      _RegistrarActividadScreenState();
}

class _RegistrarActividadScreenState extends State<RegistrarActividadScreen> {
  final _service = ActividadService();
  final _tituloCtrl = TextEditingController();
  final _cursoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();

  String? _tipo;
  String? _error;
  final List<Actividad> _actividades = [];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _cursoCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  /// Recibe los datos del formulario y presenta el resultado.
  void _registrar() {
    try {
      final actividad = _service.registrarActividad(
        titulo: _tituloCtrl.text,
        tipo: _tipo,
        curso: _cursoCtrl.text,
        fechaEntrega: _fechaCtrl.text,
      );
      setState(() {
        _actividades.add(actividad);
        _error = null;
        _tituloCtrl.clear();
        _cursoCtrl.clear();
        _fechaCtrl.clear();
        _tipo = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Actividad registrada correctamente')),
      );
    } on ValidacionException catch (e) {
      setState(() => _error = e.mensaje);
    }
  }

  Future<void> _elegirFecha() async {
    final ahora = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: ahora,
      // Se permiten fechas pasadas a propósito para poder probar el caso
      // inválido; el servicio es quien las rechaza.
      firstDate: DateTime(ahora.year - 1),
      lastDate: DateTime(ahora.year + 5),
    );
    if (elegida != null) {
      final mes = elegida.month.toString().padLeft(2, '0');
      final dia = elegida.day.toString().padLeft(2, '0');
      setState(() => _fechaCtrl.text = '${elegida.year}-$mes-$dia');
    }
  }

  String _capitalizar(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar tarea o evaluación')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _tituloCtrl,
            decoration: const InputDecoration(
              labelText: 'Título',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Tipo de actividad',
              border: OutlineInputBorder(),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _tipo,
                isExpanded: true,
                isDense: true,
                hint: const Text('Selecciona un tipo'),
                items: ActividadService.tiposValidos
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_capitalizar(t)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _tipo = v),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cursoCtrl,
            decoration: const InputDecoration(
              labelText: 'Curso',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _fechaCtrl,
            readOnly: true,
            onTap: _elegirFecha,
            decoration: const InputDecoration(
              labelText: 'Fecha de entrega (AAAA-MM-DD)',
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _registrar,
            icon: const Icon(Icons.save),
            label: const Text('Registrar'),
          ),
          const SizedBox(height: 24),
          Text(
            'Actividades registradas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_actividades.isEmpty)
            const Text('Aún no hay actividades registradas.'),
          ..._actividades.map(
            (a) => Card(
              child: ListTile(
                leading: const Icon(Icons.assignment),
                title: Text(a.titulo),
                subtitle: Text(
                  '${_capitalizar(a.tipo)} · ${a.curso}\nEntrega: ${formatearFechaLatina(a.fechaEntrega)}',
                ),
                isThreeLine: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
