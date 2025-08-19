import 'package:flutter/material.dart';
import 'core/di/locator.dart';
import 'app.dart';
import 'core/session/session_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  await locator<SessionStore>().hydrate(); // ← carga “cookie”
  runApp(const MyApp());
}
