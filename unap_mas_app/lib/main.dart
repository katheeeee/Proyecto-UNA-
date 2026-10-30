import 'package:flutter/material.dart';

import 'screens/registrar_actividad_screen.dart';

void main() => runApp(const UnaPlusApp());

class UnaPlusApp extends StatelessWidget {
  const UnaPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UNA+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: const RegistrarActividadScreen(),
    );
  }
}