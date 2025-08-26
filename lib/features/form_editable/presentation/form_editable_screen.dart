import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/locator.dart';
import 'form_editable_controller.dart';

class FormEditableScreen extends StatefulWidget {
  final int ordenServicioId;
  const FormEditableScreen({super.key, required this.ordenServicioId});
  @override
  State<FormEditableScreen> createState() => _FormEditableScreenState();
}

class _FormEditableScreenState extends State<FormEditableScreen> {
  late final FormEditableController _ctrl;
  final _formKey = GlobalKey<FormState>();
  final _cantidadCtl = TextEditingController();
  final _descripcionCtl = TextEditingController();
  final _entregaCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = locator<FormEditableController>()..addListener(_onState);
    _ctrl.setOrdenServicioId(widget.ordenServicioId);
  }

  void _onState() => setState(() {});
  @override
  void dispose() {
    _ctrl.removeListener(_onState);
    _cantidadCtl.dispose();
    _descripcionCtl.dispose();
    _entregaCtl.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext formCtx) async {
    final form = Form.of(formCtx);
    if (form == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Formulario no disponible')));
      return;
    }
    // aseguremos que el controller tenga lo último tipeado
    _ctrl.setCantidad(_cantidadCtl.text);
    _ctrl.setDescripcion(_descripcionCtl.text);
    _ctrl.setEntrega(_entregaCtl.text);

    if (!form.validate()) return;

    final ok = await _ctrl.submit();
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Refacción editable agregada')));
      context.pop(true); // ← volvemos y marcamos que se guardó
    } else {
      final msg = _ctrl.error ?? 'No se pudo agregar';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar refacción (editable)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _cantidadCtl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cantidad',
                  border: OutlineInputBorder(),
                ),
                validator: _ctrl.validateCantidad,
                onChanged: _ctrl.setCantidad,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtl,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                validator: _ctrl.validateTexto,
                onChanged: _ctrl.setDescripcion,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _entregaCtl,
                decoration: const InputDecoration(
                  labelText: 'Entrega',
                  hintText: 'p.ej. hoy / mañana / fecha',
                  border: OutlineInputBorder(),
                ),
                validator: _ctrl.validateTexto,
                onChanged: _ctrl.setEntrega,
              ),
              const SizedBox(height: 20),

              Builder(
                builder: (formCtx) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: _ctrl.loading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.check),
                    label: Text(_ctrl.loading ? 'Enviando...' : 'Enviar'),
                    onPressed: _ctrl.loading ? null : () => _submit(formCtx),
                  ),
                ),
              ),

              if (_ctrl.error != null) ...[
                const SizedBox(height: 12),
                Text(_ctrl.error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
