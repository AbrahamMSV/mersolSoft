import 'package:flutter/material.dart';
import 'core/di/locator.dart';
import 'app.dart';
import 'core/session/session_store.dart';
import 'core/push/fcm_wiring.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await locator<SessionStore>().hydrate();

  runApp(const MyApp());

  // 👇 Despues de montar el árbol
  await initFcmWiring();
}