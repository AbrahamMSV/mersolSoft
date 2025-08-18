import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  Future<User?> fetchUser(int olt) async {
    try {
      final url = Uri.parse(
        'http://192.168.1.110/apiphp/ip/olt?token=fa3b2c9c-a96d-48a8-82ad-0cb775dd3e5d&olt=$olt',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded == false) return null;

        return User.fromJson(decoded);
      } else {
        throw Exception('Error en la API (${response.statusCode})');
      }
    } on http.ClientException {
      throw Exception('No se pudo conectar con el servidor');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}
