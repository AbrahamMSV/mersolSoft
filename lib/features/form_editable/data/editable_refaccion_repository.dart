import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../core/session/session_store.dart';
import 'editable_refaccion_service.dart';

class EditableRefaccionRepository {
  final EditableRefaccionService _svc;
  EditableRefaccionRepository(this._svc);

  Future<Result<void>> agregarEditable({
    required int ordenServicioId,
    required num cantidad,
    required String descripcion,
    required String entrega,
  }) async {
    try {
      final store = locator<SessionStore>();
      final idSucursal = store.session?.profile?.idSucursal;

      if (idSucursal == null) {
        return Err(ParsingException('Orden o sucursal no disponibles en la sesión'));
      }

      final payload = <String, dynamic>{
        'Articulo': 'CRM-000001',
        'Cantidad': cantidad,
        'Descripcion': descripcion,
        'Entrega': entrega,
        'IsEditable': 1,
        'OrdenServicioID': ordenServicioId,
        'PrecioUnitario': '0.00',
        'SucursalID': idSucursal,
        'Unidad': 'PZA',
      };

      final json = await _svc.agregar(payload);

      final isError = (json['IsError'] as bool?) ?? (json['isError'] as bool?) ?? false;
      if (isError) {
        final msg = (json['Message'] as String?) ?? (json['message'] as String?) ?? 'No se pudo agregar';
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
