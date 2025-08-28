import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class DiagnosticoService {
  final HttpClient _http;
  final String baseUrl;
  final String asignarPath;

  DiagnosticoService(
      this._http, {
        required this.baseUrl,
        required this.asignarPath
      });

  Future<Map<String, dynamic>> fetchListado({required int ordenServicioId}) {
    final uri = Uri.parse('${baseUrl}${asignarPath}/Diagnostico/$ordenServicioId');
    return _http.getJson(uri);
  }
}
