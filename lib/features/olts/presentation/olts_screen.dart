import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../olts/domain/olt_host.dart';
import '../../../core/di/locator.dart';
import 'olts_controller.dart';
import '../../order_status/domain/order_status_args.dart';
import 'widget/semaforo_badge.dart';

class OltsScreen extends StatefulWidget {
  const OltsScreen({super.key});
  @override State<OltsScreen> createState() => _OltsScreenState();
}

class _OltsScreenState extends State<OltsScreen> {
  late final OltsController _ctrl;
  final _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = locator<OltsController>()..addListener(_onState);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.refresh(); // 🔰 carga inicial
    });
  }

  void _onState() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_onState);
    _searchCtl.dispose();
    super.dispose();
  }

  void _refreshOlts() => _ctrl.refresh();

  bool _onScroll(ScrollNotification sn) {
    if (sn.metrics.pixels >= sn.metrics.maxScrollExtent - 200) {
      _ctrl.loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final loading = _ctrl.loading;
    final loadingMore = _ctrl.loadingMore;
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
      body: Column(
        children: [
          // Búsqueda
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtl,
              decoration: InputDecoration(
                hintText: 'Buscar…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtl.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtl.clear();
                    _ctrl.setQuery('');
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: _ctrl.setQuery,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _ctrl.refresh,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,

                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: items.length + (loadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final item = items[index];
                    return _OltCard(item: item, onChanged: _refreshOlts);
                  },
                ),
              ),
            ),
          ),

          if (loading && items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!loading && error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),
          if (!loading && !loadingMore && !_ctrl.hasMore && items.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('No hay más resultados'),
            ),
        ],
      ),
    );
  }
}

class _OltCard extends StatelessWidget {
  final OltHost item;
  final VoidCallback onChanged;

  const _OltCard({super.key,required this.item,required this.onChanged});

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text('Orden ${item.asignadaId}', style: Theme.of(context).textTheme.titleMedium)),
              Chip(label: Text(item.folio))
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
              const Icon(Icons.traffic, size: 16,),
              const SizedBox(width: 6,),
              SemaforoBadge(value: item.semaforo)
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