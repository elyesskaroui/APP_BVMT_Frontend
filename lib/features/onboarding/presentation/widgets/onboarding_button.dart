import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Bouton animé pour l'onboarding (Next / Get Started)
class OnboardingButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;

  const OnboardingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  State<OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<OnboardingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: widget.isPrimary
                    ? const LinearGradient(
                        colors: [
                          AppColors.accentOrange,
                          AppColors.accentOrangeLight,
                        ],
                      )
                    : null,
                color: widget.isPrimary ? null : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: widget.isPrimary
                        ? AppColors.accentOrange.withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: 0.15),
                    blurRadius: _isPressed ? 8 : 16,
                    spreadRadius: _isPressed ? 0 : 2,
                    offset: Offset(0, _isPressed ? 4 : 8),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: widget.isPrimary
                        ? Colors.white
                        : AppColors.primaryBlue,
                  ),
                  child: Text(widget.text),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
