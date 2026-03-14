import 'package:flutter/material.dart';

/// Données d'une slide d'onboarding
class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
