import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/encabezado_seccion.dart';
import '../../widgets/indicador_carga.dart';
import '../../widgets/mensaje_error.dart';

class EstadisticasAdminScreen extends StatefulWidget {
  const EstadisticasAdminScreen({super.key});
  @override
  State<EstadisticasAdminScreen> createState() => _EstadisticasAdminScreenState();
}

class _EstadisticasAdminScreenState extends State<EstadisticasAdminScreen> {
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
      _meseros = await ApiService.getEstadisticasMeseros();
      _clientes = await ApiService.getEstadisticasClientes();
      if (mounted) setState(() => _cargando = false);
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const IndicadorCarga(mensaje: 'Cargando estadísticas...');
    if (_error != null) return MensajeError(mensaje: _error!, onReintentar: _cargar);

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          EncabezadoSeccion(titulo: 'Estadísticas de meseros'),
          const SizedBox(height: AppSpacing.md),
          if (_meseros != null && _meseros!.isNotEmpty)
            SizedBox(
              height: 200,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_meseros![v.toInt()]['usuario'] ?? '', style: AppTypography.label),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _meseros!.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(
                    toY: (double.tryParse(e.value['ventas']?.toString() ?? '0') ?? 0),
                    color: AppColors.primary,
                    width: 22,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sm)),
                  )],
                )).toList(),
              )),
            )
          else
            // Quitado 'const' — AppTypography.caption no es constante
            Text('Sin datos de meseros', style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xxl),
          EncabezadoSeccion(titulo: 'Estadísticas de clientes'),
          const SizedBox(height: AppSpacing.md),
          if (_clientes != null && _clientes!.isNotEmpty)
            SizedBox(
              height: 200,
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_clientes![v.toInt()]['usuario'] ?? '', style: AppTypography.label),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _clientes!.asMap().entries.map((e) => BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(
                    toY: (double.tryParse(e.value['gastado']?.toString() ?? '0') ?? 0),
                    color: AppColors.info,
                    width: 22,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sm)),
                  )],
                )).toList(),
              )),
            )
          else
            // Quitado 'const' — AppTypography.caption no es constante
            Text('Sin datos de clientes', style: AppTypography.caption),
        ],
      ),
    );
  }
}
