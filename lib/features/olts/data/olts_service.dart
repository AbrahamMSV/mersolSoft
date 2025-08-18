import 'package:meta/meta.dart';
import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class OltsService {
  final HttpClient _http;
  final String baseUrl;
  final String token;
  final String path;

  OltsService(
      this._http, {
        required this.baseUrl,
        required this.token,
        this.path = AppConfig.oltsPath, // '/olts' por defecto
      });

  /// GET {baseUrl}{path}?token=...
  /// Respuesta esperada:
  /// { "IsError": false, "message": "...", "data": [ {id,Usuario,Pass,Olt,IpPublica}, ... ] }
  Future<Map<String, dynamic>> fetchOltsRaw() async {
    final uri = Uri.parse('$baseUrl$path?token=$token&user=oltmanager&pass=F%40stN3t%2325');
    return _http.getJson(uri);
  }
}
