import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IndicadorCarga extends StatelessWidget {
  final String? mensaje;
  const IndicadorCarga({super.key, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (mensaje != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(mensaje!, style: AppTypography.caption),
          ],
        ],
      ),
    );
  }
}

/// Shimmer genérico para listas
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  const ShimmerList({super.key, this.itemCount = 5, this.itemHeight = 72});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
        child: _shimmerLine(itemHeight),
      ),
    );
  }

  static Widget _shimmerLine(double h) {
    return Container(
      height: h,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}
