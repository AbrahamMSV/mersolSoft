import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/refaccion_item.dart';
import 'refacciones_service.dart';

class RefaccionesRepository {
  final RefaccionesService _service;
  RefaccionesRepository(this._service);

  Future<Result<List<RefaccionItem>>> listar(int ordenServicioId) async {
    try {
      final json = await _service.fetchPorOrden(ordenServicioId: ordenServicioId);

      final isError = (json['isError'] as bool?) ?? (json['IsError'] as bool?) ?? false;
      if (isError) {
        return Err(ServerException((json['message'] as String?) ?? 'No se pudo obtener refacciones'));
      }

      final data = json['data'];
      if (data is! List) {
        return Err(ParsingException('Formato inesperado: data no es lista'));
      }

      final items = data
          .whereType<Map<String, dynamic>>()
          .map((e) => RefaccionItem.fromJson(e))
          .toList();

      return Ok(items);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}
