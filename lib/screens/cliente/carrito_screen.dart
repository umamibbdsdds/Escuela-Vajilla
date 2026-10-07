import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/platillo_model.dart';
import '../../widgets/boton_primario.dart';
import '../../widgets/boton_secundario.dart';

class CarritoScreen extends StatefulWidget {
  final List<PlatilloModel> platillos;
  final Map<int, int> carrito;
  final Map<int, String> notas;
  final Future<void> Function(List<Map<String, dynamic>> detalles) onConfirmar;

  const CarritoScreen({
    super.key,
    required this.platillos,
    required this.carrito,
    required this.notas,
    required this.onConfirmar,
  });

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  bool _enviando = false;

  List<PlatilloModel> get _enCarrito => widget.platillos.where((p) => widget.carrito.containsKey(p.id)).toList();

  double get _total => _enCarrito.fold(0.0, (s, p) => s + p.precio * widget.carrito[p.id]!);

  List<Map<String, dynamic>> get _detalles => _enCarrito.map((p) => {
    'platillo_id': p.id,
    'cantidad': widget.carrito[p.id],
    'nota': widget.notas[p.id] ?? '',
  }).toList();

  Future<void> _confirmar() async {
    setState(() => _enviando = true);
    try {
      await widget.onConfirmar(_detalles);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu carrito')),
      body: Column(
        children: [
          Expanded(
            child: _enCarrito.isEmpty
                ? Center(child: Text('Carrito vacío', style: AppTypography.body))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _enCarrito.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final p = _enCarrito[i];
                      final cant = widget.carrito[p.id]!;
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.sm),
                                child: SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: Image.network(
                                    p.imagenUrl ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppColors.surfaceVariant,
                                      child: const Icon(Icons.restaurant_rounded, color: AppColors.onSurfaceVariant),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p.nombre, style: AppTypography.bodyBold),
                                    Text('\$${p.precio.toStringAsFixed(2)} c/u', style: AppTypography.caption),
                                    if (widget.notas[p.id]?.isNotEmpty == true)
                                      Text('Nota: ${widget.notas[p.id]}', style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(AppRadius.xl),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_rounded, size: 18),
                                      onPressed: () {
                                        setState(() {
                                          final c = cant - 1;
                                          if (c <= 0) widget.carrito.remove(p.id); else widget.carrito[p.id] = c;
                                        });
                                      },
                                    ),
                                    Text('$cant', style: AppTypography.bodyBold),
                                    IconButton(
                                      icon: const Icon(Icons.add_rounded, size: 18),
                                      onPressed: () => setState(() => widget.carrito[p.id] = cant + 1),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Total + Confirmar
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppTheme.light.colorScheme.surface,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTypography.bodyBold),
                      Text('\$${_total.toStringAsFixed(2)}', style: AppTypography.headlineWith(AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BotonPrimario(
                    texto: 'Confirmar pedido',
                    onPressed: _enCarrito.isEmpty || _enviando ? null : _confirmar,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
