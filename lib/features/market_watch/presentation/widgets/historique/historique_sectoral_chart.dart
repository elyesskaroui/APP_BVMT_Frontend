import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// ULTIMATE Sectoral Chart — Horizontal animated bars, readable labels,
/// gradient fills, touch highlighting, summary chips, premium styling
class HistoriqueSectoralChart extends StatefulWidget {
  final List<SectorBreakdown> sectors;

  const HistoriqueSectoralChart({super.key, required this.sectors});

  @override
  State<HistoriqueSectoralChart> createState() =>
      _HistoriqueSectoralChartState();
}

class _HistoriqueSectoralChartState extends State<HistoriqueSectoralChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _barAnim;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _barAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<SectorBreakdown>.from(widget.sectors)
      ..sort((a, b) => b.percentage.compareTo(a.percentage));

    final maxPct = sorted.isNotEmpty ? sorted.first.percentage : 1.0;
    final posCount = sorted.where((s) => s.variation >= 0).length;
    final negCount = sorted.length - posCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.06)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              blurRadius: 18,
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
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bar_chart_rounded,
                        size: 16, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text('Performance Sectorielle',
                        style: AppTypography.titleLarge,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),

            // ── Summary chips ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
              child: Row(
                children: [
                  _SummaryChip(
                    icon: Icons.trending_up_rounded,
                    label: '$posCount en hausse',
                    color: AppColors.bullGreen,
                  ),
                  const SizedBox(width: 8),
                  _SummaryChip(
                    icon: Icons.trending_down_rounded,
                    label: '$negCount en baisse',
                    color: AppColors.bearRed,
                  ),
                ],
              ),
            ),

            // ── Horizontal bars ──
            AnimatedBuilder(
              animation: _barAnim,
              builder: (context, child) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 4),
                  child: Column(
                    children: sorted.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final sector = entry.value;
                      final isPositive = sector.variation >= 0;
                      final barColor =
                          isPositive ? AppColors.bullGreen : AppColors.bearRed;
                      final isTouched = _touchedIndex == idx;

                      return GestureDetector(
                        onTapDown: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => _touchedIndex = idx);
                        },
                        onTapUp: (_) =>
                            setState(() => _touchedIndex = -1),
                        onTapCancel: () =>
                            setState(() => _touchedIndex = -1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isTouched
                                ? barColor.withValues(alpha: 0.06)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Label row
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      sector.name,
                                      style: AppTypography.labelMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isTouched
                                            ? barColor
                                            : AppColors.textPrimary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${sector.percentage.toStringAsFixed(1)}%',
                                    style: AppTypography.labelMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: barColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      '${isPositive ? '+' : ''}${sector.variation.toStringAsFixed(2)}%',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: barColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Animated horizontal bar
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: SizedBox(
                                  height: 6,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: barColor.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor:
                                            (sector.percentage / maxPct) *
                                                _barAnim.value,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isPositive
                                                  ? [
                                                      const Color(0xFF27AE60),
                                                      const Color(0xFF2ECC71),
                                                      const Color(0xFF6FCF97),
                                                    ]
                                                  : [
                                                      const Color(0xFFE74C3C),
                                                      const Color(0xFFEF5350),
                                                      const Color(0xFFFF8A80),
                                                    ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: barColor
                                                    .withValues(alpha: 0.25),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: (100 + idx * 60).ms,
                            duration: 400.ms,
                          )
                          .slideX(
                            begin: -0.03,
                            end: 0,
                            delay: (100 + idx * 60).ms,
                            duration: 400.ms,
                          );
                    }).toList(),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimB(listenable: animation, builder: builder);
  }
}

class _AnimB extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const _AnimB({
    required super.listenable,
    required this.builder,
  }) : super();

  @override
  Widget build(BuildContext context) => builder(context, null);
}
