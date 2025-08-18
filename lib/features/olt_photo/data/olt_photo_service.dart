import '../../../core/network/http_client.dart';
import '../../../core/config/app_config.dart';

class OltPhotoService {
  final HttpClient _http;
  final String baseUrl;
  final String token;
  final String path;

  OltPhotoService(this._http, {required this.baseUrl, required this.token, required this.path});

  /// POST multipart {baseUrl}{path}?token=...
  /// fields: comentario, olt
  /// file: fieldName 'fotografia'
  Future<Map<String, dynamic>> postFoto({
    required int olt,
    required String comentario,
    required String filePath,
  }) {
    final uri = Uri.parse('$baseUrl$path?token=$token');
    return _http.postMultipart(
      uri,
      fields: {'comentario': comentario, 'olt': '$olt'},
      fileField: 'fotografia', // Ajusta al nombre que espera tu API
      filePath: filePath,
    );
  }
}
