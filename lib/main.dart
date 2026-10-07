import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Servidor en Railway
static const String baseUrl = 'https://web-production-b4b0c8.up.railway.app';

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

class _Root extends StatelessWidget {
  final bool hasSession;
  const _Root({required this.hasSession});

  @override
  Widget build(BuildContext context) {
    if (!hasSession) return const LoginScreen();
    final rol = Session.instance.rol ?? 'invitado';
    switch (rol) {
      case 'administrador': return const AdminShell();
      case 'mesero': return const VistaMesasScreen();
      case 'cocinero': return const ColaCocinaScreen();
      case 'cliente': return const MenuClienteScreen();
      default: return const LoginScreen();
    }
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});
  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  AdminSection _seccion = AdminSection.dashboard;

  Widget _pantalla() {
    switch (_seccion) {
      case AdminSection.dashboard: return const AdminDashboardScreen();
      case AdminSection.platillos: return const RegistroPlatilloScreen();
      case AdminSection.personal: return const PersonalCuentasScreen();
      case AdminSection.reportesMeseros: return const ReportesAdminScreen();
      case AdminSection.reportesClientes: return const ReportesAdminScreen();
      case AdminSection.estadisticas: return const EstadisticasAdminScreen();
      case AdminSection.exportar: return const ExportarScreen();
      default: return const AdminDashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            AdminDrawer(
              selectedSection: _seccion,
              onSectionSelected: (s) => setState(() => _seccion = s),
            ),
            Expanded(child: _pantalla()),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: AdminDrawer(
        selectedSection: _seccion,
        onSectionSelected: (s) {
          setState(() => _seccion = s);
          Navigator.pop(context);
        },
      ),
      appBar: AppBar(title: const Text('UMAMI Admin')),
      body: _pantalla(),
    );
  }
}
