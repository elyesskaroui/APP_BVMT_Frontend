import 'package:flutter/material.dart';

/// Points d'arrêt responsifs pour l'application BVMT
class Breakpoints {
  Breakpoints._();

  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Type d'appareil détecté
enum DeviceType { mobile, tablet, desktop }

/// Utilitaire responsive — détecte le type d'appareil et orientation
class Responsive {
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= Breakpoints.desktop) return DeviceType.desktop;
    if (width >= Breakpoints.tablet) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  /// Nombre de colonnes pour une grille responsive
  static int gridColumns(BuildContext context) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.desktop:
        return 4;
      case DeviceType.tablet:
        return isLandscape(context) ? 3 : 2;
      case DeviceType.mobile:
        return isLandscape(context) ? 2 : 1;
    }
  }

  /// Padding horizontal adaptatif
  static double horizontalPadding(BuildContext context) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.desktop:
        return 48.0;
      case DeviceType.tablet:
        return 32.0;
      case DeviceType.mobile:
        return 16.0;
    }
  }

  /// Facteur d'échelle de la police
  static double fontScale(BuildContext context) {
    final type = getDeviceType(context);
    switch (type) {
      case DeviceType.desktop:
        return 1.2;
      case DeviceType.tablet:
        return 1.1;
      case DeviceType.mobile:
        return 1.0;
    }
  }
}

/// Widget utilitaire pour construire des layouts selon l'appareil
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, Responsive.getDeviceType(context));
      },
    );
  }
}

/// Widget qui affiche différents enfants selon le device
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

  @override
  Widget build(BuildContext context) {
    final type = Responsive.getDeviceType(context);
    switch (type) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }
}

/// Extension pour accéder facilement aux infos responsive depuis le context
extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => Responsive.getDeviceType(this);
  bool get isMobile => Responsive.isMobile(this);
  bool get isTablet => Responsive.isTablet(this);
  bool get isDesktop => Responsive.isDesktop(this);
  bool get isLandscape => Responsive.isLandscape(this);
  int get gridColumns => Responsive.gridColumns(this);
  double get responsivePadding => Responsive.horizontalPadding(this);
}
