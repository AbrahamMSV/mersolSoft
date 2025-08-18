import 'package:flutter/foundation.dart';
import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../../user/data/user_repository.dart';
import '../../user/domain/user.dart';

class UserController extends ChangeNotifier {
  final UserRepository _repo;
  UserController(this._repo);

  User? data;
  String? error;
  bool loading = false;

  Future<void> fetch(int olt) async {
    loading = true; error = null; notifyListeners();
    final res = await _repo.getUser(olt);
    res.when(
      ok: (u) { data = u; },
      err: (e) { error = _humanize(e); data = null; },
    );
    loading = false; notifyListeners();
  }

  String _humanize(AppException e) {
    if (e is NotFoundException) return 'No se encontró el usuario.';
    if (e is NetworkException) return 'Problema de red. Verifica tu conexión.';
    if (e is ServerException) return 'El servidor respondió con un error.';
    if (e is ParsingException) return 'La respuesta no se pudo interpretar.';
    return e.message;
  }
}
