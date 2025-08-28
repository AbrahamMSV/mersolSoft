import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../core/session/session_store.dart';
import '../domain/articulo_suggestion.dart';
import 'form_refacciones_service.dart';

class FormRefaccionesRepository {
  final FormRefaccionesService _service;
  FormRefaccionesRepository(this._service);

  Future<Result<void>> crear({
    required int ordenServicioId,
    required ArticuloSuggestion seleccionado,
    required num cantidad,
    required String entrega,
    String? descripcionInput, // 👈 NUEVO: descripción escrita en el form
  }) async {
    try {
      final store = locator<SessionStore>();
      final idSucursal = store.session?.profile?.idSucursal ?? 0;

      final isEditable = seleccionado.articulo.trim().toUpperCase() == 'CRM-000001';

      final payload = isEditable
          ? <String, dynamic>{
        'OrdenServicioID': ordenServicioId,
        'Articulo': seleccionado.articulo,   // ← editable fijo
        'Cantidad': cantidad,
        'Descripcion': descripcionInput ?? seleccionado.descripcion,
        'Entrega': entrega,
        'Unidad': 'PZA',            // ← editable fijo
        'IsEditable': 1,            // ← editable fijo
        'SucursalID': idSucursal,
        'PrecioUnitario': '0.00',   // ← editable fijo
      }
          : <String, dynamic>{
        'OrdenServicioID': ordenServicioId,
        'Articulo': seleccionado.articulo,
        'Cantidad': cantidad,
        'Descripcion': descripcionInput ?? (seleccionado.descripcion ?? ''),
        'Entrega': entrega,
        'Unidad': '',
        'IsEditable': 0,
        'SucursalID': idSucursal,
      };

      final json = await _service.addRefaccionServicio(payload);

      final isError = (json['IsError'] as bool?) ?? (json['isError'] as bool?) ?? false;
      if (isError) {
        return Err(ServerException(
          (json['Message'] as String?) ?? (json['message'] as String?) ?? 'No se pudo agregar la refacción',
        ));
      }
      return Ok(null);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }

  Future<Result<List<ArticuloSuggestion>>> buscar(String query) async {
    try {
      if (query.trim().isEmpty) return Ok(const []);
      final json = await _service.searchArticulos(query.trim());

      // La respuesta viene con Data1 (según tu ejemplo)
      final list = json['Data1'];
      if (list is! List) return Ok(const []);

      final items = list
          .whereType<Map<String, dynamic>>()
          .map((e) => ArticuloSuggestion.fromJson(e))
          .toList();

      return Ok(items);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}
