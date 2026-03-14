import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../home/domain/entities/market_summary_entity.dart';

/// Ligne individuelle d'un stock dans un tableau de classement
/// Avec médailles or/argent/bronze pour le Top 3, lignes alternées
/// Supporte onTap pour navigation vers la page détail du stock
class MwStockRow extends StatelessWidget {
  final TopStockEntry entry;
  final int rank;
  final String metricLabel;
  final VoidCallback? onTap;

  const MwStockRow({
    super.key,
    required this.entry,
    required this.rank,
    this.metricLabel = '',
    this.onTap,
  });

  // Medal colors for top 3
  static const _goldColor = Color(0xFFFFD700);
  static const _silverColor = Color(0xFFC0C0C0);
  static const _bronzeColor = Color(0xFFCD7F32);

  @override
  Widget build(BuildContext context) {
    final isPositive = entry.changePercent > 0;
    final isNegative = entry.changePercent < 0;
    final changeColor = isPositive
        ? AppColors.bullGreen
        : isNegative
            ? AppColors.bearRed
            : AppColors.textSecondary;

    final isEven = rank % 2 == 0;

    return Material(
      color: isEven ? const Color(0xFFFAFBFD) : Colors.white,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryBlue.withValues(alpha: 0.06),
        highlightColor: AppColors.primaryBlue.withValues(alpha: 0.03),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.divider.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Rank badge — medal for top 3, number for rest
              SizedBox(
                width: 24,
                child: rank <= 3 ? _buildMedalBadge() : _buildRankNumber(),
              ),
              const SizedBox(width: 4),
              // Symbol
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.symbol,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: rank <= 3 ? FontWeight.w800 : FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                      ),
                    ],
                  ],
                ),
              ),
              // Last price
              Expanded(
                flex: 2,
                child: Text(
                  entry.formattedPrice,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTypography.stockPrice.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Variation %
              Expanded(
                flex: 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: changeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_drop_up
                              : isNegative
                                  ? Icons.arrow_drop_down
                                  : Icons.remove,
                          color: changeColor,
                          size: 14,
                        ),
                        Text(
                          entry.formattedChange,
                          style: AppTypography.labelSmall.copyWith(
                            color: changeColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Metric value
              Expanded(
                flex: 2,
                child: Text(
                  entry.formattedMetric,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedalBadge() {
    final Color medalColor;
    final String emoji;
    switch (rank) {
      case 1:
        medalColor = _goldColor;
        emoji = '🥇';
        break;
      case 2:
        medalColor = _silverColor;
        emoji = '🥈';
        break;
      default:
        medalColor = _bronzeColor;
        emoji = '🥉';
    }

    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: medalColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildRankNumber() {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$rank',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
