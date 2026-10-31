import 'package:flutter/material.dart';
import 'pantallas/horario/horario_widget.dart';
import 'servicios/notificaciones_service.dart';

final NotificacionesService servicioNotificaciones = NotificacionesService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await servicioNotificaciones.inicializar();

  runApp(const UnaMasApp());
}

class UnaMasApp extends StatelessWidget {
  const UnaMasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UNA+',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const HorarioWidget(),
    );
  }
}
