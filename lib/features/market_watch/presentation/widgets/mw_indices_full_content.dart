import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../indices/domain/entities/index_summary_entity.dart';
import '../../../indices/domain/entities/indices_stock_entity.dart';
import '../../../indices/presentation/bloc/indices_bloc.dart';
import '../../../indices/presentation/bloc/indices_event.dart';
import '../../../indices/presentation/bloc/indices_state.dart';

// ==========================================================================
// MwIndicesFullContent — Ultimate 10/10 Premium Design
// ==========================================================================

class MwIndicesFullContent extends StatelessWidget {
  final double hPadding;
  final IndicesBloc indicesBloc;

  const MwIndicesFullContent({
    super.key,
    required this.hPadding,
    required this.indicesBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IndicesBloc, IndicesState>(
      builder: (context, state) {
        if (state is IndicesLoading || state is IndicesInitial) {
          return _buildShimmer();
        }
        if (state is IndicesError) {
          return _buildError(state.message);
        }
        if (state is IndicesLoaded) {
          return _IndicesLoadedContent(
            state: state,
            hPadding: hPadding,
            indicesBloc: indicesBloc,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE8EAF0),
        highlightColor: const Color(0xFFF5F6FA),
        child: Column(
          children: [
            _sBox(52, 16),
            const SizedBox(height: 16),
            _sBox(140, 24),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: _sBox(80, 16)),
              const SizedBox(width: 8),
              Expanded(child: _sBox(80, 16)),
              const SizedBox(width: 8),
              Expanded(child: _sBox(80, 16)),
              const SizedBox(width: 8),
              Expanded(child: _sBox(80, 16)),
            ]),
            const SizedBox(height: 16),
            _sBox(280, 24),
            const SizedBox(height: 16),
            _sBox(120, 20),
            const SizedBox(height: 12),
            ...List.generate(
                6,
                (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _sBox(82, 18),
                    )),
          ],
        ),
      ),
    );
  }

  Widget _sBox(double h, double r) => Container(
      height: h,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(r)));

  Widget _buildError(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.bearRed.withValues(alpha: 0.15),
                  AppColors.bearRed.withValues(alpha: 0.05),
                ]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  color: AppColors.bearRed, size: 32),
            ),
            const SizedBox(height: 20),
            Text('Connexion impossible',
                style:
                    AppTypography.h3.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () =>
                    indicesBloc.add(const IndicesLoadRequested()),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text('R\u00e9essayer',
                    style: AppTypography.titleSmall
                        .copyWith(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================================
// LOADED CONTENT — Stateful for stagger animations & search
// ==========================================================================

class _IndicesLoadedContent extends StatefulWidget {
  final IndicesLoaded state;
  final double hPadding;
  final IndicesBloc indicesBloc;

  const _IndicesLoadedContent({
    required this.state,
    required this.hPadding,
    required this.indicesBloc,
  });

  @override
  State<_IndicesLoadedContent> createState() => _IndicesLoadedContentState();
}

class _IndicesLoadedContentState extends State<_IndicesLoadedContent>
    with TickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  static const _sectionCount = 6;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.12;
      final end = (start + 0.4).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerCtrl,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _staggerCtrl.forward();
  }

  @override
  void didUpdateWidget(covariant _IndicesLoadedContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.selectedIndex != widget.state.selectedIndex) {
      _staggerCtrl.reset();
      _staggerCtrl.forward();
    }
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  Widget _staggerWrap(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index.clamp(0, _sectionCount - 1)],
      child: SlideTransition(
        position: _slideAnims[index.clamp(0, _sectionCount - 1)],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hp = widget.hPadding;
    final s = widget.state;
    final summary = s.indexSummary;
    final bloc = widget.indicesBloc;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Segmented Selector
        _staggerWrap(
          0,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hp),
            child: _SegmentedSelector(
              selected: s.selectedIndex,
              options: s.availableIndices,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                bloc.add(IndicesIndexChanged(v));
              },
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 2. Hero Card
        if (summary != null)
          _staggerWrap(
            1,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hp),
              child: _HeroCard(
                summary: summary,
                chartPoints: s.chartPoints,
              ),
            ),
          ),
        const SizedBox(height: 12),

        // 3. Stats row
        if (summary != null)
          _staggerWrap(
            2,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hp),
              child: _StatsRow(summary: summary),
            ),
          ),
        const SizedBox(height: 20),

        // 4. Chart
        if (s.chartPoints.isNotEmpty)
          _staggerWrap(
            3,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hp),
              child: _ChartCard(
                chartPoints: s.chartPoints,
                period: s.chartPeriod,
                isPositive: summary?.isPositive ?? true,
                changePercent: summary?.changePercent ?? 0,
                onPeriodChanged: (p) =>
                    bloc.add(IndicesChartPeriodChanged(p)),
              ),
            ),
          ),
        const SizedBox(height: 22),

        // 5. Session summary
        _staggerWrap(
          4,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: hp),
            child: _SessionSummary(state: s),
          ),
        ),
        const SizedBox(height: 22),

        // 6. Composition
        _staggerWrap(
          5,
          _CompositionSection(
            state: s,
            hPadding: hp,
            bloc: bloc,
          ),
        ),
      ],
    );
  }
}

