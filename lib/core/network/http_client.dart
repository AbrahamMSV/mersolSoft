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
// NUEVO: POST JSON (application/json)
  Future<Map<String, dynamic>> postJson(
      Uri url, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
      }) async {
    try {
      final finalHeaders = {
        'Content-Type': 'application/json',
        if (headers != null) ...headers,
      };
      final res = await _client
          .post(url, headers: finalHeaders, body: jsonEncode(body ?? const {}))
          .timeout(timeout);

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
  // NUEVO: POST multipart (texto + archivo)
  Future<Map<String, dynamic>> postMultipart(
      Uri url, {
        Map<String, String>? headers,
        Map<String, String>? fields,
        required String fileField,
        required String filePath,
        String? filename,
      }) async {
    try {
      final request = http.MultipartRequest('POST', url);
      if (headers != null) request.headers.addAll(headers);
      if (fields != null) request.fields.addAll(fields);

      final file = await http.MultipartFile.fromPath(fileField, filePath, filename: filename);
      request.files.add(file);

      final streamed = await request.send().timeout(timeout);
      final res = await http.Response.fromStream(streamed);
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
  Future<Map<String, dynamic>> postJsonLenient(
      Uri url, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
      }) async {
    try {
      final finalHeaders = {
        'Content-Type': 'application/json',
        if (headers != null) ...headers,
      };
      final res = await _client.post(url, headers: finalHeaders, body: jsonEncode(body ?? const {})).timeout(timeout);
      // No validamos statusCode aquí: intentamos parsear siempre
      return (jsonDecode(res.body) as Map<String, dynamic>);
    } on FormatException {
      throw ParsingException('Respuesta no es JSON válido');
    } on Exception catch (e) {
      throw NetworkException('Fallo de red: $e');
    }
  }
  Future<Map<String, dynamic>> putJsonLenient(
      Uri url, {
        Map<String, String>? headers,
        Map<String, dynamic>? body,
      }) async {
    try {
      final finalHeaders = {
        'Content-Type': 'application/json',
        if (headers != null) ...headers,
      };
      final res = await _client.put(url, headers: finalHeaders, body: jsonEncode(body ?? const {})).timeout(timeout);
      return (jsonDecode(res.body) as Map<String, dynamic>);
    } on FormatException {
      throw ParsingException('Respuesta no es JSON válido');
    } on Exception catch (e) {
      throw NetworkException('Fallo de red: $e');
    }
  }
}
