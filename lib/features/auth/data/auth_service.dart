import '../../../core/network/http_client.dart';
import 'dart:convert';

class AuthService {
  final HttpClient _http;
  final String baseUrl;
  final String asignar;

  AuthService(this._http, {required this.baseUrl, required this.asignar});

  /// Realiza el login contra:
  /// GET {baseUrl}/ip/olt?token=...&user=...&pass=...
  /// Esperado: { "IsError": false, "data": { ... }, "message": "..." }
  Future<Map<String, dynamic>> loginRaw({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl$asignar/Sesion'
        '?usuario=${Uri.encodeQueryComponent(username)}'
        '&parametro=${Uri.encodeQueryComponent(password)}');

    // Usa tu HttpClient actual (getJson espera Map). Si tu API
    // devolviera algo que no sea JSON-objeto, ajusta HttpClient.
    return _http.getJson(uri);
  }
}
