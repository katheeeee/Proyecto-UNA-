import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constantes.dart';
import '../../../core/rutas.dart';
import '../../../core/tema.dart';
import '../../../core/validadores.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  bool _ocultarContrasena = true;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final exito = await auth.iniciarSesion(
      correo: _correoController.text,
      contrasena: _contrasenaController.text,
    );

    if (!mounted || exito) {
      return;
    }

    final mensaje = auth.error;
    if (mensaje != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensaje)));
    }
  }

  void _irARegistro() {
    context.read<AuthProvider>().limpiarError();
    context.go(RutasApp.registro);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Encabezado(),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Iniciar sesión',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Accede con tu correo institucional',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: TemaApp.textoSecundario),
                            ),
                            const SizedBox(height: 20),
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
                              controller: _contrasenaController,
                              obscureText: _ocultarContrasena,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _enviar(),
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
                                  : const Text('Ingresar'),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: auth.procesando ? null : _irARegistro,
                              child: const Text(
                                '¿No tienes cuenta? Regístrate',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Datos de prueba: ${Constantes.correoPrueba} / ${Constantes.contrasenaPrueba}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: TemaApp.textoSecundario),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: TemaApp.azulInstitucional,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(
            Icons.school_outlined,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'UNA+',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: TemaApp.azulInstitucional,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Universidad Nacional del Altiplano',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: TemaApp.textoSecundario),
        ),
      ],
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
