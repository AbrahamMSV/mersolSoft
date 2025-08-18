import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/di/locator.dart';
import 'olts_controller.dart';
import '../domain/olt_host.dart';
import 'package:go_router/go_router.dart';
import '../../olts/domain/olt_host.dart';

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

  @override
  Widget build(BuildContext context) {
    final loading = _ctrl.loading;
    final error = _ctrl.error;
    final items = _ctrl.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OLTs'),
        actions: [
          PopupMenuButton<OltSort>(
            initialValue: _ctrl.sort,
            onSelected: (s) => _ctrl.sort = s,
            itemBuilder: (context) => const [
              PopupMenuItem(value: OltSort.oltAsc,  child: Text('Ordenar OLT ↑')),
              PopupMenuItem(value: OltSort.oltDesc, child: Text('Ordenar OLT ↓')),
              PopupMenuItem(value: OltSort.ipAsc,   child: Text('Ordenar IP ↑')),
              PopupMenuItem(value: OltSort.ipDesc,  child: Text('Ordenar IP ↓')),
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
                revealed: _revealPassIds.contains(o.id),
                onToggleReveal: () => _toggleReveal(o.id),
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
  final bool revealed;
  final VoidCallback onToggleReveal;

  const _OltCard({required this.item, required this.revealed, required this.onToggleReveal});

  @override
  Widget build(BuildContext context) {
    final passText = revealed ? item.pass : '•' * (item.pass.length.clamp(4, 16));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(child: Text('OLT ${item.olt}', style: Theme.of(context).textTheme.titleMedium)),
              Chip(label: Text(item.ipPublica)),
              IconButton(tooltip: 'Copiar IP', icon: const Icon(Icons.copy), onPressed: () { /* copiar IP */ }),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.person, size: 18), const SizedBox(width: 6),
              Expanded(child: Text('Usuario: ${item.usuario}')),
              IconButton(tooltip: 'Copiar usuario', icon: const Icon(Icons.copy), onPressed: () { /* copiar usuario */ }),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.lock, size: 18), const SizedBox(width: 6),
              Expanded(child: Text('Pass: $passText')),
              IconButton(tooltip: revealed ? 'Ocultar' : 'Mostrar', icon: Icon(revealed ? Icons.visibility_off : Icons.visibility), onPressed: onToggleReveal),
              IconButton(tooltip: 'Copiar contraseña', icon: const Icon(Icons.copy), onPressed: () { /* copiar pass */ }),
            ]),
            const SizedBox(height: 12),
            // NUEVO: botón para ir a formulario de fotografía
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_camera),
                label: const Text('Fotografía'),
                onPressed: () => context.go('/olts/foto', extra: item),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
