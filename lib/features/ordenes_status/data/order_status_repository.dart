import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import 'order_status_service.dart';

class OrderStatusRepository {
  final OrderStatusService _service;
  OrderStatusRepository(this._service);

  Future<Result<void>> cambiar({
    required int ordenServicioId,
    required int nuevoStatus,
    String? comentario,
  }) async {
    try {
      final json = await _service.putEstatus(
        ordenServicioId: ordenServicioId,
        statusOrderId: nuevoStatus,
        comentario: comentario,
      );

      final isError = (json['IsError'] as bool?) ?? (json['isError'] as bool?) ?? false;
      if (isError) {
        final msg = (json['Message'] as String?) ?? (json['message'] as String?) ?? 'No se pudo actualizar el estatus';
        return Err(ServerException(msg));
      }
      return Ok(null);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}

