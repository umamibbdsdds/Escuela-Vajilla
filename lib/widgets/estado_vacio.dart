import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final String? submensaje;

  const EstadoVacio({
    super.key,
    this.icono = Icons.inbox_rounded,
    required this.mensaje,
    this.submensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 64, color: AppColors.neutral),
            const SizedBox(height: AppSpacing.lg),
            Text(mensaje, style: AppTypography.subtitle.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
            if (submensaje != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(submensaje!, style: AppTypography.caption, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
