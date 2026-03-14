import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Logo BVMT animé avec effet de scale, opacité et checkmark
class AnimatedLogo extends StatefulWidget {
  final bool show;
  final bool showCheckmark;
  final double size;

  const AnimatedLogo({
    super.key,
    required this.show,
    this.showCheckmark = false,
    this.size = 120,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkmarkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _checkmarkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeIn),
    );

    _checkmarkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkmarkController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _scaleController.forward();
    }
    if (widget.showCheckmark && !oldWidget.showCheckmark) {
      _checkmarkController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleController, _checkmarkController]),
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cercle de fond avec glow
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlueLight.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                // Logo CustomPaint
                CustomPaint(
                  size: Size(widget.size * 0.7, widget.size * 0.7),
                  painter: _BvmtLogoPainter(
                    checkmarkProgress: _checkmarkAnimation.value,
                    showCheckmark: widget.showCheckmark,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BvmtLogoPainter extends CustomPainter {
  final double checkmarkProgress;
  final bool showCheckmark;

  _BvmtLogoPainter({
    required this.checkmarkProgress,
    required this.showCheckmark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Ligne de graphique boursier ──
    final chartPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final points = [
      Offset(w * 0.08, h * 0.55),
      Offset(w * 0.22, h * 0.45),
      Offset(w * 0.32, h * 0.50),
      Offset(w * 0.45, h * 0.30),
      Offset(w * 0.58, h * 0.35),
      Offset(w * 0.72, h * 0.20),
      Offset(w * 0.92, h * 0.15),
    ];

    final chartPath = Path();
    chartPath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      chartPath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(chartPath, chartPaint);

    // ── Flèche montante ──
    final tip = points.last;
    final arrowSize = w * 0.1;
    canvas.drawLine(
      tip,
      Offset(tip.dx - arrowSize, tip.dy),
      chartPaint,
    );
    canvas.drawLine(
      tip,
      Offset(tip.dx, tip.dy + arrowSize),
      chartPaint,
    );

    // ── Texte "BVMT" ──
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'BVMT',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.22,
          fontWeight: FontWeight.w900,
          letterSpacing: w * 0.02,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        (w - textPainter.width) / 2,
        h * 0.60,
      ),
    );

    // ── Checkmark animé ──
    if (showCheckmark && checkmarkProgress > 0) {
      final checkPaint = Paint()
        ..color = AppColors.bullGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.06
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final checkPath = Path();
      final startX = w * 0.35;
      final startY = h * 0.88;
      final midX = w * 0.48;
      final midY = h * 0.98;
      final endX = w * 0.70;
      final endY = h * 0.78;

      if (checkmarkProgress <= 0.5) {
        final progress = checkmarkProgress * 2;
        checkPath.moveTo(startX, startY);
        checkPath.lineTo(
          startX + (midX - startX) * progress,
          startY + (midY - startY) * progress,
        );
      } else {
        final progress = (checkmarkProgress - 0.5) * 2;
        checkPath.moveTo(startX, startY);
        checkPath.lineTo(midX, midY);
        checkPath.lineTo(
          midX + (endX - midX) * progress,
          midY + (endY - midY) * progress,
        );
      }
      canvas.drawPath(checkPath, checkPaint);
    }
  }

  @override
  bool shouldRepaint(_BvmtLogoPainter oldDelegate) =>
      oldDelegate.checkmarkProgress != checkmarkProgress ||
      oldDelegate.showCheckmark != showCheckmark;
}
