import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/locator.dart';
import '../domain/order_status_args.dart';
import 'order_status_controller.dart';

class OrderStatusScreen extends StatefulWidget {
  final OrderStatusArgs args;
  const OrderStatusScreen({super.key, required this.args});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  late final OrderStatusController _ctrl;
  final _commentCtl = TextEditingController();
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = locator<OrderStatusController>()..addListener(_onState);
    _ctrl.setInitialStatus(widget.args.statusOrderId); // puede ser null => "sin permisos"
  }

  void _onState() => setState(() {});
  @override
  void dispose() { _ctrl.removeListener(_onState); _commentCtl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final meta = _ctrl.meta;
    final canAct = _ctrl.canAct;
    final loading = _ctrl.loading;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // Si el sistema YA hizo pop (gesto/flecha), no hagas nada extra.
        if (didPop) return;
        // Si lo manejas tú, devuelve el resultado al caller (olts_screen)
        context.pop(_changed); // _changed == true cuando hiciste PUT ok
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Estatus OS ${widget.args.ordenServicioId}'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              final r = GoRouter.of(context);
              if (r.canPop()) {
                r.pop(_changed); // devuelve true si hubo cambio
              } else {
                r.go('/olts');
              }
            },
          ),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(meta.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(meta.description),
            const SizedBox(height: 16),

            TextField(
              controller: _commentCtl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                border: OutlineInputBorder(),
              ),
              onChanged: _ctrl.setComentario,
            ),

            const SizedBox(height: 24),
            if (_ctrl.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_ctrl.error!, style: const TextStyle(color: Colors.red)),
              ),

            if (canAct && meta.cta != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync),
                  label: Text(loading ? 'Actualizando...' : meta.cta!),
                  onPressed: loading
                      ? null
                      : () async {
                    final ok = await _ctrl.doAction(widget.args.ordenServicioId);
                    if (!mounted) return;
                    if (ok) {
                      _changed = true; // para que al volver OLTs se refresque
                    }
                    final msg = ok ? 'Estatus actualizado' : (_ctrl.error ?? 'No se pudo actualizar');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                  },
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
