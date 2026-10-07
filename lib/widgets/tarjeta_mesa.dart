import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/orden_model.dart';
import 'chip_estado.dart';

class TarjetaMesa extends StatelessWidget {
  final MesaModel mesa;
  final VoidCallback? onTap;
  final bool compacta;

  const TarjetaMesa({
    super.key,
    required this.mesa,
    this.onTap,
    this.compacta = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.estadoMesaColor(mesa.estado);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.table_restaurant_rounded,
                size: compacta ? 28 : 36, color: color),
              const SizedBox(height: AppSpacing.sm),
              Text('Mesa ${mesa.numero}', style: AppTypography.subtitleWith(color)),
              const SizedBox(height: AppSpacing.xs),
              ChipEstado(estado: mesa.estado, esMesa: true, fontSize: 10),
              if (mesa.meseroNombre != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(mesa.meseroNombre!, style: AppTypography.label, overflow: TextOverflow.ellipsis),
              ],
              if (mesa.pedidosActivos > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                Badge(
                  label: Text('${mesa.pedidosActivos}'),
                  backgroundColor: AppColors.warning,
                ),
              ],
              if (mesa.estado == 'lista' && onTap != null) ...[
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.delivery_dining_rounded, size: 16),
                  label: const Text('Entregar', style: TextStyle(fontSize: 11)),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    minimumSize: const Size(double.infinity, 36),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
