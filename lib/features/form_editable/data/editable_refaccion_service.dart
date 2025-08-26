import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class EditableRefaccionService {
  final HttpClient _http;
  final String baseUrl;
  final String csaPath;
  final String agregarPath;

  EditableRefaccionService(
      this._http, {
        required this.baseUrl,
        required this.csaPath,
        required this.agregarPath,
      });

  Future<Map<String, dynamic>> agregar(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl$csaPath/AgregarRefaccionServicio');
    return _http.postJson(uri, body: payload);
  }
}
