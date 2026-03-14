import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Fond animé avec particules et cercles concentriques
class OnboardingBackground extends StatefulWidget {
  const OnboardingBackground({super.key});

  @override
  State<OnboardingBackground> createState() => _OnboardingBackgroundState();
}

class _OnboardingBackgroundState extends State<OnboardingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _particles = List.generate(20, (_) => _Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _OnboardingBackgroundPainter(
            particles: _particles,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double speed;
  final double opacity;
  final double phase;

  _Particle()
      : x = Random().nextDouble(),
        y = Random().nextDouble(),
        radius = Random().nextDouble() * 2.5 + 1,
        speed = Random().nextDouble() * 0.3 + 0.1,
        opacity = Random().nextDouble() * 0.15 + 0.05,
        phase = Random().nextDouble() * 2 * pi;
}

class _OnboardingBackgroundPainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _OnboardingBackgroundPainter({
    required this.particles,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Gradient de fond profond
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primaryBlue,
        AppColors.deepNavy,
        const Color(0xFF0A1628),
        AppColors.deepNavy.withValues(alpha: 0.95),
      ],
      stops: const [0.0, 0.4, 0.7, 1.0],
    );

    final bgPaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, bgPaint);

    // Cercles concentriques subtils
    final centerX = size.width * 0.5;
    final centerY = size.height * 0.35;
    
    for (int i = 0; i < 4; i++) {
      final radius = 80.0 + (i * 60) + (sin(animationValue * 2 * pi + i) * 10);
      final circlePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.03 - (i * 0.005))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      canvas.drawCircle(Offset(centerX, centerY), radius, circlePaint);
    }

    // Particules flottantes
    for (final particle in particles) {
      final offsetX = particle.x + sin(animationValue * 2 * pi + particle.phase) * 0.02;
      final offsetY = (particle.y + animationValue * particle.speed) % 1.0;
      
      final particlePaint = Paint()
        ..color = Colors.white.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(offsetX * size.width, offsetY * size.height),
        particle.radius,
        particlePaint,
      );
    }

    // Points lumineux subtils
    final glowPaint = Paint()
      ..color = AppColors.primaryBlueLight.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      60 + sin(animationValue * 2 * pi) * 10,
      glowPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.6),
      40 + cos(animationValue * 2 * pi) * 8,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_OnboardingBackgroundPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
