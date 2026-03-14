import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_shadows.dart';
import '../../core/constants/app_typography.dart';

/// Widget réutilisable — Carte d'indice (TUNINDEX, TUNINDEX20)
/// ✅ Accessibilité : Semantics, daltonism icons, touch target ≥ 48dp
class IndexCard extends StatelessWidget {
  final String indexName;
  final String value;
  final String changePercent;
  final bool isPositive;
  final VoidCallback? onTap;

  const IndexCard({
    super.key,
    required this.indexName,
    required this.value,
    required this.changePercent,
    required this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$indexName: $value, variation $changePercent',
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.paddingMD),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppDimens.radiusMD),
            boxShadow: AppShadows.cardLight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(indexName, style: AppTypography.titleSmall),
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(value, style: AppTypography.indexValue),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      isPositive ? AppColors.bullGreen10 : AppColors.bearRed10,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSM),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color:
                          isPositive ? AppColors.bullGreen : AppColors.bearRed,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${isPositive ? '+' : ''}$changePercent',
                      style: AppTypography.changePercentSmall.copyWith(
                        color:
                            isPositive
                                ? AppColors.bullGreen
                                : AppColors.bearRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
