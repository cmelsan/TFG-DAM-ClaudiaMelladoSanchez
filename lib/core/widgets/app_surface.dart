import 'package:flutter/material.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

/// Card base de Sabor de Casa.
///
/// Reemplaza [Card] en toda la app. Sin elevación nativa de Material —
/// usa [BoxShadow] muy suave + borde 0.5 px para profundidad sutil.
///
/// ```dart
/// AppSurface(
///   padding: const EdgeInsets.all(16),
///   child: Text('Hola'),
/// )
/// ```
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    this.padding,
    this.borderColor,
    this.borderWidth = 0.5,
    this.radius,
    this.shadow = true,
    this.color,
    this.child,
  });

  final EdgeInsetsGeometry? padding;

  /// Sobreescribe el color de borde (por defecto Color(0xFFE5E5E3)).
  final Color? borderColor;
  final double borderWidth;

  /// Sobreescribe el radio (por defecto [AppTokens.radiusMd]).
  final double? radius;

  /// Si `false`, omite el [BoxShadow].
  final bool shadow;

  /// Color de fondo (por defecto blanco en light, [Color(0xFF1E1E1E)] en dark).
  final Color? color;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = color ?? (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final border =
        borderColor ??
        (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E5E3));
    final r = radius ?? AppTokens.radiusMd;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: border, width: borderWidth),
        boxShadow: shadow ? [AppTokens.cardShadow] : null,
      ),
      padding: padding,
      child: child,
    );
  }
}
