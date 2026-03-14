import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Illustration animée d'une slide avec cercle blanc et icône
class SlideIllustration extends StatefulWidget {
  final IconData icon;
  final Color accentColor;
  final int slideIndex;

  const SlideIllustration({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.slideIndex,
  });

  @override
  State<SlideIllustration> createState() => _SlideIllustrationState();
}

class _SlideIllustrationState extends State<SlideIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cercles pulsants en arrière-plan
            ...List.generate(3, (i) {
              final scale = 1.0 + (i * 0.25) + (_pulseController.value * 0.15);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 160 + (i * 35),
                  height: 160 + (i * 35),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08 - (i * 0.02)),
                      width: 1.5,
                    ),
                  ),
                ),
              );
            }),
            
            // Cercle blanc principal avec ombre
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withValues(alpha: 0.97),
                    Colors.white.withValues(alpha: 0.94),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  // Ombre principale
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30 + (_pulseController.value * 8),
                    spreadRadius: 2,
                    offset: const Offset(0, 12),
                  ),
                  // Glow de couleur
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.35 + (_pulseController.value * 0.15)),
                    blurRadius: 45,
                    spreadRadius: -5,
                  ),
                  // Halo externe
                  BoxShadow(
                    color: AppColors.primaryBlueLight.withValues(alpha: 0.2),
                    blurRadius: 60 + (_pulseController.value * 15),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: _buildIllustrationContent(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildIllustrationContent() {
    switch (widget.slideIndex) {
      case 0:
        return _buildChartAnimation();
      case 1:
        return _buildWalletAnimation();
      case 2:
        return _buildNotificationAnimation();
      default:
        return _buildDefaultIcon();
    }
  }

  // Slide 0: Graphique boursier animé
  Widget _buildChartAnimation() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Icône principale avec rotation légère
            Transform.rotate(
              angle: -0.05 + (_pulseController.value * 0.1),
              child: Icon(
                widget.icon,
                size: 75,
                color: widget.accentColor,
              ),
            ),
            // Point de progression animé
            if (_pulseController.value > 0.3)
              Positioned(
                top: 35,
                right: 38,
                child: Transform.scale(
                  scale: (_pulseController.value - 0.3) * 1.4,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bullGreen,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.bullGreen.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Slide 1: Portefeuille animé
  Widget _buildWalletAnimation() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              widget.icon,
              size: 75,
              color: widget.accentColor,
            ),
            // Pièces animées
            ...List.generate(3, (i) {
              final delay = i * 0.2;
              final progress = ((_pulseController.value + delay) % 1.0);
              return Positioned(
                top: 30 + (progress * 15),
                right: 35 + (i * 12),
                child: Opacity(
                  opacity: (1 - progress).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.6 + (progress * 0.4),
                    child: Icon(
                      Icons.monetization_on,
                      size: 16 - (i * 2),
                      color: AppColors.accentOrange.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // Slide 2: Notification animée
  Widget _buildNotificationAnimation() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cloche qui oscille
            Transform.rotate(
              angle: sin(_pulseController.value * pi * 4) * 0.08,
              child: Icon(
                widget.icon,
                size: 75,
                color: widget.accentColor,
              ),
            ),
            // Badge de notification
            Positioned(
              top: 32,
              right: 42,
              child: Transform.scale(
                scale: 0.8 + (_pulseController.value * 0.3),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.bearRed,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.bearRed.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Ondes de notification
            if (_pulseController.value > 0.5)
              ...List.generate(2, (i) {
                final progress = ((_pulseController.value - 0.5) * 2 + (i * 0.3)) % 1.0;
                return Positioned(
                  top: 25,
                  right: 35,
                  child: Opacity(
                    opacity: (1 - progress) * 0.5,
                    child: Container(
                      width: 30 + (progress * 20),
                      height: 30 + (progress * 20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.bearRed.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildDefaultIcon() {
    return Icon(
      widget.icon,
      size: 75,
      color: widget.accentColor,
    );
  }
}
