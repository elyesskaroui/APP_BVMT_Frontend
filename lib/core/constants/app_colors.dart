import 'package:flutter/material.dart';

/// Palette de couleurs BVMT
/// Inspirée du design de la Bourse de Tunis
class AppColors {
  AppColors._();

  // ── Gradient principal (bleu BVMT) ──
  static const Color primaryBlueLight = Color(0xFF1A6BCC);
  static const Color primaryBlue = Color(0xFF0D4FA8);
  static const Color primaryBlueDark = Color(0xFF2A3A52);
  static const Color deepNavy = Color(0xFF1B2A4A);

  // ── Gradient du header ──
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlueLight, primaryBlue, primaryBlueDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlueLight, primaryBlue],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, deepNavy],
  );

  // ── Accent / CTA ──
  static const Color accentOrange = Color(0xFFE8652D);
  static const Color accentOrangeLight = Color(0xFFF0875A);

  // ── Status ──
  static const Color bullGreen = Color(0xFF27AE60);
  static const Color bearRed = Color(0xFFE74C3C);
  static const Color warningYellow = Color(0xFFF39C12);

  // ── Surfaces ──
  static const Color scaffoldBackground = Color(0xFFF5F6FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBackgroundDark = Color(0xFF1E3050);
  static const Color divider = Color(0xFFE0E0E0);

  // ── Texte ──
  static const Color textPrimary = Color(0xFF1B2A4A);
  static const Color textSecondary = Color(0xFF6B7B8D);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnPrimaryMuted = Color(0xB3FFFFFF); // 70% white

  // ── Bottom Navigation ──
  static const Color navBarBackground = Color(0xFF1B2A4A);
  static const Color navBarActive = Color(0xFFFFFFFF);
  static const Color navBarInactive = Color(0xFF8899AA);

  // ══════════════════════════════════════
  // ── Pre-computed alpha colors ──
  // ══════════════════════════════════════
  // Evite les appels withValues() à chaque build
  static const Color primaryBlue10 = Color(0x1A0D4FA8);
  static const Color primaryBlue08 = Color(0x140D4FA8);
  static const Color bullGreen10 = Color(0x1A27AE60);
  static const Color bullGreen20 = Color(0x3327AE60);
  static const Color bearRed10 = Color(0x1AE74C3C);
  static const Color bearRed20 = Color(0x33E74C3C);
  static const Color divider30 = Color(0x4DE0E0E0);
  static const Color divider50 = Color(0x80E0E0E0);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white15 = Color(0x26FFFFFF);
  static const Color white25 = Color(0x40FFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white90 = Color(0xE6FFFFFF);
  static const Color black04 = Color(0x0A000000);
  static const Color black035 = Color(0x09000000);

  // ══════════════════════════════════════
  // ── Dark Mode ──
  // ══════════════════════════════════════
  static const Color darkScaffold = Color(0xFF0F1923);
  static const Color darkCard = Color(0xFF1A2635);
  static const Color darkDivider = Color(0xFF2A3A52);
  static const Color darkTextPrimary = Color(0xFFE8ECF1);
  static const Color darkTextSecondary = Color(0xFF8899AA);
  static const Color darkNavBar = Color(0xFF141E2B);
}
