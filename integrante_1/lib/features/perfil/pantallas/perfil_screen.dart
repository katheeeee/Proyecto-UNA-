import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/rutas.dart';
import '../../../core/tema.dart';
import '../../auth/modelos/usuario.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/perfil_provider.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  Future<void> _cerrarSesion(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Seguro que deseas salir de tu cuenta UNA+?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) {
      return;
    }

    await context.read<AuthProvider>().cerrarSesion();
  }

  void _editar(BuildContext context) {
    context.read<PerfilProvider>().limpiarError();
    context.push(RutasApp.editarPerfil);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final perfil = context.watch<PerfilProvider>();
    final usuario = auth.usuario;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            onPressed: usuario == null ? null : () => _editar(context),
            tooltip: 'Editar perfil',
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: usuario == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TarjetaEncabezado(usuario: usuario),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Datos académicos',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 16),
                              _FilaDato(
                                icono: Icons.mail_outline,
                                etiqueta: 'Correo institucional',
                                valor: usuario.correo,
                              ),
                              const SizedBox(height: 14),
                              _FilaDato(
                                icono: Icons.school_outlined,
                                etiqueta: 'Escuela profesional',
                                valor: usuario.escuelaProfesional,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (perfil.error != null) ...[
                        const SizedBox(height: 14),
                        _MensajeError(mensaje: perfil.error!),
                      ],
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => _editar(context),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar perfil'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _cerrarSesion(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _TarjetaEncabezado extends StatelessWidget {
  const _TarjetaEncabezado({required this.usuario});

  final Usuario usuario;

  String get _iniciales {
    final partes = usuario.nombreCompleto
        .trim()
        .split(RegExp(r'\s+'))
        .where((parte) => parte.isNotEmpty)
        .toList();
    if (partes.isEmpty) {
      return '?';
    }
    if (partes.length == 1) {
      return partes.first.substring(0, 1).toUpperCase();
    }
    final primera = partes.first.substring(0, 1);
    final ultima = partes.last.substring(0, 1);
    return '$primera$ultima'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: TemaApp.azulClaro,
              child: Text(
                _iniciales,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: TemaApp.azulInstitucional,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              usuario.nombreCompleto,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              usuario.correo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: TemaApp.textoSecundario),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: TemaApp.azulClaro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Estudiante UNA',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: TemaApp.azulInstitucional,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  final IconData icono;
  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: TemaApp.azulClaro,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, size: 20, color: TemaApp.azulInstitucional),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                etiqueta,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: TemaApp.textoSecundario),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
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
