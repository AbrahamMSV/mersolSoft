import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(
    BuildContext context, {
      String title = 'Confirmar',
      required String message,
      String confirmText = 'Sí',
      String denyText = 'No',
      String cancelText = 'Cancelar',
      bool barrierDismissible = true,
    }) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(null), // Cancelar
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false), // No
          child: Text(denyText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(true), // Sí
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

Future<void> showAlertDialog(
    BuildContext context, {
      String title = 'Aviso',
      required String message,
      String okText = 'Entendido',
      bool barrierDismissible = true,
    }) {
  return showDialog<void>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(okText),
        ),
      ],
    ),
  );
}
