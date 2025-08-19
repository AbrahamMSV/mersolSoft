import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/auth_session.dart';
import '../domain/auth_profile.dart';
import 'auth_service.dart';

class AuthRepository {
  final AuthService _service;
  AuthRepository(this._service);

  Future<Result<AuthSession>> login(String username, String password) async {
    try {
      final json = await _service.loginRaw(username: username, password: password);

      if ((json['isError'] as bool?) == true) {
        return Err(ServerException((json['message'] as String?) ?? 'No se pudo iniciar sesión'));
      }

      final data = json['data'];
      if (data is! List || data.isEmpty || data.first is! Map) {
        return Err(ServerException('Usuario/contraseña inválidos'));
      }

      final profile = AuthProfile.fromJson(data.first as Map<String, dynamic>);
      final session = AuthSession(username: username, profile: profile);
      return Ok(session);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error al interpretar respuesta: $e'));
    }
  }
}
