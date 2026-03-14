import 'package:flutter/material.dart';
import 'slide_illustration.dart';

/// Slide d'onboarding avec illustration, titre et description animés
class OnboardingSlide extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final int index;

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.index,
  });

  @override
  State<OnboardingSlide> createState() => _OnboardingSlideState();
}

class _OnboardingSlideState extends State<OnboardingSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _illustrationAnimation;
  late Animation<double> _titleAnimation;
  late Animation<double> _descriptionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _illustrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _titleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _descriptionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    Future.delayed(Duration(milliseconds: 80 + (widget.index * 40)), () {
      if (mounted) _controller.forward();
    });
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Illustration animée
              Transform.scale(
                scale: _illustrationAnimation.value,
                child: Transform.rotate(
                  angle: (1 - _illustrationAnimation.value) * 0.3,
                  child: SlideIllustration(
                    icon: widget.icon,
                    accentColor: widget.accentColor,
                    slideIndex: widget.index,
                  ),
                ),
              ),
              
              const SizedBox(height: 55),
              
              // Titre
              Opacity(
                opacity: _titleAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 25 * (1 - _titleAnimation.value)),
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.25,
                      letterSpacing: 0.8,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          offset: const Offset(0, 2),
                          blurRadius: 10,
                        ),
                        Shadow(
                          color: widget.accentColor.withValues(alpha: 0.4),
                          offset: Offset.zero,
                          blurRadius: 25,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 22),
              
              // Description
              Opacity(
                opacity: _descriptionAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _descriptionAnimation.value)),
                  child: Text(
                    widget.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.6,
                      letterSpacing: 0.4,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Spacer(flex: 3),
            ],
          ),
        );
      },
    );
  }
}
