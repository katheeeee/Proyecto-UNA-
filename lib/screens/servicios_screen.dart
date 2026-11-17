
import 'package:flutter/material.dart';
import '../models/servicio.dart';
import '../services/servicio_service.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final ServicioService _service = ServicioService();

  late Future<List<Servicio>> _servicios;

  @override
  void initState() {
    super.initState();
    _servicios = _service.obtenerServicios();
  }

  void _recargar() {
    setState(() {
      _servicios = _service.obtenerServicios();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios universitarios'),
        actions: [
          IconButton(
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Servicio>>(
        future: _servicios,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar servicios: ${snapshot.error}'),
            );
          }

          final servicios = snapshot.data ?? [];

          if (servicios.isEmpty) {
            return const Center(
              child: Text('No hay servicios disponibles.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: servicios.length,
            itemBuilder: (context, index) {
              final servicio = servicios[index];

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.account_balance,
                    color: Colors.blue,
                  ),
                  title: Text(servicio.nombre),
                  subtitle: Text(
                    '${servicio.descripcion}\nCategoría: ${servicio.categoria}',
                  ),
                  isThreeLine: true,
                  trailing: Icon(
                    servicio.estado ? Icons.check_circle : Icons.cancel,
                    color: servicio.estado ? Colors.green : Colors.red,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
