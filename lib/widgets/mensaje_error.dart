import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Mensaje de error amable con botón "Reintentar"
class MensajeError extends StatelessWidget {
  final String mensaje;
  final VoidCallback onReintentar;

  const MensajeError({
    super.key,
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 56, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(mensaje, style: AppTypography.subtitle.copyWith(color: AppColors.error), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Reintentar', style: AppTypography.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
