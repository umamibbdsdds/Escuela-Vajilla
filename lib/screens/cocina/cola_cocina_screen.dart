import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/polling_service.dart';
import '../../models/orden_model.dart';
import '../../widgets/chip_estado.dart';
import '../../widgets/indicador_carga.dart';
import '../../widgets/mensaje_error.dart';

/// ============================================================
///  ColaCocinaScreen — 3 columnas: Recibido / Preparando / Listo
///  Cada tarjeta muestra número de mesa, items y timer.
///  El cocinero arrastra o presiona botón para avanzar estado.
/// ============================================================
class ColaCocinaScreen extends StatefulWidget {
  const ColaCocinaScreen({super.key});
  @override
  State<ColaCocinaScreen> createState() => _ColaCocinaScreenState();
}

class _ColaCocinaScreenState extends State<ColaCocinaScreen> {
  List<OrdenModel> _ordenes = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
    PollingService.start(5, (_) => _cargar());
  }

  @override
  void dispose() {
    PollingService.stop();
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final data = await ApiService.getCocinaOrdenes();
      final models = (data as List).map((o) => OrdenModel.fromJson(o)).toList();
      if (mounted) setState(() { _ordenes = models; _cargando = false; });
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  Future<void> _avanzarEstado(OrdenModel orden) async {
    final siguiente = orden.estado == 'recibido' ? 'preparando' : 'listo';
    try {
      await ApiService.putCocinaOrdenEstado(orden.id, siguiente);
      _cargar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  List<OrdenModel> _filtrar(String estado) => _ordenes.where((o) => o.estado == estado).toList();

  String _tiempoTranscurrido(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando && _ordenes.isEmpty) return const IndicadorCarga(mensaje: 'Cargando cola...');
    if (_error != null) return MensajeError(mensaje: _error!, onReintentar: _cargar);

    final recibidas = _filtrar('recibido');
    final preparando = _filtrar('preparando');
    final listas = _filtrar('listo');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cocina'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _cargar),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // En teléfono: 1 columna scrollable; en tablet/desktop: 3 columnas
          final esTablet = constraints.maxWidth > 700;
          if (!esTablet) {
            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Recibido', icon: Icon(Icons.receipt_long_rounded)),
                      Tab(text: 'Preparando', icon: Icon(Icons.soup_kitchen_rounded)),
                      Tab(text: 'Listo', icon: Icon(Icons.done_all_rounded)),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildLista(recibidas, Icons.play_arrow_rounded, 'preparando'),
                        _buildLista(preparando, Icons.check_circle_rounded, 'listo'),
                        _buildLista(listas, null, null),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          // 3 columnas en tablet/desktop
          return Row(
            children: [
              Expanded(child: _buildColumna('Recibido', recibidas, AppColors.warning, Icons.play_arrow_rounded, 'preparando')),
              Container(width: 1, color: AppColors.outline),
              Expanded(child: _buildColumna('Preparando', preparando, AppColors.info, Icons.check_circle_rounded, 'listo')),
              Container(width: 1, color: AppColors.outline),
              Expanded(child: _buildColumna('Listo', listas, AppColors.success, null, null)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColumna(String titulo, List<OrdenModel> ordenes, Color color, IconData? accionIcon, String? siguiente) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          color: color.withOpacity(0.08),
          child: Text(titulo, style: AppTypography.bodyBold.copyWith(color: color), textAlign: TextAlign.center),
        ),
        Expanded(
          child: ordenes.isEmpty
              ? Center(child: Text('Sin órdenes', style: AppTypography.caption))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  itemCount: ordenes.length,
                  itemBuilder: (_, i) => _buildTarjeta(ordenes[i], accionIcon, siguiente),
                ),
        ),
      ],
    );
  }

  Widget _buildLista(List<OrdenModel> ordenes, IconData? accionIcon, String? siguiente) {
    if (ordenes.isEmpty) return Center(child: Text('Sin órdenes', style: AppTypography.caption));
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.sm),
      itemCount: ordenes.length,
      itemBuilder: (_, i) => _buildTarjeta(ordenes[i], accionIcon, siguiente),
    );
  }

  Widget _buildTarjeta(OrdenModel orden, IconData? accionIcon, String? siguiente) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mesa ${orden.mesaId ?? '-'}', style: AppTypography.bodyBold),
                ChipEstado(estado: orden.estado),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Código: ${orden.codigoPedido ?? '-'}', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xs),
            ...orden.detalles.take(3).map((d) => Text('• x${d.cantidad} Platillo #${d.platilloId}', style: AppTypography.caption)),
            if (orden.detalles.length > 3) Text('… +${orden.detalles.length - 3} más', style: AppTypography.caption),
            const SizedBox(height: AppSpacing.xs),
            Text(_tiempoTranscurrido(orden.fecha), style: AppTypography.caption.copyWith(color: AppColors.onSurfaceVariant)),
            if (accionIcon != null && siguiente != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => _avanzarEstado(orden),
                  icon: Icon(accionIcon, size: 18),
                  label: Text(siguiente == 'preparando' ? 'Preparar' : 'Listo'),
                  style: FilledButton.styleFrom(
                    backgroundColor: siguiente == 'preparando' ? AppColors.info : AppColors.success,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
