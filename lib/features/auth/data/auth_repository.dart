import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/auth_session.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _service;
  AuthRepository(this._service);

  Future<Result<AuthSession>> login(String username, String password) async {
    try {
      final json = await _service.loginRaw(username: username, password: password);

      final isError = (json['IsError'] as bool?) ?? true;
      final message = (json['message'] as String?) ?? 'No se pudo iniciar sesión';
      final data = json['data'];

      if (isError) {
        return Err(ServerException(message));
      }

      // Si "data" trae más cosas (roles, id, etc.), las dejamos en el session.data
      final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
      final session = AuthSession(username: username, data: map);
      return Ok(session);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}
