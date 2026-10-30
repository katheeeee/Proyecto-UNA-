import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/pantallas/login_screen.dart';
import '../features/auth/pantallas/registro_screen.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/inicio/pantallas/inicio_screen.dart';
import '../features/perfil/pantallas/editar_perfil_screen.dart';
import '../features/perfil/pantallas/perfil_screen.dart';
import 'tema.dart';

class RutasApp {
  static const String login = '/login';
  static const String registro = '/registro';
  static const String inicio = '/inicio';
  static const String perfil = '/perfil';
  static const String editarPerfil = '/perfil/editar';
}

GoRouter crearRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: RutasApp.login,
    refreshListenable: auth,
    redirect: (context, state) {
      final autenticado = auth.autenticado;
      final ubicacion = state.matchedLocation;
      final enAutenticacion =
          ubicacion == RutasApp.login || ubicacion == RutasApp.registro;

      if (!autenticado && !enAutenticacion) {
        return RutasApp.login;
      }
      if (autenticado && enAutenticacion) {
        return RutasApp.inicio;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: RutasApp.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RutasApp.registro,
        builder: (context, state) => const RegistroScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _ShellNavegacion(
            ubicacion: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: RutasApp.inicio,
            builder: (context, state) => const InicioScreen(),
          ),
          GoRoute(
            path: RutasApp.perfil,
            builder: (context, state) => const PerfilScreen(),
          ),
        ],
      ),
      GoRoute(
        path: RutasApp.editarPerfil,
        builder: (context, state) => const EditarPerfilScreen(),
      ),
    ],
  );
}

class _ShellNavegacion extends StatelessWidget {
  const _ShellNavegacion({required this.ubicacion, required this.child});

  final String ubicacion;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final indice = ubicacion == RutasApp.perfil ? 1 : 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: TemaApp.bordeSuave)),
        ),
        child: NavigationBar(
          selectedIndex: indice,
          onDestinationSelected: (nuevoIndice) {
            final destino = nuevoIndice == 0
                ? RutasApp.inicio
                : RutasApp.perfil;
            context.go(destino);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
