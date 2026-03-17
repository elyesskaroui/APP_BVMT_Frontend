import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// Widget — Carte résumé d'une séance historique
/// Design premium white-card avec badge hausse/baisse
class HistoriqueSessionCard extends StatelessWidget {
  final HistoriqueSessionEntity session;

  const HistoriqueSessionCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final isPositive = session.tunindexChange >= 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
        children: [
          // Date + badge variation
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primaryBlue,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                session.formattedDate,
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              _buildChangeBadge(session.tunindexChange, isPositive),
            ],
          ),
          const SizedBox(height: 12),

          // TUNINDEX / TUNINDEX20 row
          Row(
            children: [
              Expanded(
                child: _buildIndexTile(
                  'TUNINDEX',
                  session.tunindexValue,
                  session.tunindexChange,
                  const Color(0xFF00D2FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildIndexTile(
                  'TUNINDEX20',
                  session.tunindex20Value,
                  session.tunindex20Change,
                  AppColors.accentOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Stats row (Capitaux / Quantité / Transactions)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  Icons.monetization_on_outlined,
                  'Capitaux',
                  session.formattedCapitaux,
                ),
                _verticalDivider(),
                _buildStat(
                  Icons.bar_chart_rounded,
                  'Quantité',
                  _formatNumber(session.totalQuantite),
                ),
                _verticalDivider(),
                _buildStat(
                  Icons.swap_horiz_rounded,
                  'Trans.',
                  _formatNumber(session.totalTransactions),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Hausse / Baisse / Inchangées mini-bar
          _buildHausseBaisseBar(),
        ],
      ),
    );
  }

  Widget _buildChangeBadge(double change, bool isPositive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isPositive ? AppColors.bullGreen : AppColors.bearRed)
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
            style: AppTypography.labelSmall.copyWith(
              color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexTile(
      String name, double value, double change, Color accentColor) {
    final isPositive = change >= 0;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTypography.labelSmall.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toStringAsFixed(2),
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%',
            style: AppTypography.labelSmall.copyWith(
              color: isPositive ? AppColors.bullGreen : AppColors.bearRed,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 14),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.divider,
    );
  }

  Widget _buildHausseBaisseBar() {
    final total = session.nbHausses + session.nbBaisses + session.nbInchangees;
    if (total == 0) return const SizedBox();

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: SizedBox(
            height: 5,
            child: Row(
              children: [
                Expanded(
                  flex: session.nbHausses,
                  child: Container(color: AppColors.bullGreen),
                ),
                Expanded(
                  flex: session.nbInchangees,
                  child: Container(color: AppColors.divider),
                ),
                Expanded(
                  flex: session.nbBaisses,
                  child: Container(color: AppColors.bearRed),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '↑ ${session.nbHausses}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.bullGreen,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
            Text(
              '= ${session.nbInchangees}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 9,
              ),
            ),
            Text(
              '↓ ${session.nbBaisses}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.bearRed,
                fontWeight: FontWeight.w600,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }
}