// ==========================================================================\n// 1. INDEX DROPDOWN SELECTOR\n// ==========================================================================

class _SegmentedSelector extends StatelessWidget {
  final String selected;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _SegmentedSelector({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Indices :',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),

        // Dropdown container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.18),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                  value: selected,
                  isExpanded: true,
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  dropdownColor: Colors.white,
                  elevation: 8,
                  menuMaxHeight: 400,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 2),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  selectedItemBuilder: (context) {
                    return options.map((opt) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          opt,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  items: options.map((opt) {
                    final isActive = opt == selected;
                    return DropdownMenuItem<String>(
                      value: opt,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryBlue.withValues(alpha: 0.08)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            // Active indicator
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isActive ? 3.5 : 0,
                              height: 20,
                              margin:
                                  EdgeInsets.only(right: isActive ? 10 : 0),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                opt,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isActive
                                      ? AppColors.primaryBlue
                                      : AppColors.textPrimary,
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            if (isActive)
                              Icon(
                                Icons.check_rounded,
                                color: AppColors.primaryBlue,
                                size: 18,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) onChanged(v);
                  },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// 2. HERO CARD — clean white premium
// ==========================================================================

class _HeroCard extends StatelessWidget {
  final IndexSummaryEntity summary;
  final List<IndexChartPoint> chartPoints;

  const _HeroCard({required this.summary, required this.chartPoints});

  @override
  Widget build(BuildContext context) {
    final positive = summary.isPositive;
    final accent = positive ? AppColors.bullGreen : AppColors.bearRed;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.06),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Triple sparkline ribbon covering full card
            if (chartPoints.length > 2) ...[
              // Line 1 — top zone: soft blue
              Positioned.fill(
                child: Opacity(
                  opacity: 0.07,
                  child: _MiniSparkline(
                    points: chartPoints,
                    color: AppColors.primaryBlue,
                    phaseOffset: 0.33,
                    verticalShift: -0.30,
                  ),
                ),
              ),
              // Line 2 — middle zone: main accent (strongest)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.13,
                  child: _MiniSparkline(
                    points: chartPoints,
                    color: accent,
                    phaseOffset: 0.0,
                    verticalShift: 0.0,
                  ),
                ),
              ),
              // Line 3 — bottom zone: warm orange
              Positioned.fill(
                child: Opacity(
                  opacity: 0.06,
                  child: _MiniSparkline(
                    points: chartPoints,
                    color: AppColors.accentOrange,
                    phaseOffset: 0.66,
                    verticalShift: 0.28,
                  ),
                ),
              ),
            ],

            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top accent gradient bar
                Container(
                  height: 3.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryBlueLight,
                        accent.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row: index name + LIVE badge
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 11, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      summary.name,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: AppTypography.labelMedium.copyWith(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _LivePulse(color: accent),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Big value
                      _AnimatedValue(
                        text: summary.formattedValue,
                        style: AppTypography.hero.copyWith(
                          color: AppColors.deepNavy,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Variation badge + Previous close
                      Row(
                        children: [
                          _VariationBadge(
                            label: summary.formattedChange,
                            isPositive: positive,
                            accent: accent,
                          ),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule_rounded,
                                    size: 11,
                                    color: AppColors.textSecondary
                                        .withValues(alpha: 0.45)),
                                const SizedBox(width: 5),
                                Text(
                                  'Veille ',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  summary.formattedPreviousClose,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated live pulse dot
class _LivePulse extends StatefulWidget {
  final Color color;
  const _LivePulse({required this.color});
  @override
  State<_LivePulse> createState() => _LivePulseState();
}

class _LivePulseState extends State<_LivePulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: widget.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.7),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'LIVE',
            style: TextStyle(
              color: widget.color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated mini sparkline for hero card background
class _MiniSparkline extends StatefulWidget {
  final List<IndexChartPoint> points;
  final Color color;
  final double phaseOffset;
  final double verticalShift;
  const _MiniSparkline({
    required this.points,
    required this.color,
    this.phaseOffset = 0.0,
    this.verticalShift = 0.0,
  });

  @override
  State<_MiniSparkline> createState() => _MiniSparklineState();
}

class _MiniSparklineState extends State<_MiniSparkline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final phase = (_ctrl.value + widget.phaseOffset) % 1.0;
        return CustomPaint(
          painter: _SparkPainter(
            points: widget.points,
            color: widget.color,
            phase: phase,
            verticalShift: widget.verticalShift,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<IndexChartPoint> points;
  final Color color;
  final double phase;
  final double verticalShift;
  _SparkPainter({
    required this.points,
    required this.color,
    required this.phase,
    this.verticalShift = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final vals = points.map((p) => p.value).toList();
    final minV = vals.reduce(math.min);
    final maxV = vals.reduce(math.max);
    final range = maxV - minV;
    if (range == 0) return;

    final vShift = verticalShift * size.height;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height -
          ((vals[i] - minV) / range) * size.height * 0.85 +
          vShift;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = ((i - 1) / (points.length - 1)) * size.width;
        final prevY = size.height -
            ((vals[i - 1] - minV) / range) * size.height * 0.85 +
            vShift;
        final cx = (prevX + x) / 2;
        path.cubicTo(cx, prevY, cx, y, x, y);
      }
    }

    // Base line
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.45)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Animated glow pulse traveling along the line
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final totalLen = metrics.first.length;
      final glowLen = totalLen * 0.25;
      final glowStart = phase * totalLen;
      final glowEnd = glowStart + glowLen;

      Path? glowPath;
      if (glowEnd <= totalLen) {
        glowPath = metrics.first.extractPath(glowStart, glowEnd);
      } else {
        glowPath = metrics.first.extractPath(glowStart, totalLen);
        final remainder =
            metrics.first.extractPath(0, glowEnd - totalLen);
        glowPath.addPath(remainder, Offset.zero);
      }

      // Outer glow
      canvas.drawPath(
        glowPath,
        Paint()
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Bright core
      canvas.drawPath(
        glowPath,
        Paint()
          ..color = color
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Gradient fill below
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.points != points || old.phase != phase;
}

/// Animated hero value text
class _AnimatedValue extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _AnimatedValue({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
                  begin: const Offset(0, 0.15), end: Offset.zero)
              .animate(anim),
          child: child,
        ),
      ),
      child: Text(text, key: ValueKey(text), style: style),
    );
  }
}

/// Variation badge
class _VariationBadge extends StatelessWidget {
  final String label;
  final bool isPositive;
  final Color accent;
  const _VariationBadge({
    required this.label,
    required this.isPositive,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          accent.withValues(alpha: 0.18),
          accent.withValues(alpha: 0.08),
        ]),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            color: accent,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                color: accent,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              )),
        ],
      ),
    );
  }
}

// ==========================================================================
// 3. STATS ROW
// ==========================================================================

class _StatsRow extends StatelessWidget {
  final IndexSummaryEntity summary;
  const _StatsRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _SD('Veille', summary.formattedPreviousClose, Icons.schedule_rounded,
          const Color(0xFF6C8EBF)),
      _SD('Plus haut', summary.formattedHigh, Icons.north_rounded,
          const Color(0xFF34D399)),
      _SD('Plus bas', summary.formattedLow, Icons.south_rounded,
          const Color(0xFFFF8C6B)),
      _SD(
          'Var. 31/12',
          summary.formattedYearChange,
          Icons.date_range_rounded,
          summary.yearChangePercent >= 0
              ? const Color(0xFF34D399)
              : const Color(0xFFFF6B6B)),
    ];

    return Row(
      children: stats.asMap().entries.map((e) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: e.key < stats.length - 1 ? 8 : 0),
            child: _StatTile(d: e.value),
          ),
        );
      }).toList(),
    );
  }
}

