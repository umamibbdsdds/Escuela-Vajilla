import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TarjetaResumen extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final VoidCallback? onTap;

  const TarjetaResumen({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    this.color = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(icono, color: color, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(valor, style: AppTypography.headline.copyWith(color: color)),
              const SizedBox(height: AppSpacing.xs),
              Text(titulo, style: AppTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}
