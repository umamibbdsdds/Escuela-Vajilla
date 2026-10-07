import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/encabezado_seccion.dart';
import '../../widgets/indicador_carga.dart';
import '../../widgets/mensaje_error.dart';
import '../../widgets/estado_vacio.dart';

/// ============================================================
///  ReportesAdminScreen — Reportes del admin (migrada al tema)
///  Contiene: total, promedio, más vendido, reportes meseros/clientes
/// ============================================================
class ReportesAdminScreen extends StatefulWidget {
  const ReportesAdminScreen({super.key});
  @override
  State<ReportesAdminScreen> createState() => _ReportesAdminScreenState();
}

class _ReportesAdminScreenState extends State<ReportesAdminScreen> {
  Map<String, dynamic>? _totales;
  List<dynamic>? _masVendido;
  List<dynamic>? _meseros;
  List<dynamic>? _clientes;
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final total = await ApiService.getReporteTotal();
      final promedio = await ApiService.getReportePromedio();
      _totales = {'total': total['total'], 'promedio': promedio['promedio']};
      _masVendido = await ApiService.getReporteMasVendido();
      _meseros = await ApiService.getAdminReporteMeseros();
      _clientes = await ApiService.getAdminReporteClientes();
      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const IndicadorCarga(mensaje: 'Cargando reportes...');
    if (_error != null) return MensajeError(mensaje: _error!, onReintentar: _cargar);

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Totales
          EncabezadoSeccion(titulo: 'Resumen financiero'),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Text('Total vendido', style: AppTypography.caption),
                        Text('\$${(_totales?['total'] ?? 0).toStringAsFixed(2)}', style: AppTypography.headlineWith(AppColors.success)),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Text('Promedio por orden', style: AppTypography.caption),
                        Text('\$${(_totales?['promedio'] ?? 0).toStringAsFixed(2)}', style: AppTypography.headlineWith(AppColors.info)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Más vendidos
          EncabezadoSeccion(titulo: 'Platillos más vendidos'),
          if (_masVendido == null || _masVendido!.isEmpty)
            const EstadoVacio(icono: Icons.trending_up_rounded, mensaje: 'Aún no hay datos')
          else
            ..._masVendido!.map((p) => Card(
              child: ListTile(
                leading: const Icon(Icons.restaurant_rounded, color: AppColors.primary),
                title: Text(p['nombre'] ?? '', style: AppTypography.body),
                trailing: Text('${p['total_vendido'] ?? 0} uds', style: AppTypography.bodyBold),
              ),
            )),
          const SizedBox(height: AppSpacing.xl),
          // Reportes por mesero
          EncabezadoSeccion(titulo: 'Reporte de meseros'),
          if (_meseros == null || _meseros!.isEmpty)
            const EstadoVacio(icono: Icons.person_outline_rounded, mensaje: 'Sin datos')
          else
            ..._meseros!.map((m) => Card(
              child: ListTile(
                leading: const Icon(Icons.person_rounded, color: AppColors.info),
                title: Text(m['usuario'] ?? '', style: AppTypography.body),
                subtitle: Text('${m['total_ordenes'] ?? 0} órdenes', style: AppTypography.caption),
                trailing: Text('\$${(double.tryParse(m['total_ventas']?.toString() ?? '0') ?? 0).toStringAsFixed(2)}', style: AppTypography.bodyBold),
              ),
            )),
        ],
      ),
    );
  }
}
