import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../core/session/session_store.dart';
import '../domain/olt_host.dart';
import 'olts_service.dart';

class OltsRepository {
  final OltsService _service;
  OltsRepository(this._service);

  Future<Result<List<OltHost>>> getOlts() async {
    try {
      final store = locator<SessionStore>();
      final idUsuario = store.session?.profile?.idUsuario;
      if (idUsuario == null || idUsuario == 0) {
        return Err(ServerException('Sesión inválida o vencida: idUsuario no disponible'));
      }
      final json = await _service.fetchOltsRaw(idUsuario);

      final data = json['data'];
      if (data is! List) {
        return Err(ParsingException('Formato inesperado: data no es una lista'));
      }

      final items = data
          .whereType<Map<String, dynamic>>()
          .map((e) => OltHost.fromJson(e))
          .toList();

      return Ok(items);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}
