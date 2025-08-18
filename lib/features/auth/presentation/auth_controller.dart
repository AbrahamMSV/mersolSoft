import 'package:flutter/foundation.dart';
import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/auth_session.dart';
import '../data/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repo;
  AuthController(this._repo);

  AuthSession? session;
  bool loading = false;
  String? error;

  Future<bool> login(String user, String pass) async {
    loading = true; error = null; notifyListeners();
    final res = await _repo.login(user, pass);
    res.when(
      ok: (s) { session = s; },
      err: (e) { error = _humanize(e); session = null; },
    );
    loading = false; notifyListeners();
    return session != null;
  }

  String _humanize(AppException e) {
    if (e is ServerException) return e.message;
    if (e is NetworkException) return 'Problema de red. Verifica tu conexión.';
    if (e is NotFoundException) return 'Recurso no encontrado.';
    if (e is ParsingException) return 'La respuesta no se pudo interpretar.';
    return e.message;
  }

  bool get isLoggedIn => session != null;
}
