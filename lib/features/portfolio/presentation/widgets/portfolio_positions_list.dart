import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../domain/entities/position_entity.dart';

/// Widget — Liste des positions du portefeuille
class PortfolioPositionsList extends StatelessWidget {
  final List<PositionEntity> positions;

  const PortfolioPositionsList({super.key, required this.positions});

  @override
  Widget build(BuildContext context) {
    if (positions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimens.paddingXL),
        child: Center(
          child: Text(
            'Aucune position',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: positions.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: AppColors.divider.withValues(alpha: 0.4),
        ),
        itemBuilder: (context, index) {
          return _PositionTile(position: positions[index]);
        },
      ),
    );
  }
}

class _PositionTile extends StatelessWidget {
  final PositionEntity position;
  const _PositionTile({required this.position});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingMD,
        vertical: AppDimens.paddingSM + 4,
      ),
      child: Row(
        children: [
          // ── Icône ──
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusSM),
            ),
            alignment: Alignment.center,
            child: Text(
              position.symbol.substring(
                  0, position.symbol.length >= 2 ? 2 : position.symbol.length),
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(width: AppDimens.paddingSM + 4),

          // ── Symbole + Quantité ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.symbol,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${position.quantity} actions • PRU: ${position.avgPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ── Valeur + P&L ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${position.totalValue.toStringAsFixed(2)} TND',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (position.isPositive ? AppColors.bullGreen : AppColors.bearRed)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  position.formattedGainLossPercent,
                  style: TextStyle(
                    color: position.isPositive ? AppColors.bullGreen : AppColors.bearRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
