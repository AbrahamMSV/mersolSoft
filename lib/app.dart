import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/di/locator.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/user/presentation/user_screen.dart';
import 'features/olts/presentation/olts_screen.dart';
import 'features/diagnostico_ordenservicio/presentation/diagnostico_screen.dart';
import 'features/olt_photo/presentation/olt_photo_form_screen.dart';
import 'features/olts/domain/olt_host.dart';
import 'features/form_diagnostico/presentation/form_diagnostico_screen.dart';
import 'features/card_refacciones/presentation/refacciones_screen.dart';
import 'features/form_refacciones/presentation/form_refacciones_screen.dart';
import 'features/order_status/domain/order_status_args.dart';
import 'features/order_status/presentation/order_status_screen.dart';
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
              ListTile(selected: current == '/user', leading: const Icon(Icons.person), title: const Text('Inicio'), onTap: () => context.go('/user')),
              ListTile(selected: current == '/olts', leading: const Icon(Icons.memory), title: const Text('Ordenes'), onTap: () => context.go('/olts')),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  await locator<AuthController>().logout();
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
    GoRoute(
      path: '/diagnosticos',
      builder: (context, state) {
        final ordenId = state.extra as int; // ← viene desde la card OLT
        return _HomeScaffold(
          current: '/diagnosticos',
          child: DiagnosticoScreen(ordenServicioId: ordenId),
        );
      },
    ),
    GoRoute(
      path: '/diagnosticos/foto',
      builder: (context, state) {
        final extra = state.extra;

        // Acepta int directo o string numérica, si no, queda null
        final int? diagnosticoId = switch (extra) {
          final int v => v,
          final String s => int.tryParse(s),
          _ => null,
        };
        return _HomeScaffold(
          current: '/diagnosticos',
          child: OltPhotoFormScreen(
            item: null,                    // ya no venimos desde OLT
            diagnosticoId: diagnosticoId,  // <<-- ¡aquí va el ID real!
          ),
        );
      },
    ),
    GoRoute(
      path: '/diagnosticos/nuevo',
      builder: (context, state) {
        final osId = state.extra as int; // OrdenServicioID
        return _HomeScaffold(
          current: '/diagnosticos',
          child: FormDiagnosticoScreen(ordenServicioId: osId),
        );
      },
    ),
    GoRoute(
      path: '/refacciones',
      builder: (context, state) {
        final osId = state.extra as int?;  // robustez: podría venir string
        if (osId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta OrdenServicioID')));
            GoRouter.of(context).go('/olts');
          });
          return const SizedBox.shrink();
        }
        return _HomeScaffold(
          current: '/refacciones',
          child: RefaccionesScreen(ordenServicioId: osId),
        );
      },
    ),
    GoRoute(
      path: '/refacciones/nuevo',
      builder: (context, state) {
        final osId = state.extra as int?;
        if (osId == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Falta OrdenServicioID')));
            GoRouter.of(context).go('/refacciones');
          });
          return const SizedBox.shrink();
        }
        return _HomeScaffold(
          current: '/refacciones',
          child: FormRefaccionesScreen(ordenServicioId: osId),
        );
      },
    ),
    GoRoute(
      path: '/estatus',
      builder: (context, state) {
        final extra = state.extra;
        OrderStatusArgs? args;
        if (extra is OrderStatusArgs) {
          args = extra;
        } else if (extra is Map) {
          final os = extra['ordenServicioId'];
          final st = extra['statusOrderId'];
          if (os is int) {
            args = OrderStatusArgs(ordenServicioId: os, statusOrderId: st is int ? st : null);
          }
        }
        if (args == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faltan parámetros de estatus')));
            GoRouter.of(context).go('/olts');
          });
          return const SizedBox.shrink();
        }
        return _HomeScaffold(
          current: '/estatus',
          child: OrderStatusScreen(args: args),
        );
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
