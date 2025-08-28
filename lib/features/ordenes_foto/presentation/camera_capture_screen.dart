import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capture;

  @override
  void initState() {
    super.initState();
    _takePhoto();
  }

  Future<void> _takePhoto() async {
    final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (!mounted) return;
    setState(() { _capture = photo; });
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _capture != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tomar fotografía'),
        // Atrás: vuelve sin guardar
      ),
      body: Center(
        child: hasPhoto
            ? Image.file(
          // ignore: unnecessary_null_comparison
          // Se usa File solo en móvil; en web habría que manejar diferente.
          // Para simplicidad asumimos móvil nativo.
          // (import 'dart:io' solo si compilas mobile)
          // Aquí mostramos vía Image.file con path.
          // Si compilas también a web, cambia a Image.memory leyendo bytes.
          // Para este caso, móvil:
          // ignore: prefer_interpolation_to_compose_strings
          File(_capture!.path),
          fit: BoxFit.contain,
        )
            : const Text('Abriendo cámara...'),
      ),
      bottomNavigationBar: hasPhoto
          ? SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Tomar otra'),
                  onPressed: _takePhoto,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Guardar'),
                  onPressed: () {
                    Navigator.pop(context, _capture); // devuelve la foto
                  },
                ),
              ),
            ],
          ),
        ),
      )
          : null,
    );
  }
}
