import 'package:flutter/material.dart';

/// Ombres centralisées — Design system BVMT
/// Evite la duplication de BoxShadow dans les widgets
class AppShadows {
  AppShadows._();

  /// Ombre légère — Cartes de surface (stat cards, index cards)
  static final List<BoxShadow> cardLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Ombre standard — Cartes principales (favoris, top movers)
  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// Ombre élevée — Cartes premium (portefeuille, header)
  static final List<BoxShadow> cardElevated = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  /// Ombre colorée bleue — Éléments sur fond primaire (portfolio card)
  static final List<BoxShadow> primaryElevated = [
    BoxShadow(
      color: const Color(0xFF0D4FA8).withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
  ];

  /// Ombre pour le bottom nav bar
  static final List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 20,
      offset: const Offset(0, -4),
    ),
  ];

  /// Ombre subtile — Séparateurs, éléments discrets
  static final List<BoxShadow> subtle = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
}
