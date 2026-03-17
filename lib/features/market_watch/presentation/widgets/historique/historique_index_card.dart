import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// ULTIMATE Index Card — Animated drawing sparkline, gradient glow header,
/// year high/low with position indicator, premium micro-interactions
class HistoriqueIndexCard extends StatefulWidget {
  final String title;
  final double currentValue;
  final double change;
  final List<HistoriqueChartPoint> chartData;
  final bool isTunindex20;

  const HistoriqueIndexCard({
    super.key,
    required this.title,
    required this.currentValue,
    required this.change,
    required this.chartData,
    this.isTunindex20 = false,
  });

  @override
  State<HistoriqueIndexCard> createState() => _HistoriqueIndexCardState();
}

class _HistoriqueIndexCardState extends State<HistoriqueIndexCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawCtrl;

  @override
  void initState() {
    super.initState();
    _drawCtrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    Future.delayed(600.ms, () {
      if (mounted) _drawCtrl.forward();
    });
  }

  @override
  void dispose() {
    _drawCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = widget.change >= 0;
    final changeColor = isPositive ? AppColors.bullGreen : AppColors.bearRed;
    final accentColor =
        widget.isTunindex20 ? const Color(0xFFE8912D) : AppColors.primaryBlue;
    final nf = NumberFormat('#,##0.00', 'fr_FR');

    final values = widget.chartData
        .map((p) => widget.isTunindex20 ? p.tunindex20 : p.tunindex)
        .toList();
    final yearHigh =
        values.isNotEmpty ? values.reduce(math.max) : widget.currentValue;
    final yearLow =
        values.isNotEmpty ? values.reduce(math.min) : widget.currentValue;
    final range = yearHigh - yearLow;
    final positionPct =
        range > 0 ? (widget.currentValue - yearLow) / range : 0.5;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header with animated sparkline ──
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.08),
                  accentColor.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accentColor, accentColor.withValues(alpha: 0.6)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.title,
                              style: AppTypography.labelLarge.copyWith(
                                color: accentColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          nf.format(widget.currentValue),
                          style: AppTypography.indexValue.copyWith(fontSize: 17),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: changeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPositive
                                  ? Icons.north_east_rounded
                                  : Icons.south_east_rounded,
                              size: 11,
                              color: changeColor,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${isPositive ? '+' : ''}${widget.change.toStringAsFixed(2)}%',
                              style: AppTypography.changePercentSmall
                                  .copyWith(color: changeColor, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Animated sparkline 
                SizedBox(
                  width: 60,
                  height: 38,
                  child: AnimatedBuilder(
                    listenable: _drawCtrl,
                    builder: (context, _) => CustomPaint(
                      painter: _AnimatedSparklinePainter(
                        data: values.length > 30
                            ? values.sublist(values.length - 30)
                            : values,
                        color: accentColor,
                        progress: _drawCtrl.value,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Year Range with position indicator ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _RangeLabel(
                      label: 'Plus Bas',
                      value: nf.format(yearLow),
                      color: AppColors.bearRed,
                      alignment: CrossAxisAlignment.start,
                    ),
                    _RangeLabel(
                      label: 'Plus Haut',
                      value: nf.format(yearHigh),
                      color: AppColors.bullGreen,
                      alignment: CrossAxisAlignment.end,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Position bar
                SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFE74C3C),
                              Color(0xFFF39C12),
                              Color(0xFF27AE60),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Positioned(
                        left: null,
                        right: null,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final pos =
                                (constraints.maxWidth * positionPct).clamp(4.0, constraints.maxWidth - 4);
                            return Container(
                              margin: EdgeInsets.only(left: pos - 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withValues(alpha: 0.4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final CrossAxisAlignment alignment;

  const _RangeLabel({
    required this.label,
    required this.value,
    required this.color,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            fontSize: 9,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Sparkline that animates drawing progressively
class _AnimatedSparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double progress; // 0..1

  _AnimatedSparklinePainter({
    required this.data,
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = maxVal - minVal;
    if (range == 0) return;

    final visibleCount = (data.length * progress).ceil().clamp(2, data.length);
    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < visibleCount; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height * 0.9;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        // Smooth curve via cubic bezier
        final prevX = ((i - 1) / (data.length - 1)) * size.width;
        final prevY = size.height -
            ((data[i - 1] - minVal) / range) * size.height * 0.9;
        final ctrlX = (prevX + x) / 2;
        path.cubicTo(ctrlX, prevY, ctrlX, y, x, y);
        fillPath.cubicTo(ctrlX, prevY, ctrlX, y, x, y);
      }
    }

    // Fill gradient
    final lastX = ((visibleCount - 1) / (data.length - 1)) * size.width;
    fillPath.lineTo(lastX, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.25 * progress),
            color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: progress)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // End dot (glowing)
    if (progress > 0.8) {
      final endY = size.height -
          ((data[visibleCount - 1] - minVal) / range) * size.height * 0.9;
      final dotOpacity = ((progress - 0.8) / 0.2).clamp(0.0, 1.0);
      // Glow
      canvas.drawCircle(
        Offset(lastX, endY),
        5,
        Paint()..color = color.withValues(alpha: 0.2 * dotOpacity),
      );
      // Core dot
      canvas.drawCircle(
        Offset(lastX, endY),
        3,
        Paint()..color = color.withValues(alpha: dotOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AnimatedSparklinePainter old) =>
      old.progress != progress || old.data != data;
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required Animation super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context, null);
}
