import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/locator.dart';
import 'form_refacciones_controller.dart';
import '../domain/articulo_suggestion.dart';

class FormRefaccionesScreen extends StatefulWidget {
  final int ordenServicioId;
  const FormRefaccionesScreen({super.key, required this.ordenServicioId});

  @override
  State<FormRefaccionesScreen> createState() => _FormRefaccionesScreenState();
}

class _FormRefaccionesScreenState extends State<FormRefaccionesScreen> {
  late final FormRefaccionesController _ctrl;
  final _formKey = GlobalKey<FormState>();
  final _typeAheadCtl = TextEditingController();
  final _cantidadCtl = TextEditingController();
  final _entregaCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = locator<FormRefaccionesController>()..addListener(_onState);
  }

  void _onState() => setState(() {});
  @override
  void dispose() {
    _ctrl.removeListener(_onState);
    _typeAheadCtl.dispose();
    _cantidadCtl.dispose();
    _entregaCtl.dispose();
    super.dispose();
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _ctrl.submitAdd(ordenServicioId: widget.ordenServicioId);
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refacción agregada')));
      context.pop(true);
    } else {
      final msg = _ctrl.error ?? 'No se pudo agregar la refacción';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
  @override
  Widget build(BuildContext context) {
    final selected = _ctrl.seleccionado;
    final loading = _ctrl.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar refacción (OS ${widget.ordenServicioId})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final r = GoRouter.of(context);
            if (r.canPop()) r.pop(); else r.go('/refacciones', extra: widget.ordenServicioId);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // SELECT (typeahead)
              TypeAheadField<ArticuloSuggestion>(
                controller: _typeAheadCtl,
                debounceDuration: const Duration(milliseconds: 300),
                suggestionsCallback: _ctrl.sugerencias,
                builder: (context, ctl, focusNode) {
                  return TextFormField(
                    controller: ctl,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Buscar artículo',
                      hintText: 'Escribe parte del código o descripción',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    validator: (_) => _ctrl.seleccionado == null ? 'Selecciona un artículo' : null,
                  );
                },
                itemBuilder: (context, s) => ListTile(
                  title: Text(s.articulo),
                  subtitle: Text(s.descripcion ?? '-'),
                  trailing: Text('Stock: ${s.stock}'),
                ),
                onSelected: (s) {
                  _ctrl.setSeleccion(s); // guardamos Articulo y Descripcion
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Seleccionado: ${s.articulo}')));
                },
                emptyBuilder: (_) => const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('Sin resultados'),
                ),
                loadingBuilder: (_) => const Padding(
                  padding: EdgeInsets.all(12),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),

              const SizedBox(height: 16),

              // CANTIDAD (numérico)
              TextFormField(
                controller: _cantidadCtl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                onChanged: _ctrl.setCantidadFromText,
                validator: (v) {
                  final t = (v ?? '').trim().replaceAll(',', '.');
                  final n = num.tryParse(t);
                  if (n == null || n <= 0) return 'Cantidad inválida';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ENTREGA (texto)
              TextFormField(
                controller: _entregaCtl,
                decoration: const InputDecoration(
                  labelText: 'Entrega',
                  hintText: 'p.ej. hoy / mañana / fecha',
                  border: OutlineInputBorder(),
                ),
                onChanged: _ctrl.setEntrega,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa la entrega' : null,
              ),

              const SizedBox(height: 16),

              if (selected != null)
                Card(
                  child: ListTile(
                    title: Text(selected.articulo),
                    subtitle: Text(selected.descripcion ?? ''),
                  ),
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.check),
                  label: Text(loading ? 'Enviando...' : 'Listo'),
                  onPressed: loading ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
