import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../home/domain/entities/market_summary_entity.dart';

/// Card graphique intraday pour un indice (TUNINDEX / TUNINDEX20)
/// Design dark premium identique à la page d'accueil :
///   - Fond navy gradient, grille subtile
///   - Courbe turquoise avec gradient, dashed reference line
///   - Y-axis labels, time labels
///   - Sélecteur de période (1J / 1S / 1M / 3M / 1A / Max)
///   - 4 stat cards en bas (Ouverture, +Haut, +Bas, Var. An.)
///   - Séance + MAJ timestamp en bas
///   - Badge Live pulsant
class MwIndexChartCard extends StatefulWidget {
  final IndexData indexData;
  final List<ChartPoint> intradayData;
  final String sessionDate;
  final bool isOpen;
  final String selectedPeriod;
  final ValueChanged<String>? onPeriodChanged;

  const MwIndexChartCard({
    super.key,
    required this.indexData,
    required this.intradayData,
    required this.sessionDate,
    required this.isOpen,
    this.selectedPeriod = '1J',
    this.onPeriodChanged,
  });

  @override
  State<MwIndexChartCard> createState() => _MwIndexChartCardState();
}

class _MwIndexChartCardState extends State<MwIndexChartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  static const _periods = ['1J', '1S', '1M', '3M', '1A', 'Max'];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    if (widget.isOpen) _pulseCtrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant MwIndexChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isOpen && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════
  // Colors matching home page
  // ═══════════════════════════════════════════
  static const _darkBg1 = Color(0xFF1B2A4A);
  static const _darkBg2 = Color(0xFF0F1923);
  static const _lineColorDefault = Color(0xFF1A6BCC);

  @override
  Widget build(BuildContext context) {
    final positive = widget.indexData.changePercent >= 0;
    final changeColor =
        positive ? const Color(0xFF4ADE80) : const Color(0xFFFF6B6B);
    final lineColor =
        positive ? const Color(0xFF4ADE80) : const Color(0xFFFF6B6B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Dark Chart Card ──
        _buildDarkChartCard(lineColor, changeColor, positive),
        const SizedBox(height: 10),

        // ── 4 Bottom Stat Cards ──
        _buildBottomStats(lineColor),

        // ── Session date + MAJ ──
        const SizedBox(height: 8),
        _buildFooter(),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ── DARK CHART CARD  ──
  // ═══════════════════════════════════════════
  Widget _buildDarkChartCard(
      Color lineColor, Color changeColor, bool positive) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_darkBg1, _darkBg2],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _darkBg1.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            // Subtle grid overlay
            Positioned.fill(child: CustomPaint(painter: _SubtleGridPainter())),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header row ──
                  _buildHeader(changeColor, positive),
                  const SizedBox(height: 8),

                  // ── Market status ──
                  _buildMarketStatus(),
                  const SizedBox(height: 10),

                  // ── Period selector ──
                  _buildPeriodSelector(lineColor),
                  const SizedBox(height: 12),

                  // ── Chart area ──
                  SizedBox(
                    height: 160,
                    child: widget.intradayData.isEmpty
                        ? _buildNoData()
                        : _buildChart(lineColor),
                  ),

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

  // ═══════════════════════════════════════════
  // ── HEADER  ──
  // ═══════════════════════════════════════════
  Widget _buildHeader(Color changeColor, bool positive) {
    return Row(
      children: [
        // Index name badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _lineColorDefault.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _lineColorDefault.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Text(
            widget.indexData.name,
            style: const TextStyle(
              color: _lineColorDefault,
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
              widget.indexData.formattedValue,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
                    size: 13,
                    color: changeColor,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    widget.indexData.formattedChange,
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
    );
  }

  // ═══════════════════════════════════════════
  // ── MARKET STATUS LINE ──
  // ═══════════════════════════════════════════
  Widget _buildMarketStatus() {
    final statusColor = widget.isOpen
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF59E0B);
    final statusText = widget.isOpen
        ? 'Marché ouvert'
        : 'Marché fermé • Ouvre demain à 09:00';

    return Row(
      children: [
        // Pulsating dot for live
        widget.isOpen
            ? AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) => Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: _pulseAnim.value),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(
                            alpha: _pulseAnim.value * 0.5),
                        blurRadius: 6 * _pulseAnim.value,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ── PERIOD SELECTOR ──
  // ═══════════════════════════════════════════
  Widget _buildPeriodSelector(Color lineColor) {
    return Row(
      children: _periods.map((p) {
        final selected = p == widget.selectedPeriod;
        return Expanded(
          child: GestureDetector(
            onTap: () => widget.onPeriodChanged?.call(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? _lineColorDefault.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: selected
                    ? Border.all(
                        color: _lineColorDefault.withValues(alpha: 0.4),
                        width: 1,
                      )
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 0.5,
                      ),
              ),
              child: Center(
                child: Text(
                  p,
                  style: TextStyle(
                    color: selected
                        ? _lineColorDefault
                        : Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ═══════════════════════════════════════════
  // ── CHART ──
  // ═══════════════════════════════════════════
  Widget _buildChart(Color lineColor) {
    final spots =
        widget.intradayData.map((p) => FlSpot(p.time, p.value)).toList();
    final values = widget.intradayData.map((p) => p.value).toList();
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);

    // Fixed Y-axis: round to nearest 50, with padding
    final minY = (minVal / 50).floor() * 50.0 - 15;
    final maxY = (maxVal / 50).ceil() * 50.0 + 15;

    // Dashed reference line at opening value
    final openValue = widget.intradayData.first.value;

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
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 4, bottom: 2),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                labelResolver: (_) => 'Ouv',
              ),
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
              reservedSize: 52,
              getTitlesWidget: (value, meta) {
                if (value % 50 != 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    value.toStringAsFixed(0),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 10,
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
            getTooltipItems: (touchedSpots) =>
                touchedSpots.map((spot) {
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
          getTouchedSpotIndicator: (barData, spotIndexes) =>
              spotIndexes.map((i) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: lineColor.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF2A3A52),
                  strokeWidth: 2,
                  strokeColor: lineColor,
                ),
              ),
            );
          }).toList(),
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

  Widget _buildNoData() {
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

  // ═══════════════════════════════════════════
  // ── TIME LABELS ──
  // ═══════════════════════════════════════════
  Widget _buildTimeLabels() {
    final labels = _timeLabelsForPeriod();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: labels
            .map((t) => Text(
                  t,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ))
            .toList(),
      ),
    );
  }

  List<String> _timeLabelsForPeriod() {
    switch (widget.selectedPeriod) {
      case '1S':
        return ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'];
      case '1M':
        return ['S1', 'S2', 'S3', 'S4'];
      case '3M':
        return ['M1', 'M2', 'M3'];
      case '1A':
        return ['Jan', 'Avr', 'Jul', 'Oct'];
      case 'Max':
        return ['2020', '2022', '2024', '2026'];
      default:
        return ['09:00', '10:00', '11:00', '12:00', '13:00'];
    }
  }

  // ═══════════════════════════════════════════
  // ── BOTTOM STATS  ──
  // ═══════════════════════════════════════════
  Widget _buildBottomStats(Color lineColor) {
    final open = _findOpen();
    final high = _findHigh();
    final low = _findLow();
    final yearPositive = widget.indexData.yearChangePercent >= 0;

    return Row(
      children: [
        _bottomStatCard(
          label: 'Ouverture',
          value: open,
          valueColor: AppColors.deepNavy,
          accentColor: AppColors.primaryBlue,
          icon: Icons.circle_outlined,
        ),
        _bottomStatCard(
          label: '+ Haut',
          value: high,
          valueColor: AppColors.bullGreen,
          accentColor: AppColors.bullGreen,
          icon: Icons.arrow_upward_rounded,
        ),
        _bottomStatCard(
          label: '+ Bas',
          value: low,
          valueColor: AppColors.bearRed,
          accentColor: AppColors.bearRed,
          icon: Icons.arrow_downward_rounded,
        ),
        _bottomStatCard(
          label: 'Var. An.',
          value: widget.indexData.formattedYearChange,
          valueColor:
              yearPositive ? AppColors.bullGreen : AppColors.bearRed,
          accentColor:
              yearPositive ? AppColors.bullGreen : AppColors.bearRed,
          icon: yearPositive
              ? Icons.north_east_rounded
              : Icons.south_east_rounded,
        ),
      ],
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
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: accentColor.withValues(alpha: 0.06),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.12),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon + label
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
                  child: Icon(icon, size: 10, color: accentColor),
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            // Value
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Accent bar
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

  // ═══════════════════════════════════════════
  // ── FOOTER (séance + MAJ)  ──
  // ═══════════════════════════════════════════
  Widget _buildFooter() {
    return Center(
      child: Text(
        '© Séance du ${widget.sessionDate}',
        style: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.5),
          fontSize: 9,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── HELPERS ──
  // ═══════════════════════════════════════════
  String _findOpen() {
    if (widget.intradayData.isEmpty) return '—';
    return _formatNumber(widget.intradayData.first.value);
  }

  String _findHigh() {
    if (widget.intradayData.isEmpty) return '—';
    return _formatNumber(widget.intradayData
        .map((p) => p.value)
        .reduce((a, b) => a > b ? a : b));
  }

  String _findLow() {
    if (widget.intradayData.isEmpty) return '—';
    return _formatNumber(widget.intradayData
        .map((p) => p.value)
        .reduce((a, b) => a < b ? a : b));
  }

  String _formatNumber(double v) {
    // Format with space as thousands separator like 6 600,00
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(intPart[i]);
    }
    return '$buffer,$decPart';
  }
}

/// Subtle grid overlay for the dark chart card
class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;

    const hCount = 6;
    for (int i = 1; i < hCount; i++) {
      final y = size.height * i / hCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
