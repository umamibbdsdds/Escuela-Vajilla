import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/platillo_model.dart';
import '../services/api_client.dart';

/// TarjetaPlatillo — versión para menú cliente con +/- y nota
class TarjetaPlatillo extends StatelessWidget {
  final PlatilloModel platillo;
  final int cantidad;
  final VoidCallback? onAgregar;
  final VoidCallback? onQuitar;
  final ValueChanged<String>? onNotaChanged;
  final VoidCallback? onTap;

  const TarjetaPlatillo({
    super.key,
    required this.platillo,
    this.cantidad = 0,
    this.onAgregar,
    this.onQuitar,
    this.onNotaChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final disponible = platillo.disponible;

    return Card(
      child: InkWell(
        onTap: disponible ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Opacity(
          opacity: disponible ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: (platillo.imagenUrl ?? '').isNotEmpty
                        ? Image.network(
                            ApiClient.imageUrl(platillo.imagenUrl!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImage(),
                          )
                        : _placeholderImage(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Nombre
                Text(
                  platillo.nombre,
                  style: AppTypography.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                // Categoría
                Text(platillo.categoria, style: AppTypography.label),
                if (!disponible) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text('AGOTADO', style: AppTypography.overline.copyWith(color: AppColors.error)),
                ],
                const Spacer(),
                // Precio
                Text('\$${platillo.precio.toStringAsFixed(2)}', style: AppTypography.subtitleWith(AppColors.primary)),
                const SizedBox(height: AppSpacing.xs),
                // +/-
                if (disponible)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.outlined(
                        onPressed: cantidad > 0 ? onQuitar : null,
                        icon: const Icon(Icons.remove_rounded, size: 18),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Container(
                        width: 40,
                        alignment: Alignment.center,
                        child: Text('$cantidad', style: AppTypography.bodyBold),
                      ),
                      IconButton.filled(
                        onPressed: onAgregar,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(36, 36),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _placeholderImage() => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: const Icon(Icons.fastfood_rounded, color: AppColors.primaryLight, size: 28),
  );
}
