import 'package:flutter/material.dart';
import '../../../core/network/http_client.dart';
import '../data/user_service.dart';
import '../data/user_repository.dart';
import 'user_controller.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});
  @override State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late final TextEditingController _ctl;
  late final UserController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctl = TextEditingController();
    final http = HttpClient();
    final service = UserService(http, baseUrl: 'http://192.168.1.110/apiphp');
    final repo = UserRepository(service);
    _ctrl = UserController(repo);
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() { _ctrl.dispose(); _ctl.dispose(); super.dispose(); }

  void _fetchData() {
    final text = _ctl.text.trim();
    final olt = int.tryParse(text);
    if (olt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un OLT numérico')),
      );
      return;
    }
    _ctrl.fetch(olt);
  }

  @override
  Widget build(BuildContext context) {
    final loading = _ctrl.loading;
    final error = _ctrl.error;
    final user = _ctrl.data;

    return Scaffold(
      appBar: AppBar(title: const Text('Usuario por OLT')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ctl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'OLT', border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: loading ? null : _fetchData, child: const Text('Consultar')),
            const SizedBox(height: 16),
            if (loading) const CircularProgressIndicator(),
            if (!loading && error != null) Text(error!, style: const TextStyle(color: Colors.red)),
            if (!loading && error == null && user != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${user.id}'),
                  Text('Usuario: ${user.usuario}'),
                  Text('Pass: ${user.pass}'),
                  Text('Olt:${user.olt}'),
                  Text('Ip Publica:${user.ipPublica}')
                ],
              ),
          ],
        ),
      ),
    );
  }
}
