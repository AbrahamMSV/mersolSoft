import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class RefaccionesService {
  final HttpClient _http;
  final String baseUrl;
  final String csaPath;
  final String listaPath;

  RefaccionesService(
      this._http, {
        required this.baseUrl,
        required this.csaPath,
        required this.listaPath,
      });

  Future<Map<String, dynamic>> fetchPorOrden({required int ordenServicioId}) {
    final uri = Uri.parse('${baseUrl}${csaPath}/${listaPath}?OrdenID=$ordenServicioId');
    return _http.getJson(uri);
  }
}
