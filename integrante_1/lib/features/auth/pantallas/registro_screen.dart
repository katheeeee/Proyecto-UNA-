import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/rutas.dart';
import '../../../core/tema.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: TemaApp.azulClaro,
                      child: Icon(
                        Icons.person_add_alt_1_outlined,
                        size: 36,
                        color: TemaApp.azulInstitucional,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Registro de estudiante',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El formulario completo se habilita en el Paso 3.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: TemaApp.textoSecundario),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.go(RutasApp.login),
                      child: const Text('Volver al inicio de sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
