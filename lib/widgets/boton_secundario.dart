import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BotonSecundario extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final Color? color;

  const BotonSecundario({
    super.key,
    required this.texto,
    this.onPressed,
    this.icono,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? AppColors.primary,
          side: BorderSide(color: color ?? AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icono != null) ...[
              Icon(icono, size: 20),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(texto, style: AppTypography.button.copyWith(color: color ?? AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
