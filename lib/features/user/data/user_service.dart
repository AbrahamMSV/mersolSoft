import '../../../core/network/http_client.dart';

class UserService {
  final HttpClient _http;
  final String baseUrl;
  UserService(this._http, {required this.baseUrl});

  Future<Map<String, dynamic>> fetchUserRaw({required int olt}) {
    final url = Uri.parse('$baseUrl/ip/olt?token=fa3b2c9c-a96d-48a8-82ad-0cb775dd3e5d&olt=$olt');
    return _http.getJson(url);
  }
}
