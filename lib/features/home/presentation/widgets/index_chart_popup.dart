import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/cubits/market_status_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/market_summary_entity.dart';
import '../bloc/index_chart_bloc.dart';
import '../bloc/index_chart_event.dart';
import '../bloc/index_chart_state.dart';

// ═══════════════════════════════════════════════════════════════════
//  Premium Index Chart Popup — UI/UX 10/10
// ═══════════════════════════════════════════════════════════════════
// • Glassmorphism card with radial glow highlights
// • Animated chart draw (clipRect left-to-right reveal)
// • Live market status indicator with pulsing dot
// • Interactive crosshair with floating tooltip (value + diff from open)
// • Min/Max markers on chart
// • 4-stat grid (Ouverture, + Haut, + Bas, Var. Année)
// • Period selector pills (1J active, others prepared)
// • Elegant X close button (top-right)
// • Smooth entry animation (scale + fade + slide)
// • Soft glow behind chart line (CustomPainter)
// • Footer with session date + last update time
// ═══════════════════════════════════════════════════════════════════

class IndexChartPopup extends StatefulWidget {
  final IndexData index;

  const IndexChartPopup({super.key, required this.index});

  /// Show the popup — creates a local IndexChartBloc, dispatches event,
  /// and displays the dialog with BlocProvider.
  static Future<void> show(BuildContext context, IndexData index) {
    HapticFeedback.mediumImpact();
    final bloc = sl<IndexChartBloc>()..add(IndexChartRequested(index));

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close ${index.name} chart',
      barrierColor: Colors.black.withValues(alpha: 0.65),
      transitionDuration: const Duration(milliseconds: 420),
      transitionBuilder: (ctx, anim, secondAnim, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeIn,
        );
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
              child: child,
            ),
          ),
        );
      },
      pageBuilder: (ctx, anim, secondAnim) {
        return BlocProvider<IndexChartBloc>.value(
          value: bloc,
          child: IndexChartPopup(index: index),
        );
      },
    ).whenComplete(() => bloc.close());
  }

  @override
  State<IndexChartPopup> createState() => _IndexChartPopupState();
}

