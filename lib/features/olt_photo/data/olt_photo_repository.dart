import 'dart:io';
import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../core/session/session_store.dart';
import 'olt_photo_service.dart';

class OltPhotoRepository {
  final OltPhotoService _service;
  OltPhotoRepository(this._service);

  Future<Result<void>> enviar({
    required String filePath,
    required int diagnosticoId,
    required String comentario, // por ahora ignorado: se envía "hola"
  }) async {
    try {
      // 1) Obtener Sede desde la sesión persistida
      final store = locator<SessionStore>();
      final sede = store.session?.profile?.sucursal?.trim();
      if (sede == null || sede.isEmpty) {
        return Err(ServerException('Sede no disponible en la sesión'));
      }

      // 2) Determinar extensión del archivo (fallback png)
      final ext = _extensionFromPath(filePath);

      // 3) Enviar según contrato proporcionado (hardcodes)
      final json = await _service.postDiagnosticoFoto(
        sede: sede,
        extensionArchivo: ext,             // ej. "jpg" o "png"
        diagnosticoId: diagnosticoId,                 // hardcode
        claveTipoArchivo: 'DIAGNOSTICO',   // hardcode
        diagnosticoTexto: comentario,          // hardcode
        filePath: filePath,
      );

      final isError = (json['IsError'] as bool?) ?? (json['isError'] as bool?) ?? false;
      if (isError) {
        final msg = (json['message'] as String?) ?? 'No se pudo enviar la fotografía';
        return Err(ServerException(msg));
      }
      return Ok(null);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }

  String _extensionFromPath(String path) {
    try {
      final name = path.split('/').last;
      final parts = name.split('.');
      if (parts.length >= 2) {
        return parts.last.toLowerCase();
      }
      // En muchos dispositivos la cámara genera JPG:
      // si no viene extensión, usar 'png' como fallback solicitado.
      return 'png';
    } catch (_) {
      return 'png';
    }
  }
}
