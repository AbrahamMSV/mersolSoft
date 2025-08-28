import 'package:meta/meta.dart';
import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';
import '../domain/csa_datatable_payload.dart';
class OltsService {
  final HttpClient _http;
  final String baseUrl;
  final String asignar;

  OltsService(
      this._http, {
        required this.baseUrl,
        required this.asignar
      });

  Future<Map<String, dynamic>> fetchOltsRaw(CsaDataTablePayload payload) {
    final uri = Uri.parse('$baseUrl$asignar/Asignado');
    return _http.postJson(uri,body: payload.toJson());
  }
}
