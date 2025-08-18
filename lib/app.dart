import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/di/locator.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/user/presentation/user_screen.dart';
import 'features/olts/presentation/olts_screen.dart';

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
              ListTile(
                selected: current == '/user',
                leading: const Icon(Icons.person),
                title: const Text('Usuarios'),
                onTap: () => context.go('/user'),
              ),
              ListTile(
                selected: current == '/olts',
                leading: const Icon(Icons.memory),
                title: const Text('OLTs'),
                onTap: () => context.go('/olts'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  _auth.session = null;
                  context.go('/login');
                },
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
    GoRoute(
      path: '/user',
      builder: (context, state) => const _HomeScaffold(
        current: '/user',
        child: UserScreen(),
      ),
    ),
    GoRoute(
      path: '/olts',
      builder: (context, state) => const _HomeScaffold(
        current: '/olts',
        child: OltsScreen(),
      ),
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
    return MaterialApp.router(
      title: 'App Soporte',
      routerConfig: router,
    );
  }
}
