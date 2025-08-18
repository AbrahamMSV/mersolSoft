import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/di/locator.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/user/presentation/user_screen.dart';
import 'features/olts/presentation/olts_screen.dart';

// NUEVO
import 'features/olt_photo/presentation/olt_photo_form_screen.dart';
import 'features/olts/domain/olt_host.dart';

final _auth = locator<AuthController>();

class _HomeScaffold extends StatelessWidget {
  final Widget child;
  final String current;
  const _HomeScaffold({required this.child, required this.current});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(child: Text('Menú')),
              ListTile(selected: current == '/user', leading: const Icon(Icons.person), title: const Text('Usuarios'), onTap: () => context.go('/user')),
              ListTile(selected: current == '/olts', leading: const Icon(Icons.memory), title: const Text('OLTs'), onTap: () => context.go('/olts')),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () { _auth.session = null; context.go('/login'); },
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/user', builder: (_, __) => const _HomeScaffold(current: '/user', child: UserScreen())),
    GoRoute(path: '/olts', builder: (_, __) => const _HomeScaffold(current: '/olts', child: OltsScreen())),
    // NUEVO: formulario de foto; recibimos el OltHost por extra
    GoRoute(
      path: '/olts/foto',
      builder: (context, state) {
        final item = state.extra as OltHost;
        return _HomeScaffold(current: '/olts', child: OltPhotoFormScreen(item: item));
      },
    ),
  ],
  redirect: (context, state) {
    final loggingIn = state.fullPath == '/login';
    if (!_auth.isLoggedIn && !loggingIn) return '/login';
    if (_auth.isLoggedIn && loggingIn) return '/user';
    return null;
  },
  refreshListenable: _auth,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'App Soporte', routerConfig: router);
  }
}
