import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/rutas.dart';
import '../../../core/tema.dart';
import '../../../core/validadores.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/perfil_provider.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _escuelaController;
  late final TextEditingController _correoController;

  @override
  void initState() {
    super.initState();
    final usuario = context.read<AuthProvider>().usuario;
    _nombreController = TextEditingController(
      text: usuario?.nombreCompleto ?? '',
    );
    _escuelaController = TextEditingController(
      text: usuario?.escuelaProfesional ?? '',
    );
    _correoController = TextEditingController(text: usuario?.correo ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _escuelaController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final perfil = context.read<PerfilProvider>();
    final exito = await perfil.actualizar(
      nombreCompleto: _nombreController.text,
      escuelaProfesional: _escuelaController.text,
    );

    if (!mounted || !exito) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RutasApp.perfil);
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfil = context.watch<PerfilProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Datos personales',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Actualiza tu nombre y tu escuela profesional.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: TemaApp.textoSecundario),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nombreController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (valor) => Validadores.obligatorio(
                            valor,
                            campo: 'tu nombre completo',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _escuelaController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _guardar(),
                          decoration: const InputDecoration(
                            labelText: 'Escuela profesional',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          validator: (valor) => Validadores.obligatorio(
                            valor,
                            campo: 'tu escuela profesional',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _correoController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Correo institucional',
                            prefixIcon: Icon(Icons.mail_outline),
                            helperText: 'El correo no se puede modificar.',
                          ),
                        ),
                        if (perfil.error != null) ...[
                          const SizedBox(height: 14),
                          _MensajeError(mensaje: perfil.error!),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: perfil.guardando ? null : _guardar,
                          child: perfil.guardando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Guardar cambios'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: perfil.guardando
                              ? null
                              : () => context.pop(),
                          child: const Text('Cancelar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 20,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
