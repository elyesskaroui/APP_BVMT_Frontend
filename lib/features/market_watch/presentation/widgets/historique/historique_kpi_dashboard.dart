import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// ULTIMATE KPI Dashboard — Animated counters, glass cards, circular progress rings,
/// gradient icon containers, glow shadows, scale-in entry
class HistoriqueKpiDashboard extends StatelessWidget {
  final HistoriqueSessionEntity session;

  const HistoriqueKpiDashboard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final total = session.nbHausses + session.nbBaisses + session.nbInchangees;
    final hPct = total > 0 ? session.nbHausses / total : 0.0;
    final bPct = total > 0 ? session.nbBaisses / total : 0.0;
    final iPct = total > 0 ? session.nbInchangees / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GlassKpiCard(
                  label: 'Hausses',
                  value: session.nbHausses,
                  percentage: hPct,
                  accentColor: AppColors.bullGreen,
                  gradientColors: const [Color(0xFF27AE60), Color(0xFF2ECC71)],
                  icon: Icons.trending_up_rounded,
                  delay: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GlassKpiCard(
                  label: 'Baisses',
                  value: session.nbBaisses,
                  percentage: bPct,
                  accentColor: AppColors.bearRed,
                  gradientColors: const [Color(0xFFE74C3C), Color(0xFFEF5350)],
                  icon: Icons.trending_down_rounded,
                  delay: 80,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GlassKpiCard(
                  label: 'Inchangées',
                  value: session.nbInchangees,
                  percentage: iPct,
                  accentColor: AppColors.warningYellow,
                  gradientColors: const [Color(0xFFF39C12), Color(0xFFFFB74D)],
                  icon: Icons.remove_rounded,
                  delay: 160,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GlassKpiCard(
                  label: 'Transactions',
                  value: session.totalTransactions,
                  percentage: (session.totalTransactions / 5000).clamp(0.0, 1.0),
                  accentColor: AppColors.primaryBlue,
                  gradientColors: const [Color(0xFF0D4FA8), Color(0xFF1A6BCC)],
                  icon: Icons.swap_horiz_rounded,
                  isLargeNumber: true,
                  delay: 240,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassKpiCard extends StatefulWidget {
  final String label;
  final int value;
  final double percentage;
  final Color accentColor;
  final List<Color> gradientColors;
  final IconData icon;
  final bool isLargeNumber;
  final int delay;

  const _GlassKpiCard({
    required this.label,
    required this.value,
    required this.percentage,
    required this.accentColor,
    required this.gradientColors,
    required this.icon,
    this.isLargeNumber = false,
    required this.delay,
  });

  @override
  State<_GlassKpiCard> createState() => _GlassKpiCardState();
}

class _GlassKpiCardState extends State<_GlassKpiCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _countAnim;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _countAnim = Tween<double>(begin: 0, end: widget.value.toDouble())
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ringAnim = Tween<double>(begin: 0, end: widget.percentage)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 300 + widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void didUpdateWidget(_GlassKpiCard old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _countAnim = Tween<double>(
        begin: _countAnim.value,
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ringAnim = Tween<double>(
        begin: _ringAnim.value,
        end: widget.percentage,
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
          Row(
            children: [
              // Gradient icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(widget.icon, size: 18, color: Colors.white),
              ),
              const Spacer(),
              // Circular progress ring
              SizedBox(
                width: 40,
                height: 40,
                child: AnimatedBuilder(
                  listenable: _ringAnim,
                  builder: (context, _) => CustomPaint(
                    painter: _RingPainter(
                      progress: _ringAnim.value,
                      color: widget.accentColor,
                      bgColor: widget.accentColor.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        '${(_ringAnim.value * 100).toInt()}%',
                        style: AppTypography.labelSmall.copyWith(
                          color: widget.accentColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Animated counter value
          AnimatedBuilder(
            listenable: _countAnim,
            builder: (context, _) {
              final v = _countAnim.value;
              String display;
              if (widget.isLargeNumber && v >= 1000) {
                display = '${(v / 1000).toStringAsFixed(1)}K';
              } else {
                display = v.toInt().toString();
              }
              return Text(
                display,
                style: AppTypography.h2.copyWith(
                  color: widget.accentColor,
                  fontWeight: FontWeight.w800,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            widget.label,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          // Animated gradient bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 5,
              child: AnimatedBuilder(
                listenable: _ringAnim,
                builder: (context, _) {
                  return Stack(
                    children: [
                      Container(color: widget.accentColor.withValues(alpha: 0.08)),
                      FractionallySizedBox(
                        widthFactor: _ringAnim.value.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: widget.gradientColors),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: Duration(milliseconds: widget.delay))
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1, 1),
          duration: 500.ms,
          delay: Duration(milliseconds: widget.delay),
          curve: Curves.easeOutBack,
        );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _RingPainter({required this.progress, required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..color = color
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
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
