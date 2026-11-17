import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/rutas.dart';
import '../../../core/tema.dart';
import '../../../core/validadores.dart';
import '../providers/auth_provider.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _correoController = TextEditingController();
  final _escuelaController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _ocultarContrasena = true;
  bool _ocultarConfirmacion = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _escuelaController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final exito = await auth.registrar(
      nombreCompleto: _nombreController.text,
      correo: _correoController.text,
      escuelaProfesional: _escuelaController.text,
      contrasena: _contrasenaController.text,
    );

    if (!mounted) {
      return;
    }

    if (exito) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso. Ahora inicia sesión.'),
          ),
        );
      context.go(RutasApp.login);
      return;
    }

    final mensaje = auth.error;
    if (mensaje != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  void _volver() {
    context.read<AuthProvider>().limpiarError();
    context.go(RutasApp.login);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Registro de estudiante',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Completa tus datos para crear tu cuenta UNA+.',
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
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Correo institucional',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: Validadores.correo,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _escuelaController,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
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
                          controller: _contrasenaController,
                          obscureText: _ocultarContrasena,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _ocultarContrasena = !_ocultarContrasena;
                                });
                              },
                              tooltip: _ocultarContrasena
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                              icon: Icon(
                                _ocultarContrasena
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: Validadores.contrasena,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirmarController,
                          obscureText: _ocultarConfirmacion,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _enviar(),
                          decoration: InputDecoration(
                            labelText: 'Confirmar contraseña',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _ocultarConfirmacion = !_ocultarConfirmacion;
                                });
                              },
                              tooltip: _ocultarConfirmacion
                                  ? 'Mostrar contraseña'
                                  : 'Ocultar contraseña',
                              icon: Icon(
                                _ocultarConfirmacion
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (valor) => Validadores.confirmarContrasena(
                            valor,
                            _contrasenaController.text,
                          ),
                        ),
                        if (auth.error != null) ...[
                          const SizedBox(height: 14),
                          _MensajeError(mensaje: auth.error!),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: auth.procesando ? null : _enviar,
                          child: auth.procesando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Registrarme'),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: auth.procesando ? null : _volver,
                          child: const Text('Ya tengo una cuenta'),
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
