import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';

/// Widget réutilisable — Carte de prix d'action avec variation
class StockTickerCard extends StatelessWidget {
  final String symbol;
  final String price;
  final String changePercent;
  final bool isPositive;
  final VoidCallback? onTap;

  const StockTickerCard({
    super.key,
    required this.symbol,
    required this.price,
    required this.changePercent,
    required this.isPositive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMD,
          vertical: AppDimens.paddingSM,
        ),
        margin: const EdgeInsets.only(right: AppDimens.paddingSM),
        decoration: BoxDecoration(
          color: AppColors.cardBackgroundDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimens.radiusSM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symbol,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
              size: 20,
            ),
            Text(
              price,
              style: const TextStyle(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isPositive ? AppColors.bullGreen : AppColors.bearRed)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                changePercent,
                style: TextStyle(
                  color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
