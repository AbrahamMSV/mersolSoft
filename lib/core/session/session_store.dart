import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/domain/auth_session.dart';

class SessionStore {
  static const _k = 'app.session.v1';

  AuthSession? _session;
  AuthSession? get session => _session;
  bool get isLoggedIn => _session?.profile != null;

  /// Carga desde disco al iniciar la app
  Future<void> hydrate() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_k);
    if (raw == null) { _session = null; return; }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      _session = AuthSession.fromJson(map);
    } catch (_) {
      _session = null;
    }
  }

  /// Guarda en memoria + disco
  Future<void> save(AuthSession s) async {
    _session = s;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_k, jsonEncode(s.toJson()));
  }

  /// Limpia sesión
  Future<void> clear() async {
    _session = null;
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_k);
  }
}
