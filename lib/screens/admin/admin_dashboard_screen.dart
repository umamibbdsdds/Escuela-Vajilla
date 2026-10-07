import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/session.dart';
import '../../services/api_service.dart';
import '../../widgets/tarjeta_resumen.dart';
import '../../widgets/indicador_carga.dart';
import '../../widgets/mensaje_error.dart';
import '../../widgets/encabezado_seccion.dart';
import 'admin_drawer.dart';
import 'personal_cuentas_screen.dart';
import 'registro_platillo_screen.dart';

/// ============================================================
///  AdminDashboardScreen — pantalla inicial del panel admin
///  Muestra resumen en tarjetas; las demás funciones van en el Drawer
/// ============================================================
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminSection _selectedSection = AdminSection.dashboard;
  Map<String, dynamic>? _resumen;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    setState(() { _cargando = true; _error = null; });
    try {
      _resumen = await ApiService.getAdminResumen();
      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 700;
    return Scaffold(
      appBar: AppBar(
        title: const Text('UMAMI — Panel'),
        leading: isWide ? null : Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          // Badge de alertas
          FutureBuilder<int>(
            future: ApiService.getAlertasCount(),
            builder: (_, snap) {
              final count = snap.data ?? 0;
              if (count == 0) return const SizedBox.shrink();
              return Badge(
                label: Text('$count'),
                backgroundColor: AppColors.error,
                child: IconButton(
                  icon: const Icon(Icons.notifications_rounded),
                  onPressed: () => _selectSection(AdminSection.alertas),
                ),
              );
            },
          ),
        ],
      ),
      drawer: AdminDrawer(
        selectedSection: _selectedSection,
        onSectionSelected: (s) {
          Navigator.of(context).pop(); // Cerrar drawer
          _selectSection(s);
        },
      ),
      body: _buildBody(),
    );
  }

  void _selectSection(AdminSection section) {
    setState(() => _selectedSection = section);
    // Refrescar datos según la sección
    if (section == AdminSection.dashboard) _cargarResumen();
  }

  Widget _buildBody() {
    if (_cargando) return const IndicadorCarga(mensaje: 'Cargando resumen...');
    if (_error != null) return MensajeError(mensaje: _error!, onReintentar: _cargarResumen);

    return switch (_selectedSection) {
      AdminSection.dashboard => _buildDashboard(),
      AdminSection.platillos => const RegistroPlatilloScreen(),
      AdminSection.personal => const PersonalCuentasScreen(),
      // Las demás secciones irán aquí en fases siguientes
      _ => _placeholderSection(),
    };
  }

  Widget _buildDashboard() {
    final r = _resumen ?? {};
    return RefreshIndicator(
      onRefresh: _cargarResumen,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          EncabezadoSeccion(
            titulo: 'Resumen general',
            subtitulo: 'Bienvenido, ${Session().usuario}',
          ),
          const SizedBox(height: AppSpacing.md),
          // Tarjetas de resumen 2x2
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.3,
            children: [
              TarjetaResumen(
                titulo: 'Ventas del día',
                valor: '\$${(r['ventas_hoy'] ?? 0).toStringAsFixed(2)}',
                icono: Icons.attach_money_rounded,
                color: AppColors.success,
                onTap: () => _selectSection(AdminSection.dashboard),
              ),
              TarjetaResumen(
                titulo: 'Pedidos activos',
                valor: '${r['pedidos_activos'] ?? 0}',
                icono: Icons.receipt_long_rounded,
                color: AppColors.info,
                onTap: () => _selectSection(AdminSection.vistaViva),
              ),
              TarjetaResumen(
                titulo: 'Mesas ocupadas',
                valor: '${r['mesas_ocupadas'] ?? 0}',
                icono: Icons.table_restaurant_rounded,
                color: AppColors.warning,
                onTap: () => _selectSection(AdminSection.mesas),
              ),
              TarjetaResumen(
                titulo: 'Alertas',
                valor: '${r['alertas_pendientes'] ?? 0}',
                icono: Icons.notification_important_rounded,
                color: AppColors.error,
                onTap: () => _selectSection(AdminSection.alertas),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          EncabezadoSeccion(titulo: 'Acciones rápidas'),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              ActionChip(
                avatar: const Icon(Icons.restaurant_menu_rounded, size: 18),
                label: Text('Platillos', style: AppTypography.caption),
                onPressed: () => _selectSection(AdminSection.platillos),
              ),
              ActionChip(
                avatar: const Icon(Icons.people_rounded, size: 18),
                label: Text('Personal', style: AppTypography.caption),
                onPressed: () => _selectSection(AdminSection.personal),
              ),
              ActionChip(
                avatar: const Icon(Icons.table_restaurant_rounded, size: 18),
                label: Text('Mesas', style: AppTypography.caption),
                onPressed: () => _selectSection(AdminSection.mesas),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholderSection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 64, color: AppColors.neutral),
          const SizedBox(height: AppSpacing.lg),
          Text('Sección en construcción', style: AppTypography.subtitle.copyWith(color: AppColors.textSecondary)),
          Text('Disponible en fases posteriores', style: AppTypography.caption),
        ],
      ),
    );
  }
}
