import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/user.dart';
import 'user_service.dart';

class UserRepository {
  final UserService _service;
  UserRepository(this._service);

  Future<Result<User>> getUser(int olt) async {
    try {
      final json = await _service.fetchUserRaw(olt: olt);
      // valida estructura mínima
      if (!json.containsKey('id') || !json.containsKey('Usuario')) {
        return Err(ParsingException('Faltan campos en la respuesta'));
      }
      final user = User.fromJson(json);
      return Ok(user);
    } on AppException catch (e) {
      return Err(e);
    } catch (e) {
      return Err(ParsingException('Error inesperado al parsear: $e'));
    }
  }
}
