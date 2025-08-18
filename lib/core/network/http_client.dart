import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/app_exception.dart';

class HttpClient {
  final http.Client _client;
  final Duration timeout;
  HttpClient({http.Client? client, this.timeout = const Duration(seconds: 12)})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getJson(Uri url, {Map<String, String>? headers}) async {
    try {
      final res = await _client.get(url, headers: headers).timeout(timeout);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return (jsonDecode(res.body) as Map<String, dynamic>);
      }
      if (res.statusCode == 404) throw NotFoundException('Recurso no encontrado', statusCode: res.statusCode);
      throw ServerException('Error del servidor', statusCode: res.statusCode);
    } on FormatException {
      throw ParsingException('Respuesta no es JSON válido');
    } on Exception catch (e) {
      throw NetworkException('Fallo de red: $e');
    }
  }
}
