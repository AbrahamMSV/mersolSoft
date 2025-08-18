import '../../../core/network/http_client.dart';
import 'dart:convert';

class AuthService {
  final HttpClient _http;
  final String baseUrl;
  final String token;

  AuthService(this._http, {required this.baseUrl, required this.token});

  /// Realiza el login contra:
  /// GET {baseUrl}/ip/olt?token=...&user=...&pass=...
  /// Esperado: { "IsError": false, "data": { ... }, "message": "..." }
  Future<Map<String, dynamic>> loginRaw({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/ip/auth'
        '?token=$token'
        '&user=${Uri.encodeQueryComponent(username)}'
        '&pass=${Uri.encodeQueryComponent(password)}');

    // Usa tu HttpClient actual (getJson espera Map). Si tu API
    // devolviera algo que no sea JSON-objeto, ajusta HttpClient.
    return _http.getJson(uri);
  }
}