class _SD {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SD(this.label, this.value, this.icon, this.color);
}

class _StatTile extends StatelessWidget {
  final _SD d;
  const _StatTile({required this.d});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: d.color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: d.color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                d.color.withValues(alpha: 0.15),
                d.color.withValues(alpha: 0.05),
              ]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(d.icon, color: d.color, size: 15),
          ),
          const SizedBox(height: 7),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(d.value,
                style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 2),
          Text(d.label,
              style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ==========================================================================
// 4. CHART CARD
// ==========================================================================

class _ChartCard extends StatelessWidget {
  final List<IndexChartPoint> chartPoints;
  final String period;
  final bool isPositive;
  final double changePercent;
  final ValueChanged<String> onPeriodChanged;

  static const _periods = ['15M', '1H', '3H', 'ALL'];

  const _ChartCard({
    required this.chartPoints,
    required this.period,
    required this.isPositive,
    required this.changePercent,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lc = isPositive ? const Color(0xFF34D399) : const Color(0xFFFF6B6B);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3252), Color(0xFF0D1A2E)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1A2E).withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _DotGrid())),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\u00c9volution intraday',
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.9),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text('S\u00e9ance du jour en cours',
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.35),
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: lc.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              Border.all(color: lc.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                              color: lc,
                              fontSize: 12,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: _periods.map((p) {
                      final sel = p == period;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onPeriodChanged(p);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: sel
                                ? lc.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: sel
                                  ? lc.withValues(alpha: 0.35)
                                  : Colors.white.withValues(alpha: 0.06),
                              width: sel ? 1.2 : 0.5,
                            ),
                          ),
                          child: Text(p,
                              style: TextStyle(
                                color: sel
                                    ? lc
                                    : Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                                fontWeight:
                                    sel ? FontWeight.w800 : FontWeight.w500,
                              )),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(height: 190, child: _buildChart(lc)),
                  const SizedBox(height: 10),
                  _timeLabels(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(Color lc) {
    final filtered = _filter();
    if (filtered.isEmpty) {
      return Center(
          child: Text('Donn\u00e9es indisponibles',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12)));
    }

    final isAllPeriod = period == 'ALL';

    // For ALL: generate stepped (ECG) spots — horizontal then vertical
    final List<FlSpot> spots;
    if (isAllPeriod && filtered.length > 1) {
      spots = [];
      for (var i = 0; i < filtered.length; i++) {
        final p = filtered[i];
        if (i > 0) {
          // horizontal segment: same Y as previous, new X
          spots.add(FlSpot(p.minutesSince9, filtered[i - 1].value));
        }
        // vertical segment: actual point
        spots.add(FlSpot(p.minutesSince9, p.value));
      }
    } else {
      spots = filtered.map((p) => FlSpot(p.minutesSince9, p.value)).toList();
    }

    final vals = filtered.map((p) => p.value).toList();
    final mn = vals.reduce(math.min);
    final mx = vals.reduce(math.max);
    final rng = mx - mn;
    final minY = mn - rng * 0.15;
    final maxY = mx + rng * 0.15;
    final iv = rng > 0 ? (rng / 3).ceilToDouble() : 10.0;

    return LineChart(
      LineChartData(
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: iv > 0 ? iv : 10,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.white.withValues(alpha: 0.04),
            strokeWidth: 0.5,
            dashArray: [4, 6],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: iv > 0 ? iv : 10,
              reservedSize: 52,
              getTitlesWidget: (v, _) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(v.toStringAsFixed(0),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) =>
                const Color(0xFF2A3F5F).withValues(alpha: 0.95),
            tooltipRoundedRadius: 14,
            tooltipPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            getTooltipItems: (ts) => ts.map((spot) {
              final h = 9 + (spot.x ~/ 60);
              final m = (spot.x % 60).toInt().toString().padLeft(2, '0');
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(2)}\n$h:$m',
                TextStyle(
                    color: lc,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    height: 1.5),
              );
            }).toList(),
          ),
          getTouchedSpotIndicator: (_, idxs) => idxs
              .map((_) => TouchedSpotIndicatorData(
                    FlLine(
                        color: lc.withValues(alpha: 0.5),
                        strokeWidth: 1,
                        dashArray: [4, 4]),
                    FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) =>
                          FlDotCirclePainter(
                        radius: 5,
                        color: lc,
                        strokeWidth: 2.5,
                        strokeColor: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ))
              .toList(),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: !isAllPeriod,
            curveSmoothness: 0.22,
            color: lc,
            barWidth: isAllPeriod ? 1.5 : 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) {
                if (spot.x == spots.last.x) {
                  return FlDotCirclePainter(
                    radius: 4.5,
                    color: lc,
                    strokeWidth: 2.5,
                    strokeColor: Colors.white.withValues(alpha: 0.85),
                  );
                }
                return FlDotCirclePainter(
                    radius: 0, color: Colors.transparent);
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  lc.withValues(alpha: 0.28),
                  lc.withValues(alpha: 0.08),
                  lc.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  List<IndexChartPoint> _filter() {
    if (chartPoints.isEmpty) return chartPoints;
    final last = chartPoints.last.minutesSince9;
    return switch (period) {
      '15M' =>
        chartPoints.where((p) => p.minutesSince9 >= last - 15).toList(),
      '1H' =>
        chartPoints.where((p) => p.minutesSince9 >= last - 60).toList(),
      '3H' =>
        chartPoints.where((p) => p.minutesSince9 >= last - 180).toList(),
      _ => chartPoints,
    };
  }

  Widget _timeLabels() {
    final ls = switch (period) {
      '15M' => ['', '', '', '', 'Now'],
      '1H' => ['-1h', '-45m', '-30m', '-15m', 'Now'],
      '3H' => ['-3h', '-2h', '-1h', '-30m', 'Now'],
      _ => ['09:00', '10:00', '11:00', '12:00', '13:00'],
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ls
            .map((t) => Text(t,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.28),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500)))
            .toList(),
      ),
    );
  }
}

