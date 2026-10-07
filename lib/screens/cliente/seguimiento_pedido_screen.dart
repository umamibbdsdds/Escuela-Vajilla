import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/orden_model.dart';
import '../../models/platillo_model.dart';
import '../../services/polling_service.dart';
import '../../services/api_service.dart';
import '../../core/session.dart';
import '../../widgets/encabezado_seccion.dart';
import '../../widgets/chip_estado.dart';
import '../../widgets/boton_primario.dart';

class SeguimientoPedidoScreen extends StatefulWidget {
  final OrdenModel orden;
  final List<PlatilloModel> platillos;
  const SeguimientoPedidoScreen({super.key, required this.orden, required this.platillos});
  @override
  State<SeguimientoPedidoScreen> createState() => _SeguimientoPedidoScreenState();
}

class _SeguimientoPedidoScreenState extends State<SeguimientoPedidoScreen> {
  late OrdenModel _orden;
  bool _cargando = false;

  static const List<String> _estadosOrden = ['recibido', 'preparando', 'listo', 'entregado'];

  @override
  void initState() {
    super.initState();
    _orden = widget.orden;
    PollingService.start(5, (_) => _refrescar());
  }

  @override
  void dispose() {
    PollingService.stop();
    super.dispose();
  }

  Future<void> _refrescar() async {
    if (Session.instance.mesaId == null) return;
    try {
      final data = await ApiService.getClienteOrdenActiva(Session.instance.mesaId!);
      if (data != null && mounted) setState(() => _orden = OrdenModel.fromJson(data));
    } catch (_) {}
  }

  int get _pasoActual => _estadosOrden.indexOf(_orden.estado);

  void _pedirCuenta() async {
    setState(() => _cargando = true);
    try {
      await ApiService.clientePedirCuenta(Session.instance.mesaId!);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cuenta pedida')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esListo = _orden.estado == 'listo';
    final esEntregado = _orden.estado == 'entregado';

    return Scaffold(
      appBar: AppBar(title: const Text('Tu pedido')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Código de pedido
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Text('Código de pedido', style: AppTypography.caption),
                  const SizedBox(height: AppSpacing.xs),
                  Text(_orden.codigoPedido ?? '', style: AppTypography.headlineWith(AppColors.primary)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Timeline
          EncabezadoSeccion(titulo: 'Estado del pedido'),
          const SizedBox(height: AppSpacing.md),
          _Timeline(
            pasos: _estadosOrden,
            pasoActual: _pasoActual,
            labels: ['Recibido', 'Preparando', 'Listo', 'Entregado'],
            iconos: [Icons.receipt_long_rounded, Icons.soup_kitchen_rounded, Icons.done_all_rounded, Icons.delivery_dining_rounded],
          ),
          const SizedBox(height: AppSpacing.xl),
          // Código de entrega (cuando está listo)
          if (esListo && !esEntregado) ...[
            Card(
              color: AppColors.success.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 48, color: AppColors.success),
                    const SizedBox(height: AppSpacing.sm),
                    Text('¡Tu pedido está listo!', style: AppTypography.bodyBold),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Muestra este código al mesero:', style: AppTypography.caption),
                    const SizedBox(height: AppSpacing.xs),
                    Text(_orden.codigoEntrega ?? '', style: AppTypography.headlineWith(AppColors.success)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          // Detalles
          EncabezadoSeccion(titulo: 'Detalle'),
          const SizedBox(height: AppSpacing.sm),
          ..._orden.detalles.map((d) {
            final p = widget.platillos.where((pl) => pl.id == d.platilloId).firstOrNull;
            return ListTile(
              leading: Text('x${d.cantidad}', style: AppTypography.bodyBold),
              title: Text(p?.nombre ?? 'Platillo #${d.platilloId}', style: AppTypography.body),
              subtitle: d.nota.isNotEmpty ? Text(d.nota, style: AppTypography.caption) : null,
              trailing: Text('\$${(d.precio * d.cantidad).toStringAsFixed(2)}', style: AppTypography.body),
            );
          }),
          const Divider(),
          Align(
            alignment: Alignment.centerRight,
            child: Text('Total: \$${_orden.total.toStringAsFixed(2)}', style: AppTypography.bodyBold),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Acciones
          if (esEntregado)
            BotonPrimario(texto: 'Pedir cuenta', onPressed: _cargando ? null : _pedirCuenta),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final List<String> pasos;
  final int pasoActual;
  final List<String> labels;
  final List<IconData> iconos;

  const _Timeline({required this.pasos, required this.pasoActual, required this.labels, required this.iconos});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(pasos.length, (i) {
        final completado = i <= pasoActual;
        final activo = i == pasoActual;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completado ? AppColors.primary : AppColors.surfaceVariant,
                        border: activo ? Border.all(color: AppColors.primary, width: 3) : null,
                      ),
                      child: Icon(iconos[i], color: completado ? Colors.white : AppColors.onSurfaceVariant, size: 22),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(labels[i], style: activo ? AppTypography.bodyBold : AppTypography.caption, textAlign: TextAlign.center),
                  ],
                ),
              ),
              if (i < pasos.length - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    color: i < pasoActual ? AppColors.primary : AppColors.outline,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
