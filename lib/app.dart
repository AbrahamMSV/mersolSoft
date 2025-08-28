import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/di/locator.dart';
import 'features/auth/presentation/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/ordenes/presentation/ordenes_screen.dart';
import 'features/diagnostico_orden/presentation/diagnostico_screen.dart';
import 'features/ordenes_foto/presentation/ordenes_foto_form_screen.dart';
import 'features/ordenes/domain/olt_host.dart';
import 'features/form_diagnostico/presentation/form_diagnostico_screen.dart';
import 'features/card_refacciones/presentation/refacciones_screen.dart';
import 'features/form_refacciones/presentation/form_refacciones_screen.dart';
import 'features/card_refacciones/domain/refaccion_args.dart';
import 'features/ordenes_status/domain/order_status_args.dart';
import 'features/ordenes_status/presentation/order_status_screen.dart';

final _auth = locator<AuthController>();

class _HomeScaffold extends StatelessWidget {
  final Widget child;
  final String current;
  const _HomeScaffold({required this.child, required this.current, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const DrawerHeader(child: Text('Menú')),
              ListTile(
                selected: current == '/ordenes',
                leading: const Icon(Icons.assignment), // icono más acorde
                title: const Text('Órdenes'),
                onTap: () => context.go('/ordenes'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () async {
                  await locator<AuthController>().logout();
                  // al cerrar sesión, siempre al login
                  if (context.mounted) context.go('/login');
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
    // Auth
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

    // ÓRDENES (antes /olts)
    GoRoute(
      path: '/ordenes',
      builder: (_, __) => const _HomeScaffold(
        current: '/ordenes',
        child: OrdenesScreen(), // seguimos usando tu OltsScreen como UI
      ),
    ),

    // Alias opcional por compatibilidad: /olts → /ordenes
    GoRoute(
      path: '/ordenes',
      redirect: (_, __) => '/ordenes',
    ),

    // FOTO desde ordenes (alias nuevo)
    GoRoute(
      path: '/ordenes/foto',
      builder: (context, state) {
        final item = state.extra as OltHost;
        return _HomeScaffold(
          current: '/ordenes',
          child: OltPhotoFormScreen(item: item),
        );
      },
    ),
    // Alias opcional: si en algún punto aún navegan a /olts/foto
    GoRoute(
      path: '/ordenes/foto',
      redirect: (context, state) => '/ordenes/foto',
    ),

    // Diagnósticos
    GoRoute(
      path: '/diagnosticos',
      builder: (context, state) {
        final ordenId = state.extra as int;
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
        final int? diagnosticoId = switch (extra) {
          final int v => v,
          final String s => int.tryParse(s),
          _ => null,
        };
        return _HomeScaffold(
          current: '/diagnosticos',
          child: OltPhotoFormScreen(
            item: null,
            diagnosticoId: diagnosticoId,
          ),
        );
      },
    ),
    GoRoute(
      path: '/diagnosticos/nuevo',
      builder: (context, state) {
        final osId = state.extra as int;
        return _HomeScaffold(
          current: '/diagnosticos',
          child: FormDiagnosticoScreen(ordenServicioId: osId),
        );
      },
    ),

    // Refacciones

    GoRoute(
      path: '/refacciones',
      builder: (context, state) {
        final extra = state.extra;
        RefaccionesArgs? args;

        if (extra is RefaccionesArgs) {
          args = extra;
        } else if (extra is int) {
          args = RefaccionesArgs(ordenServicioId: extra);
        } else if (extra is Map) {
          final os = extra['ordenServicioId'];
          final st = extra['statusOrderId'];
          if (os is int) {
            args = RefaccionesArgs(
              ordenServicioId: os,
              statusOrderId: st is int ? st : null,
            );
          }
        }

        if (args == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Faltan parámetros (OrdenServicioID)')),
            );
            GoRouter.of(context).go('/ordenes');
          });
          return const SizedBox.shrink();
        }

        return _HomeScaffold(
          current: '/refacciones',
          child: RefaccionesScreen(
            ordenServicioId: args.ordenServicioId,
            statusOrderId: args.statusOrderId, // 👈 se pasa al screen
          ),
        );
      },
    ),

    GoRoute(
      path: '/refacciones/nuevo',
      builder: (context, state) {
        final extra = state.extra;
        RefaccionesArgs? args;

        if (extra is RefaccionesArgs) {
          args = extra;
        } else if (extra is int) {
          args = RefaccionesArgs(ordenServicioId: extra);
        } else if (extra is Map) {
          final os = extra['ordenServicioId'];
          final st = extra['statusOrderId'];
          if (os is int) {
            args = RefaccionesArgs(
              ordenServicioId: os,
              statusOrderId: st is int ? st : null,
            );
          }
        }

        if (args == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Faltan parámetros (OrdenServicioID)')),
            );
            GoRouter.of(context).go('/refacciones');
          });
          return const SizedBox.shrink();
        }

        return _HomeScaffold(
          current: '/refacciones',
          child: FormRefaccionesScreen(
            ordenServicioId: args.ordenServicioId,
            statusOrderId: args.statusOrderId, // 👈 se pasa al form
          ),
        );
      },
    ),


    // Estatus
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Faltan parámetros de estatus')),
            );
            GoRouter.of(context).go('/ordenes');
          });
          return const SizedBox.shrink();
        }
        return _HomeScaffold(current: '/estatus', child: OrderStatusScreen(args: args));
      },
    ),
  ],

  // Redirecciones globales de sesión
  redirect: (context, state) {
    final loggingIn = state.fullPath == '/login';
    if (!_auth.isLoggedIn && !loggingIn) return '/login';
    if (_auth.isLoggedIn && loggingIn) return '/ordenes'; // ← al iniciar sesión: directo a Órdenes
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
