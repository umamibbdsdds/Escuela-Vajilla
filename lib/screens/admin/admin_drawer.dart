import 'package:flutter/material.dart';
import '../login_screen.dart';
import '../../theme/app_theme.dart';
import '../../core/session.dart';
import '../../services/auth_service.dart';

/// ============================================================
///  AdminDrawer — Menú desplegable del panel de administración
///  Drawer en teléfono, NavigationRail en tablet/escritorio
/// ============================================================

enum AdminSection {
  vistaViva,
  alertas,
  platillos,
  categorias,
  disponibilidad,
  mesas,
  personal,
  dashboard,
  reportesMeseros,
  reportesClientes,
  estadisticas,
  exportar,
  historial,
  resenas, // era reseñas — no se permiten caracteres no-ASCII en identificadores
}

class AdminDrawerOption {
  final AdminSection section;
  final String title;
  final IconData icon;
  const AdminDrawerOption(this.section, this.title, this.icon);
}

const List<AdminDrawerOption> operationOptions = [
  AdminDrawerOption(AdminSection.vistaViva, 'Vista en vivo', Icons.monitor_rounded),
  AdminDrawerOption(AdminSection.alertas, 'Alertas', Icons.notification_important_rounded),
];

const List<AdminDrawerOption> menuOptions = [
  AdminDrawerOption(AdminSection.platillos, 'Platillos', Icons.restaurant_menu_rounded),
  AdminDrawerOption(AdminSection.categorias, 'Categorías', Icons.category_rounded),
  AdminDrawerOption(AdminSection.disponibilidad, 'Disponibilidad', Icons.toggle_on_rounded),
];

const List<AdminDrawerOption> restaurantOptions = [
  AdminDrawerOption(AdminSection.mesas, 'Mesas y tablets', Icons.table_restaurant_rounded),
  AdminDrawerOption(AdminSection.personal, 'Personal y cuentas', Icons.people_rounded),
];

const List<AdminDrawerOption> analysisOptions = [
  AdminDrawerOption(AdminSection.dashboard, 'Dashboard', Icons.dashboard_rounded),
  AdminDrawerOption(AdminSection.reportesMeseros, 'Reportes de meseros', Icons.person_search_rounded),
  AdminDrawerOption(AdminSection.reportesClientes, 'Reportes de clientes', Icons.group_rounded),
  AdminDrawerOption(AdminSection.estadisticas, 'Estadísticas', Icons.bar_chart_rounded),
  AdminDrawerOption(AdminSection.exportar, 'Exportar', Icons.file_download_rounded),
  AdminDrawerOption(AdminSection.historial, 'Historial de órdenes', Icons.history_rounded),
];

const List<AdminDrawerOption> reviewOptions = [
  AdminDrawerOption(AdminSection.resenas, 'Reseñas', Icons.star_rounded),
];

class AdminDrawer extends StatelessWidget {
  final AdminSection selectedSection;
  final ValueChanged<AdminSection> onSectionSelected;

  const AdminDrawer({
    super.key,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final session = Session.instance;
    final isWide = MediaQuery.of(context).size.width >= 700;

    if (isWide) {
      return _buildNavigationRail(context, session);
    }
    return _buildDrawer(context, session);
  }

  Widget _buildDrawer(BuildContext context, Session session) {
    return Drawer(
      child: Container(
        color: AppColors.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(session, isWide: false),
            const Divider(height: 1),
            _sectionGroup('Operación', operationOptions),
            _sectionGroup('Menú', menuOptions),
            _sectionGroup('Restaurante', restaurantOptions),
            _sectionGroup('Análisis', analysisOptions),
            _sectionGroup('', reviewOptions),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text('Cerrar sesión', style: AppTypography.body.copyWith(color: AppColors.error)),
              onTap: () => _logout(context),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, Session session) {
    return NavigationRail(
      selectedIndex: _sectionToIndex(selectedSection),
      onDestinationSelected: (i) => onSectionSelected(_indexToSection(i)),
      extended: true,
      minWidth: 72,
      minExtendedWidth: 240,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Column(
          children: [
            Image.asset('assets/icon/UMAMI_Logo_transparente.png', height: 40,
              errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_rounded, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(session.usuario ?? '', style: AppTypography.caption, overflow: TextOverflow.ellipsis),
            Text(session.rol ?? '', style: AppTypography.overline.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        tooltip: 'Cerrar sesión',
        onPressed: () => _logout(context),
      ),
      destinations: _allDestinations(),
    );
  }

  List<NavigationRailDestination> _allDestinations() {
    final all = [...operationOptions, ...menuOptions, ...restaurantOptions, ...analysisOptions, ...reviewOptions];
    return all.map((o) => NavigationRailDestination(
      icon: Icon(o.icon),
      selectedIcon: Icon(o.icon, color: AppColors.primary),
      label: Text(o.title, style: AppTypography.caption),
    )).toList();
  }

  int _sectionToIndex(AdminSection s) {
    final all = [...operationOptions, ...menuOptions, ...restaurantOptions, ...analysisOptions, ...reviewOptions];
    return all.indexWhere((o) => o.section == s).clamp(0, all.length - 1);
  }

  AdminSection _indexToSection(int i) {
    final all = [...operationOptions, ...menuOptions, ...restaurantOptions, ...analysisOptions, ...reviewOptions];
    return all[i.clamp(0, all.length - 1)].section;
  }

  Widget _buildHeader(Session session, {required bool isWide}) {
    return DrawerHeader(
      decoration: const BoxDecoration(color: AppColors.appBar),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/icon/UMAMI_Logo_transparente.png', height: 52,
            errorBuilder: (_, __, ___) => const Icon(Icons.restaurant_rounded, size: 44, color: AppColors.primaryLight),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(session.usuario ?? 'Admin', style: AppTypography.subtitle.copyWith(color: Colors.white)),
          Text(session.rol ?? '', style: AppTypography.overline.copyWith(color: AppColors.primaryLight)),
        ],
      ),
    );
  }

  Widget _sectionGroup(String titulo, List<AdminDrawerOption> opciones) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xs),
            child: Text(titulo.toUpperCase(), style: AppTypography.overline.copyWith(color: AppColors.textHint)),
          ),
        ],
        ...opciones.map((o) => ListTile(
          leading: Icon(o.icon, size: 22,
            color: selectedSection == o.section ? AppColors.primary : AppColors.textSecondary,
          ),
          title: Text(o.title, style: selectedSection == o.section
            ? AppTypography.bodyBold.copyWith(color: AppColors.primary)
            : AppTypography.body,
          ),
          selected: selectedSection == o.section,
          selectedTileColor: AppColors.primary.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          onTap: () => onSectionSelected(o.section),
        )),
        const Divider(indent: AppSpacing.xl, endIndent: AppSpacing.xl),
      ],
    );
  }

  void _logout(BuildContext context) async {
    await AuthService.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
