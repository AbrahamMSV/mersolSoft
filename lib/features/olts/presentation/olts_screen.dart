import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/di/locator.dart';
import 'olts_controller.dart';
import '../domain/olt_host.dart';
import 'package:go_router/go_router.dart';
import '../../olts/domain/olt_host.dart';
import '../../order_status/domain/order_status_args.dart';

class OltsScreen extends StatefulWidget {
  const OltsScreen({super.key});
  @override State<OltsScreen> createState() => _OltsScreenState();
}

class _OltsScreenState extends State<OltsScreen> {
  late final OltsController _ctrl;
  final _searchCtl = TextEditingController();
  final Set<int> _revealPassIds = {}; // IDs con pass visible

  @override
  void initState() {
    super.initState();
    _ctrl = locator<OltsController>();
    _ctrl.addListener(_onState);
    _ctrl.refresh();
  }

  void _onState() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_onState);
    _searchCtl.dispose();
    super.dispose();
  }

  void _toggleReveal(int id) {
    setState(() {
      if (_revealPassIds.contains(id)) {
        _revealPassIds.remove(id);
      } else {
        _revealPassIds.add(id);
      }
    });
  }
  void _refreshOlts() {
    _ctrl.refresh(); // tu método existente de recarga
  }

  @override
  Widget build(BuildContext context) {
    final loading = _ctrl.loading;
    final error = _ctrl.error;
    final items = _ctrl.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordenes Asignadas'),
        actions: [
          PopupMenuButton<OltSort>(
            initialValue: _ctrl.sort,
            onSelected: (s) => _ctrl.sort = s,
            itemBuilder: (context) => const [
              PopupMenuItem(value: OltSort.oltAsc,  child: Text('Ordenar Fecha ↑')),
              PopupMenuItem(value: OltSort.oltDesc, child: Text('Ordenar Fecha ↓'))
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _ctrl.refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchCtl,
              decoration: const InputDecoration(
                labelText: 'Buscar (usuario, IP, OLT)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (t) => _ctrl.query = t,
            ),
            const SizedBox(height: 12),

            if (loading) const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(),
            )),

            if (!loading && error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text(error!, style: const TextStyle(color: Colors.red))),
              ),

            if (!loading && error == null && items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Sin resultados')),
              ),

            if (!loading && error == null && items.isNotEmpty)
              ...items.map((o) => _OltCard(
                item: o,
                onChanged:_refreshOlts,
                revealed: _revealPassIds.contains(o.asignadaId),
                onToggleReveal: () => _toggleReveal(o.asignadaId),
              )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OltCard extends StatelessWidget {
  final OltHost item;
  final VoidCallback onChanged;
  final bool revealed;
  final VoidCallback onToggleReveal;

  const _OltCard({required this.item,required this.onChanged, required this.revealed, required this.onToggleReveal});

  @override
  Widget build(BuildContext context) {
    final passText = revealed ? item.folio : '•' * (item.folio.length.clamp(4, 16));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text('Ordenes ${item.asignadaId}', style: Theme.of(context).textTheme.titleMedium)),
              Chip(label: Text(item.folio)),
              IconButton(tooltip: 'Copiar IP', icon: const Icon(Icons.copy), onPressed: () { /* copiar IP */ }),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person, size: 18), const SizedBox(width: 6),
              Expanded(child: Text('Folio: ${item.folio}'))
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.lock, size: 18), const SizedBox(width: 6),
              Expanded(child: Text('Fecha: ${item.fechaRecepcion}')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person,size: 18),const SizedBox(width: 6),
              Expanded(child: Text('Recibe: ${item.recibe}'))
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person,size: 18),const SizedBox(width: 6),
              Expanded(child: Text('Tipo Servicio: ${item.tipoServicio}'))
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person,size: 16),const SizedBox(width: 6),
              Expanded(child: Text('Articulo: ${item.articulo}'))
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person,size: 16),const SizedBox(width: 6),
              Expanded(child: Text('Marca: ${item.marca}'))
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.person,size: 16),const SizedBox(width: 6),
              Expanded(child: Text('Semaforo: ${item.semaforo}'))
            ]),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.assignment),
                  label: const Text('Diagnóstico'),
                  onPressed: () {
                    final osId = item.ordenServicioId;
                    if (osId == null || osId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Este OLT no tiene OrdenServicioID')),
                      );
                      return;
                    }
                    context.push('/diagnosticos', extra: osId);
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.build),
                  label: const Text('Refacciones'),
                  onPressed: () {
                    final osId = item.ordenServicioId;
                    if (osId == null || osId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Este OLT no tiene OrdenServicioID')),
                      );
                      return;
                    }
                    context.push('/refacciones', extra: osId); // push para poder volver
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.flag),
                  label: const Text('Estatus'),
                  onPressed: () async {
                    final osId = item.ordenServicioId;
                    final st   = item.statusOrderId;
                    if (osId == null || osId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Este OLT no tiene OrdenServicioID')),
                      );
                      return;
                    }

                    final updated = await context.push('/estatus', extra: OrderStatusArgs(
                      ordenServicioId: osId,
                      statusOrderId: st,
                    ));

                    if (updated == true) {
                      onChanged(); // 👈 pide al padre que recargue la lista
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