class _DotGrid extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeCap = StrokeCap.round;
    const sp = 22.0;
    for (double x = sp; x < size.width; x += sp) {
      for (double y = sp; y < size.height; y += sp) {
        canvas.drawCircle(Offset(x, y), 0.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ==========================================================================
// 5. SESSION SUMMARY with donut
// ==========================================================================

class _SessionSummary extends StatelessWidget {
  final IndicesLoaded state;
  const _SessionSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final total =
        state.totalHausses + state.totalBaisses + state.totalInchangees;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryBlueDark,
                  ]),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.insights_rounded,
                    color: Colors.white, size: 17),
              ),
              const SizedBox(width: 10),
              Text('R\u00e9sum\u00e9 de la s\u00e9ance',
                  style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 14.5)),
            ],
          ),
          const SizedBox(height: 18),

          // Donut + legends
          Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CustomPaint(
                  painter: _DonutPainter(
                    h: state.totalHausses,
                    b: state.totalBaisses,
                    i: state.totalInchangees,
                  ),
                  child: Center(
                    child: Text('$total',
                        style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _leg(const Color(0xFF34D399), 'Hausses',
                        state.totalHausses, total),
                    const SizedBox(height: 6),
                    _leg(const Color(0xFFD1D5DB), 'Inchang\u00e9es',
                        state.totalInchangees, total),
                    const SizedBox(height: 6),
                    _leg(const Color(0xFFFF6B6B), 'Baisses',
                        state.totalBaisses, total),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _MC('Transactions', _fk(state.totalTransactions),
                    Icons.swap_horiz_rounded),
                _div(),
                _MC('Volume', _fk(state.totalVolume),
                    Icons.bar_chart_rounded),
                _div(),
                _MC('Capitaux', '${_fk(state.totalCapitaux)} TND',
                    Icons.account_balance_wallet_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leg(Color c, String label, int count, int total) {
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: c, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style:
                    AppTypography.labelMedium.copyWith(fontSize: 11.5))),
        Text('$count',
            style: AppTypography.labelLarge
                .copyWith(fontWeight: FontWeight.w800, fontSize: 12)),
        const SizedBox(width: 6),
        SizedBox(
          width: 32,
          child: Text('$pct%',
              textAlign: TextAlign.right,
              style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary, fontSize: 10)),
        ),
      ],
    );
  }

  Widget _div() => Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: AppColors.divider.withValues(alpha: 0.35));

  static String _fk(int v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}

