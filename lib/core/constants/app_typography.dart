import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Système typographique centralisé BVMT
/// Toutes les tailles respectent le minimum 12px pour les labels, 14px pour le corps
class AppTypography {
  AppTypography._();

  // ══════════════════════════════════════
  // ── Headlines ──
  // ══════════════════════════════════════

  /// 28px — Hero (montant portefeuille, statistique principale)
  static TextStyle get hero => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// 24px — Page titles
  static TextStyle get h1 => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 20px — Section titles
  static TextStyle get h2 => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 18px — Section headers
  static TextStyle get h3 => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ══════════════════════════════════════
  // ── Titles ──
  // ══════════════════════════════════════

  /// 16px bold — Card titles, sub-headers
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 15px semibold — Carousel / section sub-titles
  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// 14px semibold — List item titles
  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ══════════════════════════════════════
  // ── Body ──
  // ══════════════════════════════════════

  /// 16px regular — Primary body text
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// 14px regular — Standard body text (minimum for readability)
  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  /// 14px medium — Emphasized body text
  static TextStyle get bodyMediumBold => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // ══════════════════════════════════════
  // ── Labels & Captions ──
  // ══════════════════════════════════════

  /// 13px semibold — Badge labels, small buttons
  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 12px medium — Metadata, timestamps, secondary info
  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  /// 11px semibold — Tiny labels (tab badges, category tags)
  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // ══════════════════════════════════════
  // ── Financial Numbers ──
  // ══════════════════════════════════════

  /// 22px — Index values (TUNINDEX, main numbers)
  static TextStyle get indexValue => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  /// 16px — Stock price
  static TextStyle get stockPrice => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  /// 14px bold — Percentage change
  static TextStyle get changePercent => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  /// 13px bold — Small percentage / metric values
  static TextStyle get changePercentSmall => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // ══════════════════════════════════════
  // ── On Primary (white text on blue) ──
  // ══════════════════════════════════════

  /// 18px bold — Header title on blue background
  static TextStyle get onPrimaryTitle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnPrimary,
    letterSpacing: 1.5,
    height: 1.2,
  );

  /// 14px — Body text on primary background
  static TextStyle get onPrimaryBody => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnPrimary,
    height: 1.4,
  );

  /// 12px — Muted text on primary background
  static TextStyle get onPrimaryMuted => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnPrimaryMuted,
    height: 1.3,
  );

  // ══════════════════════════════════════
  // ── Ticker ──
  // ══════════════════════════════════════

  /// 14px bold — Ticker symbol
  static TextStyle get tickerSymbol => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textOnPrimary,
    height: 1.3,
  );

  /// 14px regular — Ticker price
  static TextStyle get tickerPrice => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnPrimary,
    height: 1.3,
  );

  // ══════════════════════════════════════
  // ── Button ──
  // ══════════════════════════════════════

  /// 14px semibold — Button text
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  /// 13px semibold — Small action text ("Voir tout")
  static TextStyle get actionLink => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.accentOrange,
    height: 1.3,
  );
}
