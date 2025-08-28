import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/locator.dart';
import 'refacciones_controller.dart';
import '../domain/refaccion_item.dart';
import '../../card_refacciones/domain/refaccion_args.dart';
class RefaccionesScreen extends StatefulWidget {
  final int ordenServicioId;
  final int? statusOrderId;
  const RefaccionesScreen({super.key, required this.ordenServicioId,this.statusOrderId});

  @override
  State<RefaccionesScreen> createState() => _RefaccionesScreenState();
}

class _RefaccionesScreenState extends State<RefaccionesScreen> {
  late final RefaccionesController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = locator<RefaccionesController>()..addListener(_onState);
    _ctrl.setOrdenServicioId(widget.ordenServicioId);
    _ctrl.refresh();
  }

  void _onState() => setState(() {});
  @override
  void dispose() { _ctrl.removeListener(_onState); super.dispose(); }
  void _nuevo() {
    context.push(
      '/refacciones/nuevo',
      extra: RefaccionesArgs(
        ordenServicioId: widget.ordenServicioId,
        statusOrderId: widget.statusOrderId,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final loading = _ctrl.loading;
    final error = _ctrl.error;
    final items = _ctrl.items;

    return Scaffold(
      appBar: AppBar(
        title: Text('Refacciones (OS ${widget.ordenServicioId})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final r = GoRouter.of(context);
            if (r.canPop()) r.pop(); else r.go('/ordenes');
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _ctrl.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (!loading && error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(error!, style: const TextStyle(color: Colors.red))),
              ),
            if (!loading && error == null && items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Sin refacciones')),
              ),
            if (!loading && error == null && items.isNotEmpty)
              ...items.map((r) => _RefCard(item: r)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _nuevo,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RefCard extends StatelessWidget {
  final RefaccionItem item;
  const _RefCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Mostrar solo: Cantidad, Articulo y Refaccion (en ese orden)
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cantidad: ${item.cantidad}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('Artículo: ${item.articulo}'),
            const SizedBox(height: 6),
            Text('Refacción: ${item.refaccion}'),
          ],
        ),
      ),
    );
  }
}
