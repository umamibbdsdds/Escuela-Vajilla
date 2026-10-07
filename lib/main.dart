import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'core/session.dart';
import 'services/api_client.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_drawer.dart';
import 'screens/admin/personal_cuentas_screen.dart';
import 'screens/admin/registro_platillo_screen.dart';
import 'screens/admin/reportes_admin_screen.dart';
import 'screens/admin/estadisticas_admin_screen.dart';
import 'screens/admin/exportar_screen.dart';
import 'screens/cliente/menu_cliente_screen.dart';
import 'screens/mesero/vista_mesas_screen.dart';
import 'screens/cocina/cola_cocina_screen.dart';

/// ============================================================
///  main.dart — Bootstrap con tema, rutas iniciales por rol
///  IP configurable en ApiClient.baseUrl
/// ============================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // IP configurable — cambiar antes de correr
  ApiClient.baseUrl = 'http://10.0.2.2:3000'; // Android emulator
  // ApiClient.baseUrl = 'http://192.168.1.X:3000'; // Dispositivo físico

  // Restaurar sesión previa
  final restored = await Session.instance.restore();

  runApp(UmamiApp(restoredSession: restored));
}

class UmamiApp extends StatelessWidget {
  final bool restoredSession;
  const UmamiApp({super.key, this.restoredSession = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UMAMI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: Session.instance.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _Root(hasSession: restoredSession),
      routes: {
        '/login': (ctx) => const LoginScreen(),
        '/admin': (ctx) => const AdminShell(),
        '/admin/dashboard': (ctx) => const AdminDashboardScreen(),
        '/admin/personal': (ctx) => const PersonalCuentasScreen(),
        '/admin/platillos': (ctx) => const RegistroPlatilloScreen(),
        '/admin/reportes': (ctx) => const ReportesAdminScreen(),
        '/admin/estadisticas': (ctx) => const EstadisticasAdminScreen(),
        '/admin/exportar': (ctx) => const ExportarScreen(),
        '/mesero': (ctx) => const VistaMesasScreen(),
        '/cocina': (ctx) => const ColaCocinaScreen(),
        '/cliente': (ctx) => const MenuClienteScreen(),
      },
    );
  }
}

/// Root — decide pantalla inicial según sesión existente
class _Root extends StatelessWidget {
  final bool hasSession;
  const _Root({required this.hasSession});

  @override
  Widget build(BuildContext context) {
    if (!hasSession) return const LoginScreen();
    final rol = Session.instance.rol ?? 'invitado';
    return switch (rol) {
      'administrador' => const AdminShell(),
      'mesero' => const VistaMesasScreen(),
      'cocinero' => const ColaCocinaScreen(),
      'cliente' => const MenuClienteScreen(),
      _ => const LoginScreen(),
    };
  }
}

/// AdminShell — Drawer + contenido por sección
class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminDrawer(child: AdminDashboardScreen());
  }
}
