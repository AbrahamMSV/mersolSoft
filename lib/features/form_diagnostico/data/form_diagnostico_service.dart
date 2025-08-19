import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class FormDiagnosticoService {
  final HttpClient _http;
  final String baseUrl;
  final String asignarPath;

  FormDiagnosticoService(
      this._http, {
        required this.baseUrl,
        required this.asignarPath,
      });

  Future<Map<String, dynamic>> postDiagnostico({
    required int ordenServicioId,
    required String diagnostico,
  }) async {
    final uri = Uri.parse('$baseUrl$asignarPath/Diagnostico');
    return _http.postJson(
      uri,
      body: {
        'OrdenServicioID': ordenServicioId,
        'Diagnostico': diagnostico,
      },
    );
  }
}
