import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../domain/entities/historique_entity.dart';

/// V4 Market Indicators — Floating orbs header, animated hero counter,
/// glass variation cards with accent side bar, individual stat mini-cards,
/// radial glow badges, staggered micro-animations
class HistoriqueMarketIndicators extends StatefulWidget {
  final HistoriqueSessionEntity session;

  const HistoriqueMarketIndicators({super.key, required this.session});

  @override
  State<HistoriqueMarketIndicators> createState() =>
      _HistoriqueMarketIndicatorsState();
}

class _HistoriqueMarketIndicatorsState extends State<HistoriqueMarketIndicators>
    with TickerProviderStateMixin {
  late AnimationController _capCtrl;
  late Animation<double> _capAnim;
  late AnimationController _orbCtrl;

  @override
  void initState() {
    super.initState();
    _capCtrl = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );
    _capAnim = Tween<double>(begin: 0, end: widget.session.capBoursiere)
        .animate(CurvedAnimation(parent: _capCtrl, curve: Curves.easeOutCubic));

    _orbCtrl = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    Future.delayed(350.ms, () {
      if (mounted) _capCtrl.forward();
    });
  }

  @override
  void didUpdateWidget(HistoriqueMarketIndicators old) {
    super.didUpdateWidget(old);
    if (old.session.capBoursiere != widget.session.capBoursiere) {
      _capAnim = Tween<double>(
        begin: _capAnim.value,
        end: widget.session.capBoursiere,
      ).animate(CurvedAnimation(parent: _capCtrl, curve: Curves.easeOutCubic));
      _capCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _capCtrl.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'fr_FR');
    final nfDec = NumberFormat('#,##0.00', 'fr_FR');
    final s = widget.session;
    final total = s.nbHausses + s.nbBaisses + s.nbInchangees;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.10),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // ══════════════════════════════════════
            // ── HEADER — Floating orbs gradient ──
            // ══════════════════════════════════════
            SizedBox(
              height: 155,
              child: Stack(
                children: [
                  // Base gradient
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2284E8),
                            Color(0xFF1466C0),
                            Color(0xFF0D4FA8),
                            Color(0xFF0A3B7F),
                          ],
                          stops: [0, 0.3, 0.65, 1],
                        ),
                      ),
                    ),
                  ),

                  // Floating decorative orbs
                  AnimatedBuilder(
                    listenable: _orbCtrl,
                    builder: (context, _) {
                      final t = _orbCtrl.value;
                      return Stack(
                        children: [
                          Positioned(
                            right: -15 + 10 * math.sin(t * 2 * math.pi),
                            top: -10 + 8 * math.cos(t * 2 * math.pi),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.08),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -20 + 8 * math.cos(t * 2 * math.pi + 1.5),
                            bottom: -5 + 6 * math.sin(t * 2 * math.pi + 1.5),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.06),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 50 + 6 * math.sin(t * 2 * math.pi + 3),
                            bottom: 15 + 5 * math.cos(t * 2 * math.pi + 3),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Bottom gradient fade
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0A3B7F).withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Decorative label
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MiniDiamond(color: Colors.white.withValues(alpha: 0.5)),
                              const SizedBox(width: 10),
                              Text(
                                'INDICATEURS DU MARCHÉ',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(width: 10),
                              _MiniDiamond(color: Colors.white.withValues(alpha: 0.5)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Hero Cap Boursière
                          AnimatedBuilder(
                            listenable: _capAnim,
                            builder: (context, _) => Text(
                              _formatMrd(_capAnim.value),
                              style: AppTypography.hero.copyWith(
                                color: Colors.white,
                                fontSize: 30,
                                letterSpacing: -1,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Label pill with icon
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.account_balance_rounded,
                                    size: 12,
                                    color: Colors.white.withValues(alpha: 0.7)),
                                const SizedBox(width: 6),
                                Text(
                                  'Capitalisation Boursière',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ══════════════════════════════════════
            // ── VARIATION CARDS ──
            // ══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 6),
              child: Row(
                children: [
                  _VariationCard(
                    label: 'TUNINDEX',
                    value: s.tunindexChange,
                  ),
                  const SizedBox(width: 10),
                  _VariationCard(
                    label: 'TUNINDEX20',
                    value: s.tunindex20Change,
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.04, end: 0, delay: 200.ms, duration: 400.ms),

            // ══════════════════════════════════════
            // ── STAT MINI-CARDS ──
            // ══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
              child: Column(
                children: [
                  _StatMiniCard(
                    icon: Icons.monetization_on_outlined,
                    label: 'Capitaux échangés',
                    value: '${nfDec.format(s.totalCapitaux / 1e6)} MDT',
                    accentColor: const Color(0xFF2284E8),
                    delay: 0,
                  ),
                  const SizedBox(height: 8),
                  _StatMiniCard(
                    icon: Icons.layers_outlined,
                    label: 'Quantité échangée',
                    value: nf.format(s.totalQuantite),
                    accentColor: AppColors.accentOrange,
                    delay: 1,
                  ),
                  const SizedBox(height: 8),
                  _StatMiniCard(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transactions',
                    value: nf.format(s.totalTransactions),
                    accentColor: const Color(0xFF6C5CE7),
                    delay: 2,
                  ),
                ],
              ),
            ),

            // ══════════════════════════════════════
            // ── RADIAL BADGES — Hausse/Baisse/Inch ──
            // ══════════════════════════════════════
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
              child: Row(
                children: [
                  _RadialBadge(
                    count: s.nbHausses,
                    total: total,
                    label: 'Hausses',
                    color: AppColors.bullGreen,
                    icon: Icons.trending_up_rounded,
                    delay: 0,
                  ),
                  const SizedBox(width: 8),
                  _RadialBadge(
                    count: s.nbBaisses,
                    total: total,
                    label: 'Baisses',
                    color: AppColors.bearRed,
                    icon: Icons.trending_down_rounded,
                    delay: 1,
                  ),
                  const SizedBox(width: 8),
                  _RadialBadge(
                    count: s.nbInchangees,
                    total: total,
                    label: 'Inchangées',
                    color: AppColors.warningYellow,
                    icon: Icons.trending_flat_rounded,
                    delay: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMrd(double v) {
    if (v >= 1e9) return '${(v / 1e9).toStringAsFixed(2)} Mrd DT';
    if (v >= 1e6) return '${(v / 1e6).toStringAsFixed(1)} MDT';
    return '${(v / 1e3).toStringAsFixed(1)} KDT';
  }
}

// ──────────────────────────────────────────────
// Mini diamond decorative widget
// ──────────────────────────────────────────────
class _MiniDiamond extends StatelessWidget {
  final Color color;
  const _MiniDiamond({required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 4,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Variation Card — glass card with colored accent side bar
// ──────────────────────────────────────────────
class _VariationCard extends StatelessWidget {
  final String label;
  final double value;

  const _VariationCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isPos = value >= 0;
    final color = isPos ? AppColors.bullGreen : AppColors.bearRed;

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.10)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Accent side bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, color.withValues(alpha: 0.3)],
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isPos
                                  ? Icons.north_east_rounded
                                  : Icons.south_east_rounded,
                              size: 12,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${isPos ? '+' : ''}${value.toStringAsFixed(2)}%',
                            style: AppTypography.changePercent.copyWith(
                              color: color,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ──────────────────────────────────────────────
// Stat Mini Card — individual elevated card per stat
// ──────────────────────────────────────────────
class _StatMiniCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;
  final int delay;

  const _StatMiniCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          // Icon with gradient background
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withValues(alpha: 0.15),
                  accentColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMediumBold.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (300 + delay * 80).ms, duration: 350.ms)
        .slideX(
            begin: 0.03,
            end: 0,
            delay: (300 + delay * 80).ms,
            duration: 350.ms);
  }
}

// ──────────────────────────────────────────────
// Radial Badge — arc progress around the number
// ──────────────────────────────────────────────
class _RadialBadge extends StatefulWidget {
  final int count;
  final int total;
  final String label;
  final Color color;
  final IconData icon;
  final int delay;

  const _RadialBadge({
    required this.count,
    required this.total,
    required this.label,
    required this.color,
    required this.icon,
    required this.delay,
  });

  @override
  State<_RadialBadge> createState() => _RadialBadgeState();
}

class _RadialBadgeState extends State<_RadialBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _arcAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    final fraction =
        widget.total > 0 ? widget.count / widget.total : 0.0;
    _arcAnim = Tween<double>(begin: 0, end: fraction)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 600 + widget.delay * 120), () {
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.color.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            // Arc ring around number
            SizedBox(
              width: 48,
              height: 48,
              child: AnimatedBuilder(
                listenable: _arcAnim,
                builder: (context, _) => CustomPaint(
                  painter: _ArcPainter(
                    progress: _arcAnim.value,
                    color: widget.color,
                    bgColor: widget.color.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.count}',
                      style: AppTypography.h3.copyWith(
                        color: widget.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Icon + label
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, size: 11, color: widget.color.withValues(alpha: 0.6)),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    widget.label,
                    style: AppTypography.labelSmall.copyWith(
                      color: widget.color.withValues(alpha: 0.75),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;

  _ArcPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background arc
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = bgColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress || old.color != color;
}

/// Reusable AnimatedBuilder for listenable-driven rebuilds
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
