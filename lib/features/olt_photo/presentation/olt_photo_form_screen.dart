import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/di/locator.dart';
import '../../olts/domain/olt_host.dart';
import 'olt_photo_controller.dart';
import 'camera_capture_screen.dart';

class OltPhotoFormScreen extends StatefulWidget {
  final OltHost item;
  const OltPhotoFormScreen({super.key, required this.item});

  @override
  State<OltPhotoFormScreen> createState() => _OltPhotoFormScreenState();
}

class _OltPhotoFormScreenState extends State<OltPhotoFormScreen> {
  late final OltPhotoController _ctrl;
  final _formKey = GlobalKey<FormState>();
  final _txtCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ctrl = locator<OltPhotoController>()..addListener(_onState);
  }

  void _onState() => setState(() {});

  @override
  void dispose() {
    _ctrl.removeListener(_onState);
    _txtCtl.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final XFile? x = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CameraCaptureScreen()),
    );
    if (x != null) {
      _ctrl.setFilePath(x.path);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fotografía seleccionada')));
    }
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    _ctrl.setComentario(_txtCtl.text.trim());
    try {
      final ok = await _ctrl.enviar(widget.item.olt);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enviado con éxito')));
        context.pop(); // volver a OLTs
      } else if (!ok && mounted) {
        final msg = _ctrl.error ?? 'No se pudo enviar';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      // Tu requerimiento explícito: lanzar exception “Debes tomar fotografía”
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = _ctrl.loading;
    final path = _ctrl.filePath;

    return Scaffold(
      appBar: AppBar(title: Text('Fotografía OLT ${widget.item.olt}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text('IP: ${widget.item.ipPublica}', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text('Usuario: ${widget.item.usuario}', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 16),
              TextFormField(
                controller: _txtCtl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Comentario',
                  hintText: 'Describe el contexto de la fotografía',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingrese un comentario' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Tomar fotografía'),
                      onPressed: loading ? null : _openCamera,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (path != null && path.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(File(path), height: 220, fit: BoxFit.cover),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                  label: Text(loading ? 'Enviando...' : 'Enviar'),
                  onPressed: loading ? null : _send,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
