import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/locator.dart';
import 'form_refacciones_controller.dart';
import '../domain/articulo_suggestion.dart';
import '../../ordenes_status/domain/order_status_args.dart';
import '../../../core/widgets/app_dialogs.dart';

class FormRefaccionesScreen extends StatefulWidget {
  final int ordenServicioId;
  final int? statusOrderId;
  const FormRefaccionesScreen({super.key, required this.ordenServicioId,this.statusOrderId});

  @override
  State<FormRefaccionesScreen> createState() => _FormRefaccionesScreenState();
}

class _FormRefaccionesScreenState extends State<FormRefaccionesScreen> {
  late final FormRefaccionesController _ctrl;
  final _formKey = GlobalKey<FormState>();
  final _typeAheadCtl = TextEditingController();
  final _cantidadCtl = TextEditingController();
  final _descripcionCtl = TextEditingController();
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
    _descripcionCtl.dispose();
    _entregaCtl.dispose();
    super.dispose();
  }
  Future<bool?> _confirmNextStatus() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Pasar al siguiente estatus?'),
        content: const Text(
            'Se agregará la refacción. ¿Deseas ir ahora a la pantalla de estatus para continuar el flujo?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null), // Cancelar (no hace nada)
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false), // No: solo guardar y regresar
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true), // Sí: guardar y navegar a estatus
            child: const Text('Sí'),
          ),
        ],
      ),
    );
  }
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final goToStatus = await showConfirmDialog(
      context,
      title: '¿Pasar al siguiente estatus?',
      message: 'Se agregará la refacción. ¿Deseas ir ahora a la pantalla de estatus para continuar el flujo?',
      confirmText: 'Sí',
      denyText: 'No',
      cancelText: 'Cancelar',
      barrierDismissible: true,
    );

    if (goToStatus == null) {
      if (!mounted) return;
      await showAlertDialog(
        context,
        title: 'Operación cancelada',
        message: 'No se agregó la refacción.',
        okText: 'Entendido',
      );
      return;
    }

    final ok = await _ctrl.submitAdd(ordenServicioId: widget.ordenServicioId);
    if (!mounted) return;

    if (!ok) {
      final msg = _ctrl.error ?? 'No se pudo agregar la refacción';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    if (goToStatus == true) {
      // 👇 Aquí ya tienes statusOrderId real (si vino desde Ordenes)
      await context.push(
        '/estatus', // o '/ordenes/estatus' si renombraste
        extra: OrderStatusArgs(
          ordenServicioId: widget.ordenServicioId,
          statusOrderId: widget.statusOrderId, // 👈 ya no es null si lo pasaste
        ),
      );
      if (mounted) context.pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Refacción agregada')),
      );

      // Limpieza opcional del form para otra captura
      _formKey.currentState!.reset();
      _typeAheadCtl.clear();
      _cantidadCtl.clear();
      _descripcionCtl.clear();
      _entregaCtl.clear();
      _ctrl.setSeleccion(null);
      _ctrl.setCantidadFromText('');
      _ctrl.setDescripcion('');
      _ctrl.setEntrega('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = _ctrl.seleccionado;
    final loading = _ctrl.loading;
    final isEditable = (selected?.articulo.trim().toUpperCase() == 'CRM-000001');

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
                ),
                onSelected: (s) {
                  _ctrl.setSeleccion(s); // guarda Articulo + (posible) limpia descripcion
                  final nowEditable = s.articulo.trim().toUpperCase() == 'CRM-000001';
                  if (!nowEditable) {
                    // Limpia el input visual y el valor del controller para evitar enviar de más
                    _descripcionCtl.clear();
                    _ctrl.setDescripcion('');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Seleccionado: ${s.articulo}'))
                  );
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

              // DESCRIPCIÓN: SOLO si es editable (CRM-000001)
              if (isEditable)
                TextFormField(
                  controller: _descripcionCtl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    hintText: 'Descripción de la refacción (editable)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: _ctrl.setDescripcion,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Ingresa la descripción';
                    return null;
                  },
                ),

              if (isEditable) const SizedBox(height: 16),

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
                    trailing: isEditable
                        ? const Chip(label: Text('Editable'), avatar: Icon(Icons.edit, size: 16))
                        : null,
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
