import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Widget réutilisable — État vide élégant avec illustration, message et CTA
/// Conforme WCAG : taille texte ≥ 14px, zone tactile ≥ 48dp
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. ${subtitle ?? ''}',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône dans un cercle
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue10,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),

            // Titre
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            // Sous-titre optionnel
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],

            // Bouton d'action optionnel
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 48, // min touch target
                child: TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.primaryBlue10),
                    ),
                  ),
                  child: Text(actionText!, style: AppTypography.button),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
