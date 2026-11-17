import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/almacen_sesion.dart';
import 'core/cliente_dio.dart';
import 'core/constantes.dart';
import 'core/rutas.dart';
import 'core/tema.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/repositorios/repositorio_auth.dart';
import 'features/auth/repositorios/repositorio_auth_api.dart';
import 'features/auth/repositorios/repositorio_auth_mock.dart';
import 'features/inicio/providers/inicio_provider.dart';
import 'features/perfil/providers/perfil_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final almacen = AlmacenSesion();
  final cliente = ClienteDio(almacen);
  final RepositorioAuth repositorio = Constantes.usarDatosMock
      ? RepositorioAuthMock()
      : RepositorioAuthApi(cliente);
  final auth = AuthProvider(repositorio, almacen);
  cliente.onTokenExpirado = auth.cerrarSesion;
  await auth.init();

  runApp(UNAPlusApp(almacen: almacen, auth: auth, repositorio: repositorio));
}

class UNAPlusApp extends StatefulWidget {
  const UNAPlusApp({
    super.key,
    required this.almacen,
    required this.auth,
    required this.repositorio,
  });

  final AlmacenSesion almacen;
  final AuthProvider auth;
  final RepositorioAuth repositorio;

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
        Provider<RepositorioAuth>.value(value: widget.repositorio),
        ChangeNotifierProvider<AuthProvider>.value(value: widget.auth),
        ChangeNotifierProvider<PerfilProvider>(
          create: (context) => PerfilProvider(
            context.read<RepositorioAuth>(),
            context.read<AuthProvider>(),
          ),
        ),
        ChangeNotifierProvider<InicioProvider>(
          create: (context) => InicioProvider(
            context.read<RepositorioAuth>(),
            context.read<AuthProvider>(),
          ),
        ),
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
