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
  }) async {
    try {
      final store = locator<SessionStore>();
      final idSucursal = store.session?.profile?.idSucursal ?? 0;

      final payload = {
        'OrdenServicioID': ordenServicioId,
        'Articulo': seleccionado.articulo,
        'Cantidad': cantidad,
        'Descripcion': seleccionado.descripcion ?? '',
        'Entrega': entrega,
        'Unidad': '',
        'IsEditable': 0,
        'SucursalID': idSucursal,
      };

      final json = await _service.addRefaccionServicio(payload);

      // La API puede devolver 200 o 400 pero siempre con JSON:
      final isError = (json['IsError'] as bool?) ?? (json['isError'] as bool?) ?? false;
      if (isError) {
        return Err(ServerException((json['Message'] as String?) ?? (json['message'] as String?) ?? 'No se pudo agregar la refacción'));
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
