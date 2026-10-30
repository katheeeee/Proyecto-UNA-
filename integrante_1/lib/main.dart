import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/almacen_sesion.dart';
import 'core/rutas.dart';
import 'core/tema.dart';
import 'features/auth/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final almacen = AlmacenSesion();
  final auth = AuthProvider(almacen);
  await auth.init();

  runApp(UNAPlusApp(almacen: almacen, auth: auth));
}

class UNAPlusApp extends StatefulWidget {
  const UNAPlusApp({super.key, required this.almacen, required this.auth});

  final AlmacenSesion almacen;
  final AuthProvider auth;

  @override
  State<UNAPlusApp> createState() => _UNAPlusAppState();
}

class _UNAPlusAppState extends State<UNAPlusApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = crearRouter(widget.auth);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AlmacenSesion>.value(value: widget.almacen),
        ChangeNotifierProvider<AuthProvider>.value(value: widget.auth),
      ],
      child: MaterialApp.router(
        title: 'UNA+',
        debugShowCheckedModeBanner: false,
        theme: TemaApp.claro,
        routerConfig: _router,
      ),
    );
  }
}
