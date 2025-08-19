import 'package:flutter/foundation.dart';
import '../../../core/result/result.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/di/locator.dart';
import '../../../core/session/session_store.dart';
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
    loading = false;

    return res.when(
      ok: (s) {
        session = s;
        locator<SessionStore>().save(s); // ← cookie app
        notifyListeners();
        return true;
      },
      err: (e) {
        error = _humanize(e);
        session = null;
        notifyListeners();
        return false;
      },
    );
  }

  Future<void> logout() async {
    session = null;
    await locator<SessionStore>().clear();
    notifyListeners();
  }

  bool get isLoggedIn => session?.profile != null || locator<SessionStore>().isLoggedIn;

  String _humanize(AppException e) {
    if (e is ServerException) return e.message;
    if (e is NetworkException) return 'Problema de red. Verifica tu conexión.';
    if (e is NotFoundException) return 'Recurso no encontrado.';
    if (e is ParsingException) return 'La respuesta no se pudo interpretar.';
    return e.message;
  }
}
