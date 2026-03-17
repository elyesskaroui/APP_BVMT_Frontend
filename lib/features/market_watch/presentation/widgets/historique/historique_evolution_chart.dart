import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// ULTIMATE Evolution Chart — Gradient area fill under curves, premium period selector,
/// animated toggle, dual Y-axis, refined tooltips, smooth entry
class HistoriqueEvolutionChart extends StatelessWidget {
  final List<HistoriqueChartPoint> chartData;
  final String selectedPeriod;
  final bool showTunindex20;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onToggleTunindex20;

  const HistoriqueEvolutionChart({
    super.key,
    required this.chartData,
    required this.selectedPeriod,
    required this.showTunindex20,
    required this.onPeriodChanged,
    required this.onToggleTunindex20,
  });

  static const _tunColor = AppColors.primaryBlue;
  static const _t20Color = Color(0xFFE8912D);
  static const _periods = ['1M', '3M', '6M', '1A', '2A'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.show_chart_rounded,
                        size: 16, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 10),
                  Text('Évolution', style: AppTypography.titleLarge),
                  const Spacer(),
                  _PremiumToggle(
                    isActive: showTunindex20,
                    onTap: onToggleTunindex20,
                  ),
                ],
              ),
            ),

            // ── Legend ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
              child: Row(
                children: [
                  _LegendChip(color: _tunColor, label: 'TUNINDEX'),
                  if (showTunindex20) ...[
                    const SizedBox(width: 12),
                    _LegendChip(color: _t20Color, label: 'TUNINDEX20', isDashed: true),
                  ],
                ],
              ),
            ),

            // ── Chart ──
            SizedBox(
              height: 230,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: chartData.length >= 2
                    ? _buildChart()
                    : Center(
                        child: Text('Données insuffisantes',
                            style: AppTypography.labelMedium),
                      ),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, delay: 200.ms)
                .slideY(begin: 0.02, end: 0, duration: 600.ms, delay: 200.ms),

            // ── Period selector pills ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: _periods.map((p) {
                    final isSelected = p == selectedPeriod;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onPeriodChanged(p);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryBlue
                                          .withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p,
                            style: AppTypography.labelLarge.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final tunValues = chartData.map((p) => p.tunindex).toList();
    final tunMin = tunValues.reduce(math.min);
    final tunMax = tunValues.reduce(math.max);
    final tunRange = tunMax - tunMin;

    final tun20Values = chartData.map((p) => p.tunindex20).toList();
    final tun20Min = tun20Values.reduce(math.min);
    final tun20Max = tun20Values.reduce(math.max);
    final tun20Range = tun20Max - tun20Min;

    List<FlSpot> tunSpots = [];
    List<FlSpot> tun20Spots = [];

    for (var i = 0; i < chartData.length; i++) {
      final x = i.toDouble();
      tunSpots.add(FlSpot(x, chartData[i].tunindex));
      if (showTunindex20 && tun20Range > 0) {
        final normalized = tunMin +
            ((chartData[i].tunindex20 - tun20Min) / tun20Range) * tunRange;
        tun20Spots.add(FlSpot(x, normalized));
      }
    }

    final yPad = tunRange * 0.08;

    return LineChart(
      LineChartData(
        minY: tunMin - yPad,
        maxY: tunMax + yPad,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: tunRange / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.divider30,
            strokeWidth: 0.5,
            dashArray: [4, 4],
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: showTunindex20,
              reservedSize: 52,
              interval: tunRange > 0 ? tunRange / 4 : null,
              getTitlesWidget: (value, meta) {
                if (tunRange == 0) return const SizedBox.shrink();
                final tun20Val =
                    tun20Min + ((value - tunMin) / tunRange) * tun20Range;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    tun20Val.toStringAsFixed(0),
                    style: AppTypography.labelSmall.copyWith(
                      color: _t20Color,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: tunRange / 4,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toStringAsFixed(0),
                    style: AppTypography.labelSmall.copyWith(
                      color: _tunColor.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: _getXInterval(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= chartData.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _formatMonth(chartData[idx].date),
                    style: AppTypography.labelSmall.copyWith(fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.deepNavy,
            tooltipRoundedRadius: 12,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final isT20 = spot.barIndex == 1;
                final date = chartData[spot.x.toInt()].date;
                final dateStr = DateFormat('dd MMM yy', 'fr_FR').format(date);
                double displayVal;
                if (isT20 && tunRange > 0) {
                  displayVal = tun20Min +
                      ((spot.y - tunMin) / tunRange) * tun20Range;
                } else {
                  displayVal = spot.y;
                }
                return LineTooltipItem(
                  '${isT20 ? 'TUNINDEX20' : 'TUNINDEX'}\n',
                  AppTypography.labelSmall.copyWith(
                    color: isT20 ? _t20Color : AppColors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '${displayVal.toStringAsFixed(1)}\n',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: dateStr,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (barData, indices) {
            return indices.map((idx) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  strokeWidth: 1,
                  dashArray: [3, 3],
                ),
                FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, bar, idx) =>
                      FlDotCirclePainter(
                    radius: 4,
                    color: bar.color ?? AppColors.primaryBlue,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
              );
            }).toList();
          },
        ),
        lineBarsData: [
          // TUNINDEX — gradient fill
          LineChartBarData(
            spots: tunSpots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: _tunColor,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _tunColor.withValues(alpha: 0.15),
                  _tunColor.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
          // TUNINDEX20 — dashed, lighter fill
          if (showTunindex20)
            LineChartBarData(
              spots: tun20Spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: _t20Color,
              barWidth: 2.0,
              dotData: const FlDotData(show: false),
              dashArray: [6, 3],
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _t20Color.withValues(alpha: 0.08),
                    _t20Color.withValues(alpha: 0.01),
                  ],
                ),
              ),
            ),
        ],
      ),
      duration: const Duration(milliseconds: 400),
    );
  }

  double _getXInterval() {
    final len = chartData.length;
    if (len <= 30) return (len / 5).ceilToDouble();
    if (len <= 90) return (len / 6).ceilToDouble();
    if (len <= 180) return (len / 6).ceilToDouble();
    return (len / 8).ceilToDouble();
  }

  String _formatMonth(DateTime d) {
    const months = [
      '', 'jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.',
    ];
    return '${months[d.month]} ${d.year % 100}';
  }
}

class _PremiumToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _PremiumToggle({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFE8912D).withValues(alpha: 0.1)
              : AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? const Color(0xFFE8912D).withValues(alpha: 0.35)
                : AppColors.divider30,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFFE8912D).withValues(alpha: 0.1),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFE8912D)
                    : AppColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'T20',
              style: AppTypography.labelSmall.copyWith(
                color: isActive
                    ? const Color(0xFFE8912D)
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;

  const _LegendChip({
    required this.color,
    required this.label,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDashed)
          SizedBox(
            width: 14,
            height: 3,
            child: CustomPaint(
              painter: _DashedLinePainter(color: color),
            ),
          )
        else
          Container(
            width: 14,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + 3, size.width), size.height / 2),
        paint,
      );
      x += 5;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
