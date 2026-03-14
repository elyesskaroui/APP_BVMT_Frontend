import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/market_summary_entity.dart';

/// Slide 2 & 3 — Courbe intraday (TUNINDEX / TUNINDEX20)
/// Design premium dark : fond dégradé sombre, courbe lumineuse avec gradient,
/// tooltip élégant, statistiques inférieures avec séparateurs
class IndexChartSlide extends StatelessWidget {
  final IndexData index;
  final List<ChartPoint> intradayData;
  final Color lineColor;

  const IndexChartSlide({
    super.key,
    required this.index,
    required this.intradayData,
    this.lineColor = const Color(0xFF1A6BCC),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chart Card (dark theme like screenshots) ──
          Expanded(child: _buildDarkChartCard()),
          const SizedBox(height: 12),

          // ── Stats bottom row ──
          _buildBottomStats(),
        ],
      ),
    );
  }

  Widget _buildDarkChartCard() {
    final positive = index.changePercent >= 0;
    final changeColor = positive ? const Color(0xFF4ADE80) : const Color(0xFFFF6B6B);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B2A4A),
            Color(0xFF0F1923),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2A4A).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Subtle grid overlay
            Positioned.fill(
              child: CustomPaint(
                painter: _SubtleGridPainter(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──
                  Row(
                    children: [
                      // Index name badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: lineColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: lineColor.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          index.name,
                          style: TextStyle(
                            color: lineColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Value + change
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            index.formattedValue,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: changeColor.withValues(alpha: 0.15),
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
                                  color: changeColor,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  index.formattedChange,
                                  style: TextStyle(
                                    color: changeColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Chart area ──
                  Expanded(child: _buildChart(changeColor)),

                  // ── Time labels ──
                  const SizedBox(height: 8),
                  _buildTimeLabels(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(Color accentColor) {
    if (intradayData.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded,
                size: 32, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 8),
            Text(
              'Pas de données intraday',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final spots =
        intradayData.map((p) => FlSpot(p.time, p.value)).toList();
    final values = intradayData.map((p) => p.value).toList();
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);

    // Fixed Y-axis: round to nearest 50, with padding so edge labels aren't clipped
    final minY = (minVal / 50).floor() * 50.0 - 15;
    final maxY = (maxVal / 50).ceil() * 50.0 + 15;

    // Dashed reference line at opening value
    final openValue = intradayData.first.value;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.06),
            strokeWidth: 0.5,
          ),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: openValue,
              color: Colors.white.withValues(alpha: 0.2),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ],
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 50,
              reservedSize: 56,
              getTitlesWidget: (value, meta) {
                if (value % 50 != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value.toStringAsFixed(0),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF2A3A52),
            tooltipRoundedRadius: 10,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItems: (spots) => spots.map((spot) {
              final h = 9 + (spot.x ~/ 60);
              final m =
                  (spot.x % 60).toInt().toString().padLeft(2, '0');
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(2)}\n$h:$m',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lineColor.withValues(alpha: 0.25),
                  lineColor.withValues(alpha: 0.05),
                  lineColor.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildTimeLabels() {
    const times = ['09:00', '10:00', '11:00', '12:00', '13:00'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: times
          .map(
            (t) => Text(
              t,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomStats() {
    final positive = index.changePercent >= 0;
    final yearPositive = index.yearChangePercent >= 0;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _bottomStatCard(
            label: 'Valeur',
            value: index.formattedValue,
            valueColor: AppColors.deepNavy,
            accentColor: AppColors.primaryBlue,
            icon: Icons.show_chart_rounded,
          ),
          _bottomStatCard(
            label: 'Var. Jour',
            value: index.formattedChange,
            valueColor: positive ? AppColors.bullGreen : AppColors.bearRed,
            accentColor: positive ? AppColors.bullGreen : AppColors.bearRed,
            icon: positive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          ),
          _bottomStatCard(
            label: 'Var. Annuelle',
            value: index.formattedYearChange,
            valueColor: yearPositive ? AppColors.bullGreen : AppColors.bearRed,
            accentColor: yearPositive ? AppColors.bullGreen : AppColors.bearRed,
            icon: yearPositive ? Icons.north_east_rounded : Icons.south_east_rounded,
          ),
        ],
      ),
    );
  }

  Widget _bottomStatCard({
    required String label,
    required String value,
    required Color valueColor,
    required Color accentColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: accentColor.withValues(alpha: 0.06),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Label row with tiny icon ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    icon,
                    size: 10,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // ── Value ──
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 4),
            // ── Accent bar ──
            Container(
              width: 20,
              height: 2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.6),
                    accentColor.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtle grid overlay for the dark chart card
class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;

    // Horizontal lines
    const hCount = 6;
    for (int i = 1; i < hCount; i++) {
      final y = size.height * i / hCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