class _MC extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _MC(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon,
              size: 16,
              color: AppColors.primaryBlue.withValues(alpha: 0.45)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: AppTypography.bodyMediumBold.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.labelSmall.copyWith(
                  fontSize: 9.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final int h, b, i;
  _DonutPainter({required this.h, required this.b, required this.i});

  @override
  void paint(Canvas canvas, Size size) {
    final total = h + b + i;
    if (total == 0) return;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const sw = 6.0;
    final cr = rect.deflate(sw / 2);
    var angle = -math.pi / 2;

    for (final (count, color) in [
      (h, const Color(0xFF34D399)),
      (i, const Color(0xFFD1D5DB)),
      (b, const Color(0xFFFF6B6B)),
    ]) {
      if (count == 0) continue;
      final sweep = (count / total) * 2 * math.pi;
      canvas.drawArc(
          cr,
          angle,
          sweep - 0.04,
          false,
          Paint()
            ..color = color
            ..strokeWidth = sw
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
      angle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.h != h || old.b != b || old.i != i;
}

// ==========================================================================
// 6. COMPOSITION SECTION
// ==========================================================================

class _CompositionSection extends StatefulWidget {
  final IndicesLoaded state;
  final double hPadding;
  final IndicesBloc bloc;
  const _CompositionSection({
    required this.state,
    required this.hPadding,
    required this.bloc,
  });

  @override
  State<_CompositionSection> createState() => _CompositionSectionState();
}

class _CompositionSectionState extends State<_CompositionSection> {
  String _q = '';

  List<IndicesStockEntity> get _filtered {
    if (_q.isEmpty) return widget.state.displayedStocks;
    final q = _q.toLowerCase();
    return widget.state.displayedStocks
        .where((s) => s.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final stocks = _filtered;
    final hp = widget.hPadding;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hp),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 26,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryBlue,
                      AppColors.primaryBlueLight
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text('Composition',
                  style: AppTypography.titleLarge
                      .copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${stocks.length}',
                    style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Search
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hp),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: const Color(0xFFE4E7EF), width: 0.5),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _q = v),
              style: AppTypography.bodyMedium.copyWith(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Rechercher une valeur...',
                hintStyle: AppTypography.bodyMedium.copyWith(
                    color:
                        AppColors.textSecondary.withValues(alpha: 0.5),
                    fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18,
                    color:
                        AppColors.textSecondary.withValues(alpha: 0.4)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Sort
        _SortChips(
            state: widget.state, hPadding: hp, bloc: widget.bloc),
        const SizedBox(height: 6),

        // Delay
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hp),
          child: Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 11,
                  color:
                      AppColors.textSecondary.withValues(alpha: 0.4)),
              const SizedBox(width: 4),
              Text('*En diff\u00e9r\u00e9 de 15 minutes',
                  style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary
                          .withValues(alpha: 0.45),
                      fontSize: 9.5,
                      fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Cards
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hp),
          child: stocks.isEmpty
              ? _empty()
              : Column(
                  children: stocks.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child:
                          _StockCard(stock: e.value, rank: e.key + 1),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _empty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded,
                  color: AppColors.primaryBlue, size: 28),
            ),
            const SizedBox(height: 14),
            Text('Aucune valeur trouv\u00e9e',
                style: AppTypography.titleSmall
                    .copyWith(color: AppColors.textSecondary)),
            if (_q.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('Essayez un autre terme',
                  style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary
                          .withValues(alpha: 0.6))),
            ],
          ],
        ),
      ),
    );
  }
}

