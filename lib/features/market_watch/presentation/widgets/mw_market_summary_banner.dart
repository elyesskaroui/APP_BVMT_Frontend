import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../home/domain/entities/market_summary_entity.dart';

/// Bannière résumé du marché — affiche les KPIs clés en un coup d'œil
/// Design glassmorphism léger avec dégradé bleu BVMT
class MwMarketSummaryBanner extends StatelessWidget {
  final MarketSummaryEntity summary;

  const MwMarketSummaryBanner({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D4FA8), Color(0xFF1B2A4A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Session info row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      summary.sessionDate,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _buildStatusChip(),
            ],
          ),
          const SizedBox(height: 14),

          // Hausse / Baisse mini-bar
          _buildHausseBaisseBar(),
          const SizedBox(height: 14),

          // KPI row
          Row(
            children: [
              _buildKpi(
                icon: Icons.monetization_on_outlined,
                label: 'Capitaux',
                value: _formatLargeNumber(summary.totalCapitaux),
                color: const Color(0xFFFFC107),
              ),
              _buildDivider(),
              _buildKpi(
                icon: Icons.swap_horiz_rounded,
                label: 'Transactions',
                value: _formatInt(summary.totalTransactions),
                color: const Color(0xFF64FFDA),
              ),
              _buildDivider(),
              _buildKpi(
                icon: Icons.pie_chart_outline_rounded,
                label: 'Cap. Boursière',
                value: _formatLargeNumber(summary.marketCap),
                color: const Color(0xFFBB86FC),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    final isOpen = summary.isSessionOpen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isOpen ? AppColors.bullGreen : AppColors.bearRed)
            .withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (isOpen ? AppColors.bullGreen : AppColors.bearRed)
              .withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.bullGreen : AppColors.bearRed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isOpen ? AppColors.bullGreen : AppColors.bearRed)
                      .withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Marché Ouvert' : 'Marché Fermé',
            style: AppTypography.labelSmall.copyWith(
              color: isOpen ? AppColors.bullGreen : AppColors.bearRed,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHausseBaisseBar() {
    final total = summary.nbHausses + summary.nbBaisses;
    final hausseFraction = total > 0 ? summary.nbHausses / total : 0.5;

    return Column(
      children: [
        Row(
          children: [
            Row(
              children: [
                const Icon(Icons.trending_up_rounded,
                    color: AppColors.bullGreen, size: 13),
                const SizedBox(width: 3),
                Text(
                  '${summary.nbHausses} Hausses',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.bullGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              '${summary.activeValues} / ${summary.totalValues} valeurs',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 9,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  '${summary.nbBaisses} Baisses',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.bearRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.trending_down_rounded,
                    color: AppColors.bearRed, size: 13),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 5,
            child: Row(
              children: [
                Flexible(
                  flex: (hausseFraction * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.bullGreen,
                          AppColors.bullGreen.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Flexible(
                  flex: ((1 - hausseFraction) * 100).round(),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.bearRed.withValues(alpha: 0.7),
                          AppColors.bearRed,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKpi({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  String _formatLargeNumber(double value) {
    if (value >= 1e9) return '${(value / 1e9).toStringAsFixed(1)} Md';
    if (value >= 1e6) return '${(value / 1e6).toStringAsFixed(1)} M';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(0)} K';
    return value.toStringAsFixed(0);
  }

  String _formatInt(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}
