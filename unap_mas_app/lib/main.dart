import 'package:flutter/material.dart';

import 'screens/registrar_actividad_screen.dart';
import 'screens/servicios_screen.dart';

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
      home: const InicioScreen(),
    );
  }
}

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  int _indice = 0;

  final List<Widget> _pantallas = const [
    RegistrarActividadScreen(),
    ServiciosScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pantallas[_indice],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (indice) {
          setState(() {
            _indice = indice;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.assignment),
            label: 'Actividades',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance),
            label: 'Servicios',
          ),
        ],
      ),
    );
  }
}
