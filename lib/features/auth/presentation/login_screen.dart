import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/locator.dart';
import 'auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtl = TextEditingController();
  final _passCtl = TextEditingController();
  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = locator<AuthController>();
    _auth.addListener(_onAuth);
  }

  void _onAuth() {
    if (!_auth.loading && _auth.isLoggedIn && context.mounted) {
      context.go('/user');
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
  }

  @override
  Widget build(BuildContext context) {
    final loading = _auth.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userCtl,
                decoration: const InputDecoration(
                  labelText: 'Usuario', border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa usuario' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passCtl,
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
                  child: Text(loading ? 'Validando...' : 'Iniciar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
