import 'package:flutter/material.dart';

/// Envuelve cualquier UI y, si [loading] es true, la difumina/bloquea
/// y muestra un spinner centrado.
/// Úsalo así: LoadingOverlay(loading: isBusy, child: tuContenido)
class LoadingOverlay extends StatelessWidget {
  final bool loading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.loading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final overlay = Stack(
      children: [
        // Contenido base: pierde interacción y se "atenúa" cuando loading
        IgnorePointer(
          ignoring: loading,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: loading ? 0.4 : 1.0,
            child: child,
          ),
        ),
        // Capa de bloqueo + spinner
        if (loading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 42, height: 42,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      message!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
    return overlay;
  }
}
class LoadingButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;
  final String label;
  const LoadingButton({super.key, required this.loading, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: loading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (w, a) => FadeTransition(opacity: a, child: w),
        child: loading
            ? const SizedBox(key: ValueKey('pb'), width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label, key: const ValueKey('tx')),
      ),
    );
  }
}

/// Helper reutilizable: envuelve [child] con overlay de carga.
/// Úsalo si prefieres una función en vez del widget.
/// withLoadingOverlay(loading: isBusy, child: contenido)
Widget withLoadingOverlay({required bool loading, required Widget child, String? message}) {
  return LoadingOverlay(loading: loading, child: child, message: message);
}
