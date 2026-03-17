import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// Widget — Courbe historique dual-axis TUNINDEX / TUNINDEX20
/// Design V3 premium :
///   - Fond navy gradient, grille subtile
///   - Courbe turquoise TUNINDEX (axe Y gauche)
///   - Courbe orange TUNINDEX20 (axe Y droite)
///   - Dates X-axis, légende en haut
///   - Sélecteur de période
class HistoriqueDualChart extends StatelessWidget {
  final List<HistoriqueChartPoint> chartData;
  final String selectedPeriod;
  final ValueChanged<String>? onPeriodChanged;

  const HistoriqueDualChart({
    super.key,
    required this.chartData,
    this.selectedPeriod = '6M',
    this.onPeriodChanged,
  });

  static const _periods = ['1M', '3M', '6M', '1A', 'Max'];

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return const SizedBox(height: 200, child: Center(child: Text('Aucune donnée')));
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2A4A), Color(0xFF0D3B6E), Color(0xFF1B2A4A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + legend
          _buildHeader(),
          // Chart
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: SizedBox(
              height: 220,
              child: _buildChart(),
            ),
          ),
          // Period selector
          _buildPeriodSelector(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Text(
            'Évolution des Indices',
            style: AppTypography.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          // Legend
          _legendDot(const Color(0xFF00D2FF), 'TUNINDEX'),
          const SizedBox(width: 12),
          _legendDot(AppColors.accentOrange, 'TUNINDEX20'),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final tunMin = chartData.map((e) => e.tunindex).reduce(math.min);
    final tunMax = chartData.map((e) => e.tunindex).reduce(math.max);
    final t20Min = chartData.map((e) => e.tunindex20).reduce(math.min);
    final t20Max = chartData.map((e) => e.tunindex20).reduce(math.max);

    // Padding pour les axes
    final tunRange = tunMax - tunMin;
    final t20Range = t20Max - t20Min;
    final tunBottom = tunMin - tunRange * 0.05;
    final tunTop = tunMax + tunRange * 0.05;
    final t20Bottom = t20Min - t20Range * 0.05;
    final t20Top = t20Max + t20Range * 0.05;

    // Normaliser TUNINDEX20 sur l'axe TUNINDEX
    double normalizeT20(double v) {
      if (t20Top == t20Bottom) return tunBottom;
      return tunBottom + (v - t20Bottom) / (t20Top - t20Bottom) * (tunTop - tunBottom);
    }

    // Spots
    final tunSpots = <FlSpot>[];
    final t20Spots = <FlSpot>[];
    for (var i = 0; i < chartData.length; i++) {
      tunSpots.add(FlSpot(i.toDouble(), chartData[i].tunindex));
      t20Spots.add(FlSpot(i.toDouble(), normalizeT20(chartData[i].tunindex20)));
    }

    final int xCount = chartData.length;
    final int labelInterval = (xCount / 5).ceil().clamp(1, 999);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (xCount - 1).toDouble(),
        minY: tunBottom,
        maxY: tunTop,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: tunRange / 4,
          getDrawingHorizontalLine: (v) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          // Left axis — TUNINDEX
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: tunRange / 4,
              getTitlesWidget: (v, meta) {
                if (v == meta.max || v == meta.min) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    v.toStringAsFixed(0),
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF00D2FF).withValues(alpha: 0.7),
                      fontSize: 8,
                    ),
                  ),
                );
              },
            ),
          ),
          // Right axis — TUNINDEX20
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: tunRange / 4,
              getTitlesWidget: (v, meta) {
                if (v == meta.max || v == meta.min) return const SizedBox();
                // Dé-normaliser pour afficher les vraies valeurs TUNINDEX20
                final real = t20Bottom +
                    (v - tunBottom) / (tunTop - tunBottom) * (t20Top - t20Bottom);
                return Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    real.toStringAsFixed(0),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accentOrange.withValues(alpha: 0.7),
                      fontSize: 8,
                    ),
                  ),
                );
              },
            ),
          ),
          // Bottom — Dates
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: labelInterval.toDouble(),
              getTitlesWidget: (v, meta) {
                final idx = v.toInt();
                if (idx < 0 || idx >= chartData.length) return const SizedBox();
                final d = chartData[idx].date;
                const months = [
                  '', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
                  'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
                ];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${d.day} ${months[d.month]}',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 8,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF1B2A4A).withValues(alpha: 0.95),
            tooltipRoundedRadius: 10,
            getTooltipItems: (spots) {
              return spots.map((s) {
                final idx = s.x.toInt().clamp(0, chartData.length - 1);
                final pt = chartData[idx];
                if (s.barIndex == 0) {
                  return LineTooltipItem(
                    'TUNINDEX\n${pt.tunindex.toStringAsFixed(2)}',
                    AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF00D2FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  );
                } else {
                  return LineTooltipItem(
                    'TUNINDEX20\n${pt.tunindex20.toStringAsFixed(2)}',
                    AppTypography.labelSmall.copyWith(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  );
                }
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          // TUNINDEX — turquoise
          LineChartBarData(
            spots: tunSpots,
            isCurved: true,
            curveSmoothness: 0.2,
            barWidth: 2,
            color: const Color(0xFF00D2FF),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF00D2FF).withValues(alpha: 0.15),
                  const Color(0xFF00D2FF).withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // TUNINDEX20 — orange
          LineChartBarData(
            spots: t20Spots,
            isCurved: true,
            curveSmoothness: 0.2,
            barWidth: 2,
            color: AppColors.accentOrange,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accentOrange.withValues(alpha: 0.1),
                  AppColors.accentOrange.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _periods.map((p) {
          final selected = p == selectedPeriod;
          return GestureDetector(
            onTap: () => onPeriodChanged?.call(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF00D2FF).withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF00D2FF).withValues(alpha: 0.5)
                      : Colors.transparent,
                ),
              ),
              child: Text(
                p,
                style: AppTypography.labelSmall.copyWith(
                  color: selected
                      ? const Color(0xFF00D2FF)
                      : Colors.white.withValues(alpha: 0.5),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
