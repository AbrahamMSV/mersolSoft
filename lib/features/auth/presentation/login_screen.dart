import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/locator.dart';
import 'auth_controller.dart';
import '../../../core/widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtl = TextEditingController();
  final _passCtl = TextEditingController();
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = locator<AuthController>()..addListener(_onAuth);
  }

  void _onAuth() {
    // 👇 CUANDO SE LOGUEA, IR A /ordenes (no a /user)
    if (!_auth.loading && _auth.isLoggedIn && mounted) {
      context.go('/ordenes');
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuth);
    _userCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await _auth.login(_userCtl.text.trim(), _passCtl.text);
    if (!ok && mounted) {
      final msg = _auth.error ?? 'No se pudo iniciar sesión.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
    // No navegues aquí si usas el listener _onAuth. Mantén una sola vía.
  }

  @override
  Widget build(BuildContext context) {
    final loading = _auth.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de sesión')),
      body: LoadingOverlay(
        loading: loading,
        message: 'Validando credenciales…',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _userCtl,
                  enabled: !loading,
                  decoration: const InputDecoration(
                    labelText: 'Usuario', border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa usuario' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtl,
                  enabled: !loading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña', border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa contraseña' : null,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _submit,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (w, a) => FadeTransition(opacity: a, child: w),
                      child: loading
                          ? const SizedBox(
                        key: ValueKey('pb'),
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Text('Iniciar', key: ValueKey('tx')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
