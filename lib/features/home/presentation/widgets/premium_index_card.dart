import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/market_summary_entity.dart';

/// Premium animated index card for TUNINDEX / TUNINDEX20
/// ──────────────────────────────────────────────────────
/// • Background: transparent #0D4FA8 gradient
/// • Rotating gradient border glow
/// • Diagonal shimmer sweep
/// • Subtle pulse glow effect
class PremiumIndexCard extends StatefulWidget {
  final IndexData index;
  final VoidCallback? onTap;

  const PremiumIndexCard({super.key, required this.index, this.onTap});

  @override
  State<PremiumIndexCard> createState() => _PremiumIndexCardState();
}

class _PremiumIndexCardState extends State<PremiumIndexCard>
    with TickerProviderStateMixin {
  // ── Animated border rotation ──
  late final AnimationController _borderController;
  // ── Shimmer sweep ──
  late final AnimationController _shimmerController;
  // ── Subtle pulse glow ──
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Border glow rotation — 4s loop
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Shimmer sweep — 2.5s loop
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    // Pulse glow — 3s loop
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _borderController.dispose();
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final index = widget.index;
    final positive = index.changePercent >= 0;
    final statusColor = positive ? AppColors.bullGreen : AppColors.bearRed;
    final arrowIcon =
        positive ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
      animation: Listenable.merge([
        _borderController,
        _shimmerController,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: _CardBorderPainter(
            progress: _borderController.value,
            pulseValue: _pulseAnimation.value,
          ),
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusMD),
        child: Stack(
          children: [
            // ── 1) Subtle transparent #0D1F3C background ──
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0D1F3C).withValues(alpha: 0.12),
                    const Color(0xFF0D1F3C).withValues(alpha: 0.18),
                    const Color(0xFF0D1F3C).withValues(alpha: 0.14),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusMD),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Name badge ──
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1F3C).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      index.name,
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFF0D1F3C),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Main value ──
                  Text(
                    index.formattedValue,
                    style: AppTypography.indexValue.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Daily change pill ──
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: positive
                          ? AppColors.bullGreen.withValues(alpha: 0.12)
                          : AppColors.bearRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(arrowIcon, size: 14, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          index.formattedChange,
                          style: AppTypography.changePercentSmall.copyWith(
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Annual change ──
                  Row(
                    children: [
                      Text(
                        'Ann. ',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Icon(
                        index.yearChangePercent >= 0
                            ? Icons.north_east_rounded
                            : Icons.south_east_rounded,
                        size: 12,
                        color: index.yearChangePercent >= 0
                            ? AppColors.bullGreen
                            : AppColors.bearRed,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        index.formattedYearChange,
                        style: AppTypography.labelMedium.copyWith(
                          color: index.yearChangePercent >= 0
                              ? AppColors.bullGreen
                              : AppColors.bearRed,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 2) Diagonal shimmer sweep ──
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, _) {
                    final progress = _shimmerController.value;
                    // Slide from -50% to 150% of card width
                    final alignX = -1.5 + progress * 3.0;
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusMD),
                        gradient: LinearGradient(
                          begin: Alignment(alignX, -0.3),
                          end: Alignment(alignX + 1.0, 0.3),
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.grey.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.18),
                            Colors.grey.withValues(alpha: 0.12),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

/// ── Animated border painter with rotating gradient + pulse glow ──
class _CardBorderPainter extends CustomPainter {
  final double progress; // 0..1 rotation
  final double pulseValue; // 0..1 glow intensity

  _CardBorderPainter({required this.progress, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(1),
      const Radius.circular(AppDimens.radiusMD),
    );

    final angle = progress * 2 * math.pi;

    // ── Rotating gradient border ──
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = SweepGradient(
        startAngle: angle,
        endAngle: angle + 2 * math.pi,
        colors: [
          const Color(0xFF0D1F3C).withValues(alpha: 0.05),
          const Color(0xFF0D1F3C).withValues(alpha: 0.35 + pulseValue * 0.15),
          const Color(0xFF0D1F3C).withValues(alpha: 0.15),
          const Color(0xFF0D1F3C).withValues(alpha: 0.40 + pulseValue * 0.15),
          const Color(0xFF0D1F3C).withValues(alpha: 0.05),
        ],
        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        tileMode: TileMode.clamp,
      ).createShader(rect);

    canvas.drawRRect(rrect, borderPaint);

    // ── Outer glow (subtle pulse) ──
    final glowOpacity = 0.04 + pulseValue * 0.06;
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..color = const Color(0xFF0D1F3C).withValues(alpha: glowOpacity);

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(_CardBorderPainter old) => true;
}
