import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Logo BVMT personnalisé dessiné avec CustomPainter
class BvmtLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const BvmtLogo({super.key, this.size = 80, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BvmtLogoPainter(color: color ?? AppColors.primaryBlue),
      ),
    );
  }
}

class _BvmtLogoPainter extends CustomPainter {
  final Color color;

  _BvmtLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Fond circulaire ──
    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w / 2, h / 2), w / 2, bgPaint);

    // ── Ligne de graphique boursier ──
    final chartPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final chartPath = Path();
    final points = [
      Offset(w * 0.18, h * 0.60),
      Offset(w * 0.30, h * 0.50),
      Offset(w * 0.38, h * 0.55),
      Offset(w * 0.48, h * 0.38),
      Offset(w * 0.58, h * 0.42),
      Offset(w * 0.68, h * 0.30),
      Offset(w * 0.82, h * 0.25),
    ];

    chartPath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      chartPath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(chartPath, chartPaint);

    // ── Flèche montante au bout ──
    final arrowPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;

    final tip = points.last;
    final arrowSize = w * 0.08;
    canvas.drawLine(tip, Offset(tip.dx - arrowSize, tip.dy), arrowPaint);
    canvas.drawLine(tip, Offset(tip.dx, tip.dy + arrowSize), arrowPaint);

    // ── Texte "BVMT" ──
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'BVMT',
        style: TextStyle(
          color: Colors.white,
          fontSize: w * 0.16,
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
        h * 0.64,
      ),
    );
  }

  @override
  bool shouldRepaint(_BvmtLogoPainter oldDelegate) => color != oldDelegate.color;
}

/// Logo BVMT animé avec pulsation
class AnimatedBvmtLogo extends StatefulWidget {
  final double size;
  final Color? color;

  const AnimatedBvmtLogo({super.key, this.size = 80, this.color});

  @override
  State<AnimatedBvmtLogo> createState() => _AnimatedBvmtLogoState();
}

class _AnimatedBvmtLogoState extends State<AnimatedBvmtLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: BvmtLogo(size: widget.size, color: widget.color),
    );
  }
}
