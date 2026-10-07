import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'chip_estado.dart';

class TarjetaPedido extends StatelessWidget {
  final Map<String, dynamic> orden;
  final VoidCallback? onTap;
  final Widget? trailing;

  const TarjetaPedido({
    super.key,
    required this.orden,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final id = orden['id'];
    final estado = orden['estado'] ?? 'recibido';
    final total = double.tryParse(orden['total']?.toString() ?? '0') ?? 0.0;
    final codigo = orden['codigo_pedido'] ?? '';
    final mesaNumero = orden['mesa_numero'];
    final createdAt = orden['created_at'];

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Pedido #$id${codigo.isNotEmpty ? ' · $codigo' : ''}',
                      style: AppTypography.subtitle,
                    ),
                  ),
                  ChipEstado(estado: estado),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (mesaNumero != null) ...[
                    Icon(Icons.table_restaurant_rounded, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Mesa $mesaNumero', style: AppTypography.caption),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  if (createdAt != null) ...[
                    Icon(Icons.schedule_rounded, size: 14, color: AppColors.textHint),
                    const SizedBox(width: AppSpacing.xs),
                    Text(_formatTime(createdAt.toString()), style: AppTypography.label),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total: \$${total.toStringAsFixed(2)}', style: AppTypography.bodyBold),
                  if (trailing != null) trailing!,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
