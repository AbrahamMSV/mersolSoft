import 'package:flutter/material.dart';
import 'core/di/locator.dart';
import 'app.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}
