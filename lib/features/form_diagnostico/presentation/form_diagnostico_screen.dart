import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/locator.dart';
import 'form_diagnostico_controller.dart';

class FormDiagnosticoScreen extends StatefulWidget {
  final int ordenServicioId;
  const FormDiagnosticoScreen({super.key, required this.ordenServicioId});

  @override
  State<FormDiagnosticoScreen> createState() => _FormDiagnosticoScreenState();
}

class _FormDiagnosticoScreenState extends State<FormDiagnosticoScreen> {
  late final FormDiagnosticoController _ctrl;
  final _formKey = GlobalKey<FormState>();
  final _txtCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = locator<FormDiagnosticoController>()..addListener(_onState);
  }

  void _onState() => setState(() {});
  @override
  void dispose() { _ctrl.removeListener(_onState); _txtCtl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _ctrl.setTexto(_txtCtl.text);
    final ok = await _ctrl.submit(ordenServicioId: widget.ordenServicioId);
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Diagnóstico creado')));
      context.pop(true); // volver a la lista
    } else {
      final msg = _ctrl.error ?? 'No se pudo crear el diagnóstico';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _ctrl.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text('Nuevo diagnóstico (OS ${widget.ordenServicioId})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _txtCtl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico',
                  hintText: 'Describe el diagnóstico...',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un diagnóstico' : null,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: loading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                  label: Text(loading ? 'Enviando...' : 'Enviar'),
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
