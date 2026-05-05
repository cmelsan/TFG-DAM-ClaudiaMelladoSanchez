import 'package:flutter/material.dart';

/// Helper de breakpoints responsivos.
///
/// Mobile   < 600 px  → BottomNavigationBar, columna única
/// Tablet   600-1023  → NavigationRail, 2 columnas
/// Desktop  ≥ 1024    → Sidebar 240 px, 4 columnas
abstract final class Responsive {
  static bool isMobile(BuildContext ctx) => MediaQuery.sizeOf(ctx).width < 600;

  static bool isTablet(BuildContext ctx) {
    final w = MediaQuery.sizeOf(ctx).width;
    return w >= 600 && w < 1024;
  }

  static bool isDesktop(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= 1024;

  /// Número de columnas de grid para listado de platos.
  static int dishGridColumns(BuildContext ctx) {
    final w = MediaQuery.sizeOf(ctx).width;
    if (w >= 1024) return 4;
    if (w >= 600) return 3;
    return 2;
  }

  /// Número de columnas para MetricCards del dashboard.
  static int metricColumns(BuildContext ctx) {
    final w = MediaQuery.sizeOf(ctx).width;
    if (w >= 900) return 4;
    if (w >= 600) return 2;
    return 2;
  }
}
