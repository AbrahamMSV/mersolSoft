import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final UserService _userService = UserService();
  final TextEditingController _oltController = TextEditingController();

  Future<User?>? futureUser;

  void _fetchData() {
    final input = _oltController.text.trim();
    if (input.isEmpty || int.tryParse(input) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa un número de OLT válido')),
      );
      return;
    }

    final int olt = int.parse(input);

    setState(() {
      futureUser = _userService.fetchUser(olt);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consulta Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _oltController,
              decoration: const InputDecoration(
                labelText: 'Número de OLT',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchData,
              child: const Text('Consultar'),
            ),
            const SizedBox(height: 20),
            if (futureUser != null)
              FutureBuilder<User?>(
                future: futureUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text(
                      '⚠️ No se pudo obtener la información. Verifica tu conexión o la API.',
                      style: TextStyle(color: Colors.red),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final user = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${user.id}'),
                        Text('Usuario: ${user.usuario}'),
                        Text('Contraseña: ${user.pass}'),
                        Text('OLT: ${user.olt}'),
                        Text('IP Pública: ${user.ipPublica}'),
                      ],
                    );
                  } else {
                    return const Text('No se encontraron datos');
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
