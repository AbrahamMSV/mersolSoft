import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../core/session/session_store.dart';
import '../domain/diagnostico_item.dart';
import 'diagnostico_service.dart';

class DiagnosticoRepository {
  final DiagnosticoService _service;
  DiagnosticoRepository(this._service);

  Future<Result<List<DiagnosticoItem>>> getListado(int ordenServicioId) async {
    try {

      final json = await _service.fetchListado(ordenServicioId: ordenServicioId);

      final isError = (json['isError'] as bool?) ?? (json['IsError'] as bool?) ?? false;
      if (isError) {
        return Err(ServerException((json['message'] as String?) ?? 'No se pudo obtener el diagnóstico'));
      }

      final data = json['data'];
      if (data is! List) {
        return Err(ParsingException('Formato inesperado: data no es lista'));
      }

      final items = data
          .whereType<Map<String, dynamic>>()
          .map((e) => DiagnosticoItem.fromJson(e))
          .toList();

      return Ok(items);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}
