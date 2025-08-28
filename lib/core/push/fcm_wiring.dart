import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../app.dart'; // debe exportar tu `router` global (GoRouter router)
import '../../features/ordenes_status/domain/order_status_args.dart';

final _fln = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Podrías hacer logging o pre-procesamiento aquí si lo necesitas.
}

Future<void> _initLocalNotifications() async {
  const initAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  // 👇 MUY IMPORTANTE: handler cuando el usuario toca la notificación local (foreground)
  await _fln.initialize(
    const InitializationSettings(android: initAndroid),
    onDidReceiveNotificationResponse: (NotificationResponse resp) {
      try {
        final payload = resp.payload;
        if (payload == null || payload.isEmpty) {
          router.push('/ordenes');
          return;
        }
        // El payload lo guardamos como JSON String
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _navigateFromData(data);
      } catch (_) {
        router.push('/ordenes');
      }
    },
  );

  const channel = AndroidNotificationChannel(
    'ordenes',
    'Órdenes',
    description: 'Notificaciones de órdenes',
    importance: Importance.high,
  );
  await _fln
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

Future<void> _requestNotifPermissions() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true, badge: true, sound: true,
  );
}

void _navigateFromData(Map<String, dynamic> data) {
  // Normaliza tipos (a veces llegan como int, a veces String)
  final route = (data['route'] ?? data['Route'])?.toString();
  final osStr  = (data['ordenServicioId'] ?? data['OrdenServicioID'])?.toString();
  final stStr  = (data['statusOrderId'] ?? data['StatusOrderID'])?.toString();

  final os = int.tryParse(osStr ?? '');
  final st = int.tryParse(stStr ?? '');

  // Soporta ambas rutas que has usado en el proyecto
  if (route == '/estatus' || route == '/ordenes/estatus') {
    if (os != null) {
      router.push(route == '/ordenes/estatus' ? '/ordenes/estatus' : '/estatus',
        extra: OrderStatusArgs(ordenServicioId: os, statusOrderId: st),
      );
      return;
    }
  }

  // Fallback
  router.push('/ordenes');
}

Future<void> initFcmWiring() async {
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(fcmBackgroundHandler);

  await _initLocalNotifications();
  await _requestNotifPermissions();

  // FOREGROUND: mostramos notificación local y pasamos el data como payload JSON
  FirebaseMessaging.onMessage.listen((msg) {
    final n = msg.notification;
    if (n != null) {
      final payloadJson = jsonEncode(msg.data); // 👈 para que onDidReceiveNotificationResponse navegue
      _fln.show(
        n.hashCode,
        n.title,
        n.body,
        const NotificationDetails(
          android: AndroidNotificationDetails('ordenes', 'Órdenes', importance: Importance.high),
        ),
        payload: payloadJson,
      );
    }
  });

  // BACKGROUND (app abierta) → tocar notificación
  FirebaseMessaging.onMessageOpenedApp.listen((msg) {
    _navigateFromData(msg.data);
  });

  // TERMINADA (cold start) → abrir desde notificación
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    // Espera 1 frame para asegurar que el árbol & router estén listos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateFromData(initial.data);
    });
  }

  // (Opcional) Log del token para pruebas
  final token = await FirebaseMessaging.instance.getToken();
  if (kDebugMode) print('FCM TOKEN: $token');

  FirebaseMessaging.instance.onTokenRefresh.listen((t) {
    if (kDebugMode) print('FCM TOKEN REFRESH: $t');
    // Aquí luego lo envías a tu backend si ya registras tokens
  });
}
