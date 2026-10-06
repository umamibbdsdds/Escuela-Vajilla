import 'package:flutter/material.dart';

// Importas las pantallas desde la estructura de carpetas de lib/
import 'screens/login_screen.dart';
import 'screens/cocina/cola_cocina_screen.dart';
import 'screens/mesero/entrega_codigo_screen.dart';
import 'screens/admin/personal_cuentas_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const RestauranteApp());
}

class RestauranteApp extends StatelessWidget {
  const RestauranteApp({Key? key}) : super(key: key);

  static const String baseUrl = 'https://web-production-b4b0c8.up.railway.app/api';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurante App',
      theme: AppTheme.lightTheme, // Tema importado de theme/app_theme.dart
      debugShowCheckedModeBanner: false,
      home: LoginScreen(baseUrl: baseUrl), // Pantalla importada de screens/login_screen.dart
    );
  }
}
