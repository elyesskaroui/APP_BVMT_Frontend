import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/market_summary_entity.dart';

/// Slide 1 — Résumé global du marché
/// Design premium : statut marché animé, indicateur horaire 9h-13h,
/// grille de stats avec icônes, tendance proportionnelle
class GlobalSummarySlide extends StatelessWidget {
  final MarketSummaryEntity summary;

  const GlobalSummarySlide({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Market Status & Session Info ──
          _buildMarketStatusCard(),
          const SizedBox(height: 14),

          // ── Indices side-by-side ──
          Row(
            children: [
              Expanded(child: _buildIndexCard(summary.tunindex, true)),
              const SizedBox(width: 10),
              Expanded(child: _buildIndexCard(summary.tunindex20, false)),
            ],
          ),
          const SizedBox(height: 14),

          // ── Stats grid 2×2 ──
          _buildStatsGrid(),
          const SizedBox(height: 14),

          // ── Tendance du marché ──
          _buildTrendSection(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // ── MARKET STATUS CARD ──
  // ═══════════════════════════════════════════════
  Widget _buildMarketStatusCard() {
    final now = DateTime.now();
    final marketOpen = DateTime(now.year, now.month, now.day, 9, 0);
    final marketClose = DateTime(now.year, now.month, now.day, 13, 0);
    final totalMinutes = marketClose.difference(marketOpen).inMinutes;
    final elapsedMinutes = now.difference(marketOpen).inMinutes;
    final progress = (elapsedMinutes / totalMinutes).clamp(0.0, 1.0);
    final isWithinHours = now.isAfter(marketOpen) && now.isBefore(marketClose);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: summary.isSessionOpen
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D4FA8), Color(0xFF1A6BCC)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2A3A52), Color(0xFF1B2A4A)],
              ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (summary.isSessionOpen
                    ? AppColors.primaryBlue
                    : AppColors.deepNavy)
                .withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: date + session status
          Row(
            children: [
              Icon(Icons.event_rounded,
                  size: 14, color: Colors.white.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
              Text(
                'Séance du ${summary.sessionDate}',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _statusBadge(
                summary.isSessionOpen ? 'Ouverte' : 'Fermée',
                summary.isSessionOpen
                    ? AppColors.bullGreen
                    : const Color(0xFFFF6B6B),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Bloc market status
          Row(
            children: [
              const SizedBox(width: 20),
              _statusBadge(
                summary.isBlocMarketOpen
                    ? 'Marché de blocs ouvert'
                    : 'Marché de blocs fermé',
                summary.isBlocMarketOpen
                    ? AppColors.bullGreen.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.3),
                small: true,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Market Hours Progress ──
          Row(
            children: [
              Text(
                '09:00',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: summary.isSessionOpen
                          ? progress
                          : (isWithinHours ? progress : 1.0),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: summary.isSessionOpen
                                ? [
                                    const Color(0xFF4ADE80),
                                    const Color(0xFF22C55E),
                                  ]
                                : [
                                    Colors.white.withValues(alpha: 0.3),
                                    Colors.white.withValues(alpha: 0.5),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: summary.isSessionOpen
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF4ADE80)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                    if (summary.isSessionOpen && isWithinHours)
                      Positioned.fill(
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '13:00',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (summary.isSessionOpen && isWithinHours) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(
                '${(progress * 100).toStringAsFixed(0)}% de la séance écoulée',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String text, Color color, {bool small = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 6 : 8,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 4 : 6,
            height: small ? 4 : 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: small ? 4 : 5),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: small ? 9 : 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // ── INDEX CARD ──
  // ═══════════════════════════════════════════════
  Widget _buildIndexCard(IndexData idx, bool isPrimary) {
    final positive = idx.changePercent >= 0;
    final color = positive ? AppColors.bullGreen : AppColors.bearRed;
    final bgColor = isPrimary ? AppColors.primaryBlue : AppColors.accentOrange;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.cardLight,
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: bgColor.withValues(alpha: 0.15)),
            ),
            child: Text(
              idx.name,
              style: TextStyle(
                color: bgColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            idx.formattedValue,
            style: AppTypography.indexValue.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      positive
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 12,
                      color: color,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      idx.formattedChange,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'Ann. ',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
              Icon(
                idx.yearChangePercent >= 0
                    ? Icons.north_east_rounded
                    : Icons.south_east_rounded,
                size: 10,
                color: idx.yearChangePercent >= 0
                    ? AppColors.bullGreen
                    : AppColors.bearRed,
              ),
              const SizedBox(width: 2),
              Text(
                idx.formattedYearChange,
                style: TextStyle(
                  color: idx.yearChangePercent >= 0
                      ? AppColors.bullGreen
                      : AppColors.bearRed,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  // ── STATS GRID ──
  // ═══════════════════════════════════════════════
  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.pie_chart_rounded,
                iconBgColor: const Color(0xFF3B82F6),
                label: 'Capitalisation',
                value: _compact(summary.marketCap),
                unit: 'TND',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.account_balance_wallet_rounded,
                iconBgColor: AppColors.accentOrange,
                label: 'Capitaux',
                value: _compact(summary.totalCapitaux),
                unit: 'TND',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.inventory_2_rounded,
                iconBgColor: const Color(0xFF8B5CF6),
                label: 'Quantité',
                value: _formatInt(summary.totalQuantity),
                unit: 'titres',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.swap_horiz_rounded,
                iconBgColor: const Color(0xFF06B6D4),
                label: 'Transactions',
                value: _formatInt(summary.totalTransactions),
                unit: '',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  // ── TREND SECTION ──
  // ═══════════════════════════════════════════════
  Widget _buildTrendSection() {
    final total = summary.nbHausses + summary.nbBaisses;
    final hPct = total > 0 ? summary.nbHausses / total : 0.5;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.cardLight,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.insights_rounded,
                    size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text('Tendance du marché', style: AppTypography.titleSmall),
            ],
          ),
          const SizedBox(height: 14),

          // Hausse / Baisse counts
          Row(
            children: [
              Expanded(
                child: _trendPill(
                  Icons.trending_up_rounded,
                  AppColors.bullGreen,
                  '${summary.nbHausses}',
                  'Hausses',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _trendPill(
                  Icons.trending_down_rounded,
                  AppColors.bearRed,
                  '${summary.nbBaisses}',
                  'Baisses',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Proportional bar
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Flexible(
                    flex: (hPct * 100).round().clamp(1, 99),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF4ADE80)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Flexible(
                    flex: ((1 - hPct) * 100).round().clamp(1, 99),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Active values
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart_rounded,
                    size: 14,
                    color: AppColors.textSecondary.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  '${summary.activeValues} / ${summary.totalValues} valeurs actives',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendPill(
      IconData icon, Color color, String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Helpers ──
  String _compact(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(2)} Md';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(2)} M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(1)} K';
    return v.toStringAsFixed(0);
  }

  String _formatInt(int v) {
    return v.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
  }
}

// ═══════════════════════════════════════════════
// ── STAT TILE ──
// ═══════════════════════════════════════════════
class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String label;
  final String value;
  final String unit;

  const _StatTile({
    required this.icon,
    required this.iconBgColor,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.cardLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBgColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconBgColor, size: 15),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: AppTypography.stockPrice.copyWith(fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 9,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
