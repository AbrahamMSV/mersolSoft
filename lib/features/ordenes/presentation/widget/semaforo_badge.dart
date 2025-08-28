import 'package:flutter/material.dart';
import '../../domain/semaforo_status.dart';

class SemaforoBadge extends StatelessWidget {
  final String? value;     // lo que llega del backend
  final bool dense;        // para hacerlo más compacto si quieres
  const SemaforoBadge({super.key, required this.value, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final status = SemaforoStatusX.parse(value);

    // Paleta mínima (puedes moverla a ThemeExtension luego)
    late final Color base;
    late final IconData icon;
    switch (status) {
      case SemaforoStatus.enTiempo:
        base = Colors.green;
        icon = Icons.check_circle;
        break;
      case SemaforoStatus.retraso:
        base = Colors.amber;
        icon = Icons.schedule;
        break;
      case SemaforoStatus.fueraDeTiempo:
        base = Colors.red;
        icon = Icons.error;
        break;
      case SemaforoStatus.desconocido:
        base = Theme.of(context).colorScheme.outline;
        icon = Icons.help;
        break;
    }

    final bg = base.withOpacity(0.15);
    final pad = dense ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 6);

    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: base),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: base),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: dense ? 12 : 13,
              fontWeight: FontWeight.w600,
              color: base,
            ),
          ),
        ],
      ),
    );
  }
}
