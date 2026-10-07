import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChipEstado extends StatelessWidget {
  final String estado;
  final bool esMesa;
  final double? fontSize;

  const ChipEstado({
    super.key,
    required this.estado,
    this.esMesa = false,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final color = esMesa ? AppTheme.estadoMesaColor(estado) : AppTheme.estadoOrdenColor(estado);
    final label = esMesa ? AppTheme.estadoMesaLabel(estado) : AppTheme.estadoOrdenLabel(estado);
    final icon = esMesa ? AppTheme.estadoMesaIcon(estado) : AppTheme.estadoOrdenIcon(estado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