class _IndexChartPopupState extends State<IndexChartPopup>
    with TickerProviderStateMixin {
  // ── Animation controllers ──
  late final AnimationController _chartRevealController;
  late final AnimationController _pulseController;
  late final AnimationController _travelController;
  late final Animation<double> _chartReveal;
  late final Animation<double> _pulse;

  // ── Period selector ──
  int _selectedPeriod = 0;
  static const _periods = ['1J', '1S', '1M', '3M', '1A', 'Max'];

  @override
  void initState() {
    super.initState();

    // Chart line-draw reveal animation
    _chartRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _chartReveal = CurvedAnimation(
      parent: _chartRevealController,
      curve: Curves.easeInOutCubic,
    );

    // Pulsing dot for live indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Traveling light that glides along the chart line
    _travelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // If BLoC already emitted data (from cache) before listener was attached,
    // start the reveal animation on the next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = context.read<IndexChartBloc>().state;
      if (state is IndexChartLoaded) {
        _chartRevealController.forward(from: 0);
      }
    });
  }

  @override
  void dispose() {
    _chartRevealController.dispose();
    _pulseController.dispose();
    _travelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IndexChartBloc, IndexChartState>(
      listener: (context, state) {
        if (state is IndexChartLoaded) {
          _chartRevealController.forward(from: 0);
        }
      },
      builder: (context, chartState) {
        final index = widget.index;
        final positive = index.changePercent >= 0;
        final changeColor =
            positive ? const Color(0xFF34D399) : const Color(0xFFFF6B6B);
        const lineColor = Color(0xFF3B82F6);

        final List<ChartPoint> chartData;
        final bool isLoading;
        final String? errorMessage;

        if (chartState is IndexChartLoaded) {
          chartData = chartState.chartData;
          isLoading = false;
          errorMessage = null;
        } else if (chartState is IndexChartError) {
          chartData = [];
          isLoading = false;
          errorMessage = chartState.message;
        } else {
          chartData = [];
          isLoading = true;
          errorMessage = null;
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF182A48),
                          Color(0xFF0E1B2E),
                          Color(0xFF0A1422),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0A1422).withValues(alpha: 0.8),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
                        ),
                        BoxShadow(
                          color: lineColor.withValues(alpha: 0.08),
                          blurRadius: 60,
                          spreadRadius: -10,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // ── Subtle top-left radial glow ──
                        Positioned(
                          top: -30,
                          left: -30,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  lineColor.withValues(alpha: 0.06),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        // ── Main content column ──
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ── Header ──
                            _buildHeader(index, positive, changeColor),

                            // ── Live status bar ──
                            _buildLiveStatusBar(),

                            const SizedBox(height: 4),

                            // ── Period selector ──
                            _buildPeriodSelector(),

                            const SizedBox(height: 12),

                            // ── Chart area ──
                            SizedBox(
                              height: 200,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8, 0, 16, 0),
                                child: isLoading
                                    ? _buildChartLoading()
                                    : errorMessage != null
                                        ? _buildChartError(errorMessage)
                                        : _buildChart(
                                            chartData, lineColor, changeColor),
                              ),
                            ),

                            // ── Time axis ──
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: _buildTimeAxis(),
                            ),

                            const SizedBox(height: 16),

                            // ── Stats grid ──
                            _buildStatsGrid(
                                index, chartData, positive, changeColor),

                            const SizedBox(height: 12),

                            // ── Footer ──
                            _buildFooter(),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  HEADER — Index badge + large value + change chip + X button
  // ════════════════════════════════════════════════════════════════
  Widget _buildHeader(IndexData index, bool positive, Color changeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: Badge + large value + change ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Index name badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    index.name,
                    style: const TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Large value
                Text(
                  index.formattedValue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),

                // Change chip (rounded pill)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        positive
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        size: 14,
                        color: changeColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        index.formattedChange,
                        style: TextStyle(
                          color: changeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Close button (circle X) ──
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  LIVE STATUS BAR — pulsing dot + "Séance en cours" / "Marché fermé"
  // ════════════════════════════════════════════════════════════════
  Widget _buildLiveStatusBar() {
    return BlocBuilder<MarketStatusCubit, MarketStatusState>(
      builder: (context, marketState) {
        final isOpen = marketState.isOpen;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Pulsing dot
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOpen
                          ? Color.lerp(
                              const Color(0xFF34D399).withValues(alpha: 0.4),
                              const Color(0xFF34D399),
                              _pulse.value,
                            )
                          : const Color(0xFFFF6B6B).withValues(alpha: 0.5),
                      boxShadow: isOpen
                          ? [
                              BoxShadow(
                                color: const Color(0xFF34D399)
                                    .withValues(alpha: 0.3 * _pulse.value),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                isOpen ? 'Séance en cours' : 'Marché fermé',
                style: TextStyle(
                  color: isOpen
                      ? const Color(0xFF34D399).withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '• ${marketState.statusText}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.25),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  PERIOD SELECTOR — pills: 1J | 1S | 1M | 3M | 1A | Max
  // ════════════════════════════════════════════════════════════════
  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: List.generate(_periods.length, (i) {
            final selected = i == _selectedPeriod;
            final enabled = i == 0; // Only "1J" is active for now
            return Expanded(
              child: GestureDetector(
                onTap: enabled
                    ? () => setState(() => _selectedPeriod = i)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: selected
                        ? Border.all(
                            color: const Color(0xFF3B82F6)
                                .withValues(alpha: 0.3),
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _periods[i],
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF60A5FA)
                            : enabled
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.15),
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  CHART — glow line, gradient fill, min/max dots, crosshair tooltip
  // ════════════════════════════════════════════════════════════════
  Widget _buildChart(
      List<ChartPoint> data, Color lineColor, Color accentColor) {
    if (data.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.show_chart_rounded,
                size: 40, color: Colors.white.withValues(alpha: 0.12)),
            const SizedBox(height: 10),
            Text(
              'Pas de données intraday',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    final spots = data.map((p) => FlSpot(p.time, p.value)).toList();
    final values = data.map((p) => p.value).toList();
    final minVal = values.reduce(math.min);
    final maxVal = values.reduce(math.max);
    final openValue = data.first.value;

    // Fixed Y-axis: round to nearest 50, with extra padding so edge labels aren't clipped
    final minY = (minVal / 50).floor() * 50.0 - 15;
    final maxY = (maxVal / 50).ceil() * 50.0 + 15;

    // Find min/max indices for marker dots
    final minIdx = values.indexOf(minVal);
    final maxIdx = values.indexOf(maxVal);

    return AnimatedBuilder(
      animation: _chartReveal,
      builder: (context, child) {
        return ClipRect(
          clipper: _ChartRevealClipper(_chartReveal.value),
          child: child,
        );
      },
      child: Stack(
        children: [
          // ── Glow layer behind chart ──
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GlowPainter(
                  spots: spots,
                  minY: minY,
                  maxY: maxY,
                  color: lineColor,
                ),
              ),
            ),
          ),

          // ── Traveling light shimmer on line ──
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _travelController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _TravelingLightPainter(
                      spots: spots,
                      minY: minY,
                      maxY: maxY,
                      color: lineColor,
                      progress: _travelController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Main fl_chart ──
          LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 50,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.white.withValues(alpha: 0.04),
                  strokeWidth: 0.5,
                ),
              ),
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  // Opening reference dashed line
                  HorizontalLine(
                    y: openValue,
                    color: Colors.white.withValues(alpha: 0.12),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.25),
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                      labelResolver: (_) => 'Ouv.',
                    ),
                  ),
                ],
              ),
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 50,
                    reservedSize: 56,
                    getTitlesWidget: (value, meta) {
                      // Only show labels at exact multiples of 50
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
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((i) {
                    return TouchedSpotIndicatorData(
                      // Vertical crosshair line
                      FlLine(
                        color: Colors.white.withValues(alpha: 0.15),
                        strokeWidth: 1,
                        dashArray: [3, 3],
                      ),
                      // Active dot on line
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 5,
                            color: lineColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) =>
                      const Color(0xFF1E3A5F).withValues(alpha: 0.95),
                  tooltipRoundedRadius: 12,
                  tooltipPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  tooltipBorder: BorderSide(
                    color: lineColor.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipItems: (touchedSpots) =>
                      touchedSpots.map((spot) {
                    final h = 9 + (spot.x ~/ 60);
                    final m =
                        (spot.x % 60).toInt().toString().padLeft(2, '0');
                    final diff = spot.y - openValue;
                    final diffSign = diff >= 0 ? '+' : '';
                    final diffColor = diff >= 0
                        ? const Color(0xFF34D399)
                        : const Color(0xFFFF6B6B);
                    return LineTooltipItem(
                      spot.y.toStringAsFixed(2),
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '  $diffSign${diff.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: diffColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '\n$h:$m',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.22,
                  preventCurveOverShooting: true,
                  color: lineColor,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  shadow: Shadow(
                    color: lineColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, barData) {
                      // Show dots only at min and max points
                      final idx = barData.spots.indexOf(spot);
                      return idx == minIdx || idx == maxIdx;
                    },
                    getDotPainter: (spot, percent, bar, index) {
                      final isMax = index == maxIdx;
                      return FlDotCirclePainter(
                        radius: 3.5,
                        color: isMax
                            ? const Color(0xFF34D399)
                            : const Color(0xFFFF6B6B),
                        strokeWidth: 1.5,
                        strokeColor: Colors.white.withValues(alpha: 0.8),
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        lineColor.withValues(alpha: 0.25),
                        lineColor.withValues(alpha: 0.08),
                        lineColor.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  TIME AXIS — 09:00 → 13:00
  // ════════════════════════════════════════════════════════════════
  Widget _buildTimeAxis() {
    const times = ['09:00', '10:00', '11:00', '12:00', '13:00'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: times
          .map(
            (t) => Text(
              t,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.25),
                fontSize: 9,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          )
          .toList(),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  STATS GRID — 4 metrics in elegant mini-cards with icons
  // ════════════════════════════════════════════════════════════════
  Widget _buildStatsGrid(IndexData index, List<ChartPoint> chartData,
      bool positive, Color changeColor) {
    final values = chartData.map((p) => p.value).toList();
    final openVal =
        chartData.isNotEmpty ? chartData.first.value : index.value;
    final highVal =
        values.isNotEmpty ? values.reduce(math.max) : index.value;
    final lowVal =
        values.isNotEmpty ? values.reduce(math.min) : index.value;

    final yearPositive = index.yearChangePercent >= 0;
    final yearColor =
        yearPositive ? const Color(0xFF34D399) : const Color(0xFFFF6B6B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.circle_outlined,
            iconColor: const Color(0xFF60A5FA),
            label: 'Ouverture',
            value: _formatVal(openVal),
            valueColor: Colors.white,
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            icon: Icons.arrow_upward_rounded,
            iconColor: const Color(0xFF34D399),
            label: '+ Haut',
            value: _formatVal(highVal),
            valueColor: const Color(0xFF34D399),
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            icon: Icons.arrow_downward_rounded,
            iconColor: const Color(0xFFFF6B6B),
            label: '+ Bas',
            value: _formatVal(lowVal),
            valueColor: const Color(0xFFFF6B6B),
          ),
          const SizedBox(width: 8),
          _buildStatCard(
            icon: Icons.calendar_today_rounded,
            iconColor: yearColor,
            label: 'Var. An.',
            value: index.formattedYearChange,
            valueColor: yearColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 14, color: iconColor.withValues(alpha: 0.7)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  FOOTER — session date + last update time
  // ════════════════════════════════════════════════════════════════
  Widget _buildFooter() {
    final now = DateTime.now();
    final sessionDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final updateTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time_rounded,
              size: 11, color: Colors.white.withValues(alpha: 0.20)),
          const SizedBox(width: 4),
          Text(
            'Séance du $sessionDate • MAJ $updateTime',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.20),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  LOADING STATE
  // ════════════════════════════════════════════════════════════════
  Widget _buildChartLoading() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Chargement…',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  ERROR STATE
  // ════════════════════════════════════════════════════════════════
  Widget _buildChartError(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 22,
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Utility: format a value as e.g. "15 049,43" ──
  String _formatVal(double v) {
    final parts = v.toStringAsFixed(2).split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$intPart,${parts[1]}';
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Custom Painters & Clippers
// ═══════════════════════════════════════════════════════════════════

/// Clips the chart from left to right for the reveal animation
class _ChartRevealClipper extends CustomClipper<Rect> {
  final double revealFraction;
  _ChartRevealClipper(this.revealFraction);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * revealFraction, size.height);
  }

  @override
  bool shouldReclip(covariant _ChartRevealClipper oldClipper) {
    return oldClipper.revealFraction != revealFraction;
  }
}

/// Premium comet animation — glides along the chart line with trail & sparkles
class _TravelingLightPainter extends CustomPainter {
  final List<FlSpot> spots;
  final double minY;
  final double maxY;
  final Color color;
  final double progress; // 0.0 → 1.0

  _TravelingLightPainter({
    required this.spots,
    required this.minY,
    required this.maxY,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (spots.length < 2) return;

    final xMin = spots.first.x;
    final xMax = spots.last.x;
    final xRange = xMax - xMin;
    if (xRange == 0) return;
    final yRange = maxY - minY;
    if (yRange == 0) return;

    // Build path
    final path = Path();
    for (var i = 0; i < spots.length; i++) {
      final x = (spots[i].x - xMin) / xRange * size.width;
      final y = size.height - ((spots[i].y - minY) / yRange * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;
    final totalLen = metric.length;

    final tangent = metric.getTangentForOffset(totalLen * progress);
    if (tangent == null) return;
    final point = tangent.position;

    // Pulse factor for breathing effect
    final pulse = 0.85 + 0.15 * math.sin(progress * math.pi * 12);

    // ── 1) Long gradient trail (20% of path) ──
    final trailLen = totalLen * 0.20;
    final trailStart = (totalLen * progress - trailLen).clamp(0.0, totalLen);
    final trailEnd = (totalLen * progress).clamp(0.0, totalLen);
    if (trailEnd > trailStart) {
      final trailPath = metric.extractPath(trailStart, trailEnd);
      // Wide soft trail
      canvas.drawPath(
        trailPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            point,
            Offset(
              point.dx - tangent.vector.dx * trailLen * 0.3,
              point.dy - tangent.vector.dy * trailLen * 0.3,
            ),
            [
              color.withValues(alpha: 0.3 * pulse),
              color.withValues(alpha: 0.0),
            ],
          )
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Thin bright core trail
      canvas.drawPath(
        trailPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            point,
            Offset(
              point.dx - tangent.vector.dx * trailLen * 0.3,
              point.dy - tangent.vector.dy * trailLen * 0.3,
            ),
            [
              Colors.white.withValues(alpha: 0.6 * pulse),
              color.withValues(alpha: 0.0),
            ],
          ),
      );
    }

    // ── 2) Large outer halo with radial gradient ──
    canvas.drawCircle(
      point,
      32 * pulse,
      Paint()
        ..shader = ui.Gradient.radial(
          point,
          32 * pulse,
          [
            color.withValues(alpha: 0.2 * pulse),
            color.withValues(alpha: 0.05),
            color.withValues(alpha: 0.0),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    // ── 3) Medium glow ring ──
    canvas.drawCircle(
      point,
      14 * pulse,
      Paint()
        ..shader = ui.Gradient.radial(
          point,
          14 * pulse,
          [
            color.withValues(alpha: 0.5 * pulse),
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.0),
          ],
          [0.0, 0.5, 1.0],
        ),
    );

    // ── 4) White hot center ──
    canvas.drawCircle(
      point,
      4.5 * pulse,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.95)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(
      point,
      2.5,
      Paint()..color = Colors.white,
    );

    // ── 5) Sparkle particles around the dot ──
    final rng = math.Random((progress * 10000).toInt());
    for (int i = 0; i < 5; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final dist = 8.0 + rng.nextDouble() * 16;
      final sparkleAlpha = (0.3 + rng.nextDouble() * 0.4) * pulse;
      final sparkleSize = 1.0 + rng.nextDouble() * 1.5;
      final sp = Offset(
        point.dx + math.cos(angle) * dist,
        point.dy + math.sin(angle) * dist,
      );
      canvas.drawCircle(
        sp,
        sparkleSize,
        Paint()
          ..color = Colors.white.withValues(alpha: sparkleAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TravelingLightPainter old) {
    return old.progress != progress;
  }
}

/// Paints a soft glow behind the chart line
class _GlowPainter extends CustomPainter {
  final List<FlSpot> spots;
  final double minY;
  final double maxY;
  final Color color;

  _GlowPainter({
    required this.spots,
    required this.minY,
    required this.maxY,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (spots.length < 2) return;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final path = Path();
    final xMin = spots.first.x;
    final xMax = spots.last.x;
    final xRange = xMax - xMin;
    if (xRange == 0) return;
    final yRange = maxY - minY;
    if (yRange == 0) return;

    for (var i = 0; i < spots.length; i++) {
      final x = (spots[i].x - xMin) / xRange * size.width;
      final y = size.height - ((spots[i].y - minY) / yRange * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) => false;
}
