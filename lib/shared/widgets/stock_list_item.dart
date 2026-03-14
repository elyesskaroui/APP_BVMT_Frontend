import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';

/// Widget réutilisable — Ligne d'action dans la liste des favoris
/// ✅ Accessibilité : Semantics, daltonism icons, touch target ≥ 48dp
class StockListItem extends StatelessWidget {
  final String symbol;
  final String companyName;
  final String price;
  final String changePercent;
  final bool isPositive;
  final VoidCallback? onTap;

  const StockListItem({
    super.key,
    required this.symbol,
    required this.companyName,
    required this.price,
    required this.changePercent,
    required this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$symbol, $companyName, prix $price, variation $changePercent',
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        child: Container(
          // Ensure min touch height of 48dp
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingMD,
            vertical: AppDimens.paddingSM + 4,
          ),
          child: Row(
            children: [
              // ── Icône symbole ──
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue10,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSM),
                ),
                alignment: Alignment.center,
                child: Text(
                  symbol.substring(0, symbol.length >= 2 ? 2 : symbol.length),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(width: AppDimens.paddingSM + 4),

              // ── Symbole et nom ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(symbol, style: AppTypography.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      companyName,
                      style: AppTypography.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // ── Prix ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: AppTypography.titleSmall),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isPositive
                              ? AppColors.bullGreen10
                              : AppColors.bearRed10,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Daltonism: icon alongside color
                        Icon(
                          isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 12,
                          color:
                              isPositive
                                  ? AppColors.bullGreen
                                  : AppColors.bearRed,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${isPositive ? '+' : ''}$changePercent',
                          style: AppTypography.changePercentSmall.copyWith(
                            color:
                                isPositive
                                    ? AppColors.bullGreen
                                    : AppColors.bearRed,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
