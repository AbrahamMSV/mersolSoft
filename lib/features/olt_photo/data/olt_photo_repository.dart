import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/olt_photo_payload.dart';
import 'olt_photo_service.dart';

class OltPhotoRepository {
  final OltPhotoService _service;
  OltPhotoRepository(this._service);

  Future<Result<void>> enviar(OltPhotoPayload p) async {
    try {
      final json = await _service.postFoto(olt: p.olt, comentario: p.comentario, filePath: p.filePath);
      final isError = (json['IsError'] as bool?) ?? true;
      if (isError) return Err(ServerException((json['message'] as String?) ?? 'No se pudo enviar la fotografía'));
      return Ok(null);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}
