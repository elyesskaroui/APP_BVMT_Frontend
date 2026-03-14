import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_shadows.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/market_summary_entity.dart';

/// Type du classement affiché dans le tableau
enum TopStockType {
  capitaux('Capitaux', 'CAPITAUX', Icons.account_balance_wallet_rounded),
  quantite('Quantité', 'QUANTITÉ TRAITÉE', Icons.inventory_2_rounded),
  transactions('Transactions', 'NB. TRANSACTIONS', Icons.swap_horiz_rounded),
  hausses('Hausses', 'CAPITAUX', Icons.trending_up_rounded),
  baisses('Baisses', 'CAPITAUX', Icons.trending_down_rounded);

  final String title;
  final String metricLabel;
  final IconData icon;
  const TopStockType(this.title, this.metricLabel, this.icon);
}

/// Slide 4–8 — Top 5 tableau premium
/// Design : en-tête coloré, lignes alternées, médailles de rang,
/// badges de variation avec icônes directionnelles
class TopStocksTableSlide extends StatelessWidget {
  final TopStockType type;
  final List<TopStockEntry> entries;

  const TopStocksTableSlide({
    super.key,
    required this.type,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header with accent ──
          _buildSectionHeader(),
          const SizedBox(height: 10),

          // ── Table card ──
          Expanded(child: _buildTableCard()),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    final accentColor = _typeAccentColor;
    return Row(
      children: [
        // Icon with gradient background
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor,
                accentColor.withValues(alpha: 0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(type.icon, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top ${type.title}',
              style: AppTypography.titleSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Top 5 valeurs',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Small accent badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.15),
            ),
          ),
          child: Text(
            _isVariationType ? 'Variation' : type.title,
            style: TextStyle(
              color: accentColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadows.cardLight,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // ── Table header ──
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.scaffoldBackground,
                    AppColors.scaffoldBackground.withValues(alpha: 0.5),
                  ],
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 28),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'VALEUR',
                      style: _headerTextStyle,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Dernier',
                      textAlign: TextAlign.center,
                      style: _headerTextStyle,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Variation',
                      textAlign: TextAlign.center,
                      style: _headerTextStyle,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      type.metricLabel,
                      textAlign: TextAlign.right,
                      style: _headerTextStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Accent line under header
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _typeAccentColor,
                    _typeAccentColor.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // ── Data rows ──
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_rounded,
                              size: 32,
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.3)),
                          const SizedBox(height: 8),
                          Text(
                            'Aucune donnée',
                            style: TextStyle(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: entries.length,
                      itemBuilder: (_, i) => _buildRow(i, entries[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(int rank, TopStockEntry entry) {
    final changeColor = entry.isPositive
        ? AppColors.bullGreen
        : entry.isNegative
            ? AppColors.bearRed
            : AppColors.textSecondary;
    final isEven = rank % 2 == 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : AppColors.scaffoldBackground.withValues(alpha: 0.4),
        border: Border(
          bottom: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // Rank medal/badge
          _buildRankBadge(rank),
          const SizedBox(width: 6),

          // Symbol + mini change
          Expanded(
            flex: 3,
            child: Text(
              entry.symbol,
              style: AppTypography.titleSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Last price
          Expanded(
            flex: 2,
            child: Text(
              entry.formattedPrice,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          // Variation badge with arrow icon
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entry.isPositive
                          ? Icons.arrow_drop_up_rounded
                          : entry.isNegative
                              ? Icons.arrow_drop_down_rounded
                              : Icons.remove_rounded,
                      size: 14,
                      color: changeColor,
                    ),
                    Text(
                      entry.formattedChange,
                      style: TextStyle(
                        color: changeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Metric value
          Expanded(
            flex: 2,
            child: Text(
              _isVariationType
                  ? entry.formattedChange
                  : entry.formattedMetric,
              textAlign: TextAlign.right,
              style: TextStyle(
                color:
                    _isVariationType ? changeColor : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    // Gold, silver, bronze for top 3
    if (rank < 3) {
      final colors = [
        [const Color(0xFFFFD700), const Color(0xFFFFA000)], // Gold
        [const Color(0xFFC0C0C0), const Color(0xFF9E9E9E)], // Silver
        [const Color(0xFFCD7F32), const Color(0xFFA0522D)], // Bronze
      ];
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors[rank],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors[rank][0].withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${rank + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    // Regular rank for 4, 5
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.4),
        ),
      ),
      child: Center(
        child: Text(
          '${rank + 1}',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ── Helpers ──
  TextStyle get _headerTextStyle => AppTypography.labelSmall.copyWith(
        color: AppColors.textSecondary,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      );

  bool get _isVariationType =>
      type == TopStockType.hausses || type == TopStockType.baisses;

  Color get _typeAccentColor {
    switch (type) {
      case TopStockType.capitaux:
        return AppColors.accentOrange;
      case TopStockType.quantite:
        return const Color(0xFF8B5CF6);
      case TopStockType.transactions:
        return AppColors.primaryBlue;
      case TopStockType.hausses:
        return AppColors.bullGreen;
      case TopStockType.baisses:
        return AppColors.bearRed;
    }
  }
}
