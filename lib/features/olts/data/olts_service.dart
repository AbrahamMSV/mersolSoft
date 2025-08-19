import 'package:meta/meta.dart';
import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class OltsService {
  final HttpClient _http;
  final String baseUrl;
  final String asignar;

  OltsService(
      this._http, {
        required this.baseUrl,
        required this.asignar
      });

  /// GET {baseUrl}{path}?token=...
  /// Respuesta esperada:
  /// { "IsError": false, "message": "...", "data": [ {id,Usuario,Pass,Olt,IpPublica}, ... ] }
  Future<Map<String, dynamic>> fetchOltsRaw(int idUsuario) async {
    final uri = Uri.parse('$baseUrl$asignar/Asignado?id=$idUsuario');
    return _http.getJson(uri);
  }
}
