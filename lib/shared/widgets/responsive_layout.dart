import 'package:flutter/material.dart';

/// Helper responsive — Breakpoints et utilitaires pour layout adaptatif
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Breakpoints conformes Material Design 3
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 840;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileBreakpoint && w < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  /// Nombre de colonnes adaptatif pour les grilles
  static int gridColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktopBreakpoint) return 4;
    if (w >= tabletBreakpoint) return 3;
    if (w >= mobileBreakpoint) return 2;
    return 2;
  }

  /// Padding horizontal adaptatif
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktopBreakpoint) return 48;
    if (w >= tabletBreakpoint) return 32;
    if (w >= mobileBreakpoint) return 24;
    return 16;
  }

  /// Largeur maximale du contenu (centré sur grands écrans)
  static double maxContentWidth(BuildContext context) {
    if (isDesktop(context)) return 1080;
    if (isTablet(context)) return 720;
    return double.infinity;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;

    if (w >= desktopBreakpoint && desktop != null) return desktop!;
    if (w >= mobileBreakpoint && tablet != null) return tablet!;
    return mobile;
  }
}

/// Wrapper qui centre le contenu avec une largeur maximale sur grands écrans
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsiveCenter({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? ResponsiveLayout.maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}
