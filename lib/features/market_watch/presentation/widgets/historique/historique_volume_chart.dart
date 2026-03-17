import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// Widget — Barre de volume (capitaux) quotidiens historiques
/// Design dark avec barres vertes/rouges selon variation TUNINDEX
class HistoriqueVolumeChart extends StatelessWidget {
  final List<HistoriqueSessionEntity> sessions;

  const HistoriqueVolumeChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox();

    // Prendre les 20 dernières séances max
    final data = sessions.length > 20 ? sessions.sublist(0, 20) : sessions;
    // Inverser pour afficher du plus ancien au plus récent
    final reversed = data.reversed.toList();
    final maxCap = reversed.map((e) => e.totalCapitaux).reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primaryBlue,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Volume Quotidien (Capitaux)',
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Bars
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: reversed.map((s) {
                final ratio = maxCap > 0 ? s.totalCapitaux / maxCap : 0.0;
                final isPositive = s.tunindexChange >= 0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Tooltip(
                      message: '${s.shortDate}\n${s.formattedCapitaux}',
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: (ratio * 90).clamp(4, 90).toDouble(),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? AppColors.bullGreen.withValues(alpha: 0.7)
                              : AppColors.bearRed.withValues(alpha: 0.7),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(3),
                            topRight: Radius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Date labels (first, middle, last)
          if (reversed.length >= 3)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  reversed.first.shortDate,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
                Text(
                  reversed[reversed.length ~/ 2].shortDate,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
                Text(
                  reversed.last.shortDate,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
