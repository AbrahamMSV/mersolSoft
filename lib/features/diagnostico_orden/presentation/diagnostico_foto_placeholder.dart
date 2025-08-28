import 'package:flutter/material.dart';

class DiagnosticoFotoPlaceholder extends StatelessWidget {
  final int diagnosticoId;
  const DiagnosticoFotoPlaceholder({super.key, required this.diagnosticoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fotografía (placeholder)')),
      body: Center(
        child: Text('DiagnosticoID recibido: $diagnosticoId'),
      ),
    );
  }
}
