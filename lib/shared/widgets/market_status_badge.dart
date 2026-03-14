import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';

/// Widget réutilisable — Indicateur de statut du marché (ouvert/fermé)
/// ✅ Accessibilité : Semantics, daltonism icon support
class MarketStatusBadge extends StatelessWidget {
  final bool isOpen;

  const MarketStatusBadge({super.key, required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final statusColor = isOpen ? AppColors.bullGreen : AppColors.bearRed;
    return Semantics(
      label: isOpen ? 'Marché ouvert' : 'Marché fermé',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOpen ? AppColors.bullGreen10 : AppColors.bearRed10,
          borderRadius: BorderRadius.circular(AppDimens.radiusRound),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Daltonism: icon + color for redundant visual cue
            Icon(
              isOpen ? Icons.check_circle : Icons.cancel,
              size: 12,
              color: statusColor,
            ),
            const SizedBox(width: 6),
            Text(
              isOpen ? 'Marché Ouvert' : 'Marché Fermé',
              style: AppTypography.labelMedium.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
