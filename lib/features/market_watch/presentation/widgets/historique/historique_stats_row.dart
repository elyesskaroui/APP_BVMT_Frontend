import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// Widget — Stats globales résumé de la période historique
/// 4 KPI cards en haut du tab Historique
class HistoriqueStatsRow extends StatelessWidget {
  final List<HistoriqueSessionEntity> sessions;

  const HistoriqueStatsRow({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox();

    // Calculs sur la période
    final latest = sessions.first;
    final oldest = sessions.last;

    // Performance TUNINDEX sur la période
    final tunPerf = oldest.tunindexValue != 0
        ? ((latest.tunindexValue - oldest.tunindexValue) / oldest.tunindexValue * 100)
        : 0.0;

    // Moyenne des capitaux
    final avgCap = sessions.map((s) => s.totalCapitaux).reduce((a, b) => a + b) /
        sessions.length;

    // Total transactions
    final totalTrans = sessions.map((s) => s.totalTransactions).reduce((a, b) => a + b);

    // Jours en hausse
    final joursHausse = sessions.where((s) => s.tunindexChange > 0).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildKpi(
              'Performance',
              '${tunPerf >= 0 ? '+' : ''}${tunPerf.toStringAsFixed(1)}%',
              Icons.trending_up_rounded,
              tunPerf >= 0 ? AppColors.bullGreen : AppColors.bearRed,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildKpi(
              'Cap. Moy.',
              _formatCapitaux(avgCap),
              Icons.monetization_on_outlined,
              AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildKpi(
              'Transactions',
              _formatNumber(totalTrans),
              Icons.swap_horiz_rounded,
              AppColors.accentOrange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildKpi(
              'Jrs Hausse',
              '$joursHausse/${sessions.length}',
              Icons.thumb_up_alt_rounded,
              AppColors.bullGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpi(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCapitaux(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(1)} Mrd';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}K';
    return v.toStringAsFixed(0);
  }

  String _formatNumber(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }
}
