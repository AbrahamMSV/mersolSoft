import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/locator.dart';
import '../domain/diagnostico_item.dart';
import 'diagnostico_controller.dart';

class DiagnosticoScreen extends StatefulWidget {
  final int ordenServicioId;
  const DiagnosticoScreen({super.key, required this.ordenServicioId});

  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoScreenState();
}

class _DiagnosticoScreenState extends State<DiagnosticoScreen> {
  late final DiagnosticoController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = locator<DiagnosticoController>()..addListener(_onState);
    _ctrl.setOrdenServicioId(widget.ordenServicioId);
    _ctrl.refresh();
  }

  void _onState() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_onState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = _ctrl.loading;
    final error = _ctrl.error;
    final items = _ctrl.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnóstico - Órdenes de Servicio'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              router.go('/ordenes'); // fallback si llegaste con go/DEEPLINK
            }
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
                child: Center(child: Text('Sin registros')),
              ),
            if (!loading && error == null && items.isNotEmpty)
              ...items.map((d) => _DiagnosticoCard(item: d)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nuevo diagnóstico'),
        onPressed: () async {
          // usamos push para poder esperar el resultado y refrescar al volver
          await context.push('/diagnosticos/nuevo', extra: widget.ordenServicioId);
          if (mounted) _ctrl.refresh(); // refresca la lista al regresar
        },
      ),
    );
  }
}

class _DiagnosticoCard extends StatelessWidget {
  final DiagnosticoItem item;
  const _DiagnosticoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Diagnóstico', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(item.diagnostico),
            const SizedBox(height: 8),
            Text('Fecha: ${item.fechaPartida}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_camera),
                label: const Text('Fotografía'),
                // POR AHORA: navegamos a un placeholder pasando DiagnosticoID.
                // En el siguiente paso conectaremos esto con el feature de fotografía
                // para sustituir el hardcode 13 por item.diagnosticoId.
                onPressed: () => context.push('/diagnosticos/foto', extra: item.diagnosticoId),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