class _SortChips extends StatelessWidget {
  final IndicesLoaded state;
  final double hPadding;
  final IndicesBloc bloc;
  const _SortChips({
    required this.state,
    required this.hPadding,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final chips = [
      (IndicesSortColumn.name, 'Nom', Icons.sort_by_alpha_rounded),
      (IndicesSortColumn.changePercent, 'Variation',
          Icons.trending_up_rounded),
      (IndicesSortColumn.capitaux, 'Capitaux',
          Icons.account_balance_wallet_rounded),
      (IndicesSortColumn.volume, 'Volume', Icons.bar_chart_rounded),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (col, label, icon) = chips[i];
          final a = state.sortColumn == col;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              bloc.add(IndicesSortRequested(col));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: a ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: a
                        ? AppColors.primaryBlue
                        : const Color(0xFFE4E7EF)),
                boxShadow: a
                    ? [
                        BoxShadow(
                          color: AppColors.primaryBlue
                              .withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 13,
                      color: a
                          ? Colors.white
                          : AppColors.textSecondary),
                  const SizedBox(width: 5),
                  Text(label,
                      style: AppTypography.labelSmall.copyWith(
                          color: a
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight:
                              a ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 11)),
                  if (a) ...[
                    const SizedBox(width: 3),
                    Icon(
                        state.sortAscending
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 12,
                        color: Colors.white),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================================================
// STOCK CARD — expandable, colored accent border
// ==========================================================================

class _StockCard extends StatefulWidget {
  final IndicesStockEntity stock;
  final int rank;
  const _StockCard({required this.stock, required this.rank});
  @override
  State<_StockCard> createState() => _StockCardState();
}

class _StockCardState extends State<_StockCard> {
  bool _exp = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.stock;
    final accent = s.isPositive
        ? const Color(0xFF34D399)
        : s.isNegative
            ? const Color(0xFFFF6B6B)
            : const Color(0xFFB0B8C4);
    final cIcon = s.isPositive
        ? Icons.trending_up_rounded
        : s.isNegative
            ? Icons.trending_down_rounded
            : Icons.remove_rounded;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _exp = !_exp);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _exp
                  ? accent.withValues(alpha: 0.2)
                  : const Color(0xFFF0F1F5)),
          boxShadow: [
            BoxShadow(
              color: _exp
                  ? accent.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _exp ? 18 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Colored left accent
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 4,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12, 12, 14, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text('${widget.rank}',
                                    style: AppTypography.labelSmall
                                        .copyWith(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(s.name,
                                      style: AppTypography.titleSmall
                                          .copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Text('${s.formattedClosePrice} TND',
                                      style: AppTypography.labelMedium
                                          .copyWith(
                                              color:
                                                  AppColors.textSecondary,
                                              fontSize: 11)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(cIcon, size: 13, color: accent),
                                  const SizedBox(width: 4),
                                  Text(s.formattedChange,
                                      style: TextStyle(
                                          color: accent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: _exp ? 0.5 : 0,
                              duration:
                                  const Duration(milliseconds: 200),
                              child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 20,
                                  color: AppColors.textSecondary
                                      .withValues(alpha: 0.35)),
                            ),
                          ],
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox(
                            width: double.infinity, height: 0),
                        secondChild: _details(s),
                        crossFadeState: _exp
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 260),
                        sizeCurve: Curves.easeOutCubic,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _details(IndicesStockEntity s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 14, 14),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 12),
            color: AppColors.divider.withValues(alpha: 0.25),
          ),
          Row(children: [
            _dt('Ouverture', s.formattedOpenPrice),
            _dt('Cl\u00f4ture', s.formattedClosePrice),
            _dt('Transactions', s.formattedTransactions),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _dt('Volume', s.formattedVolume),
            _dt('Capitaux', s.formattedCapitaux),
            const Expanded(child: SizedBox()),
          ]),
        ],
      ),
    );
  }

  Widget _dt(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.labelSmall.copyWith(
                  color:
                      AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 10)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTypography.bodyMediumBold.copyWith(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
