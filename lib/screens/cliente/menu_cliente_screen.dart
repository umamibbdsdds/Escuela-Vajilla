import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../core/session.dart';
import '../../services/api_service.dart';
import '../../services/polling_service.dart';
import '../../models/platillo_model.dart';
import '../../models/orden_model.dart';
import '../../widgets/encabezado_seccion.dart';
import '../../widgets/tarjeta_platillo.dart';
import '../../widgets/indicador_carga.dart';
import '../../widgets/mensaje_error.dart';
import '../../widgets/estado_vacio.dart';
import '../../widgets/boton_primario.dart';
import '../../widgets/boton_secundario.dart';
import 'carrito_screen.dart';
import 'seguimiento_pedido_screen.dart';

/// ============================================================
///  MenuClienteScreen — Menú del cliente por categorías + carrito
/// ============================================================
class MenuClienteScreen extends StatefulWidget {
  const MenuClienteScreen({super.key});
  @override
  State<MenuClienteScreen> createState() => _MenuClienteScreenState();
}

class _MenuClienteScreenState extends State<MenuClienteScreen> {
  List<PlatilloModel> _platillos = [];
  List<String> _categorias = [];
  String _categoriaSeleccionada = 'Todas';
  Map<int, int> _carrito = {}; // platilloId -> cantidad
  Map<int, String> _notas = {}; // platilloId -> nota
  bool _cargando = true;
  String? _error;
  OrdenModel? _ordenActiva;

  @override
  void initState() {
    super.initState();
    _cargar();
    _verificarOrdenActiva();
    PollingService.start(5, (_) => _verificarOrdenActiva());
  }

  @override
  void dispose() {
    PollingService.stop();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _error = null; });
    try {
      final platillosData = await ApiService.getPlatillos();
      final catsData = await ApiService.getCategorias();
      final models = (platillosData as List).map((p) => PlatilloModel.fromJson(p)).where((p) => p.disponible).toList();
      _categorias = ['Todas', ...List<String>.from(catsData)];
      if (mounted) setState(() { _platillos = models; _cargando = false; });
    } catch (e) {
      if (mounted) setState(() { _cargando = false; _error = e.toString(); });
    }
  }

  Future<void> _verificarOrdenActiva() async {
    if (Session.instance.mesaId == null) return;
    try {
      final data = await ApiService.getClienteOrdenActiva(Session.instance.mesaId!);
      if (data != null && mounted) {
        setState(() => _ordenActiva = OrdenModel.fromJson(data));
      }
    } catch (_) {}
  }

  List<PlatilloModel> get _filtrados => _categoriaSeleccionada == 'Todas'
      ? _platillos
      : _platillos.where((p) => p.categoria == _categoriaSeleccionada).toList();

  int get _totalItems => _carrito.values.fold(0, (a, b) => a + b);

  double get _totalPrecio {
    double t = 0;
    _carrito.forEach((id, cant) {
      final p = _platillos.firstWhere((pl) => pl.id == id);
      t += p.precio * cant;
    });
    return t;
  }

  void _agregar(PlatilloModel p) {
    setState(() { _carrito[p.id] = (_carrito[p.id] ?? 0) + 1; });
  }

  void _quitar(PlatilloModel p) {
    setState(() {
      final c = (_carrito[p.id] ?? 0) - 1;
      if (c <= 0) _carrito.remove(p.id); else _carrito[p.id] = c;
    });
  }

  void _abrirCarrito() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => CarritoScreen(
        platillos: _platillos,
        carrito: _carrito,
        notas: _notas,
        onConfirmar: _enviarOrden,
      ),
    )).then((ok) { if (ok == true) setState(() { _carrito.clear(); _notas.clear(); }); });
  }

  Future<void> _enviarOrden(List<Map<String, dynamic>> detalles) async {
    try {
      await ApiService.postClienteOrden({
        'mesa_id': Session.instance.mesaId,
        'detalles': detalles,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Orden enviada!')));
        _verificarOrdenActiva();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _verSeguimiento() {
    if (_ordenActiva == null) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SeguimientoPedidoScreen(orden: _ordenActiva!, platillos: _platillos),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) return const IndicadorCarga(mensaje: 'Cargando menú...');
    if (_error != null) return MensajeError(mensaje: _error!, onReintentar: _cargar);

    return Scaffold(
      appBar: AppBar(
        title: const Text('UMAMI'),
        actions: [
          if (_ordenActiva != null)
            IconButton(
              icon: const Icon(Icons.track_changes_rounded),
              tooltip: 'Seguir pedido',
              onPressed: _verSeguimiento,
            ),
          IconButton(
            icon: const Icon(Icons.restaurant_rounded),
            tooltip: 'Llamar mesero',
            onPressed: () async {
              try { await ApiService.clienteLlamarMesero(Session.instance.mesaId!); } catch (_) {}
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mesero notificado')));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categorías
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _categorias.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
              itemBuilder: (_, i) {
                final cat = _categorias[i];
                final sel = cat == _categoriaSeleccionada;
                return FilterChip(
                  selected: sel,
                  label: Text(cat),
                  onSelected: (_) => setState(() => _categoriaSeleccionada = cat),
                  selectedColor: AppColors.primary.withOpacity(0.15),
                  checkmarkColor: AppColors.primary,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Grid platillos
          Expanded(
            child: _filtrados.isEmpty
                ? const EstadoVacio(icono: Icons.restaurant_menu_rounded, mensaje: 'Sin platillos en esta categoría')
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: _filtrados.length,
                    itemBuilder: (_, i) {
                      final p = _filtrados[i];
                      final cant = _carrito[p.id] ?? 0;
                      return TarjetaPlatillo(
                        platillo: p,
                        cantidad: cant,
                        onAgregar: () => _agregar(p),
                        onQuitar: cant > 0 ? () => _quitar(p) : null,
                        onNotaChanged: (nota) => _notas[p.id] = nota,
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _totalItems > 0
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppTheme.light.colorScheme.surface,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$_totalItems artículo${_totalItems > 1 ? "s" : ""}', style: AppTypography.bodyBold),
                          Text('\$${_totalPrecio.toStringAsFixed(2)}', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    BotonPrimario(texto: 'Ver carrito', onPressed: _abrirCarrito),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
