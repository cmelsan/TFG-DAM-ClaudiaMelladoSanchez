import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/auth/presentation/providers/auth_provider.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';

/// Barra de navegación web compartida por todas las páginas públicas.
///
/// Parámetros:
/// - [isScrolled]: controla la opacidad/sombra animada.
/// - [activeRoute]: constante [RouteNames] de la página actual (resalta el enlace activo).
/// - [onCartTap]: acción del icono del carrito. Por defecto navega a `/cart`.
/// - [trailingActions]: widgets adicionales insertados antes del icono del carrito
///   (p. ej., botón de filtro de alérgenos en la página de menú).
class WebNavbar extends ConsumerWidget {
  const WebNavbar({
    required this.isScrolled,
    this.activeRoute,
    this.onCartTap,
    this.trailingActions = const [],
    super.key,
  });

  final bool isScrolled;
  final String? activeRoute;
  final VoidCallback? onCartTap;
  final List<Widget> trailingActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartItemsCountProvider);
    final authState = ref.watch(authNotifierProvider);
    final profile = authState.valueOrNull;
    final screenW = MediaQuery.sizeOf(context).width;
    final hPad = screenW < 500 ? 16.0 : 40.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isScrolled ? navBg.withValues(alpha: 0.92) : navBg,
            border: const Border(
              top: BorderSide(color: AppTokens.brandPrimary, width: 4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isScrolled ? 0.12 : 0.07,
                ),
                blurRadius: isScrolled ? 24 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: SizedBox(
                height: 80,
                child: Row(
                  children: [
                    // ── Logo ──────────────────────────────────────────
                    Flexible(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => context.goNamed(RouteNames.home),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Sabor de Casa',
                                  style: GoogleFonts.syne(
                                    fontWeight: FontWeight.w800,
                                    fontStyle: FontStyle.italic,
                                    fontSize: 28,
                                    letterSpacing: 0,
                                    height: 1,
                                    color: AppTokens.brandPrimary,
                                  ),
                                ),
                              ),
                              if (screenW >= 380) ...[
                                const SizedBox(height: 3),
                                Text(
                                  'Sanlúcar de Barrameda',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.8,
                                    color: const Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ── Nav links (solo en pantallas anchas) ──────────
                    if (screenW >= 700) ...[
                      WebNavLink(
                        label: 'Inicio',
                        isActive: activeRoute == RouteNames.home,
                        onTap: () => context.goNamed(RouteNames.home),
                      ),
                      const SizedBox(width: 4),
                      WebNavLink(
                        label: 'Menú',
                        isActive: activeRoute == RouteNames.menu,
                        onTap: () => context.goNamed(RouteNames.menu),
                      ),
                      const SizedBox(width: 4),
                      WebNavLink(
                        label: 'Catering',
                        isActive: activeRoute == RouteNames.catering,
                        onTap: () => context.goNamed(RouteNames.catering),
                      ),
                      const SizedBox(width: 4),
                      WebNavLink(
                        label: 'Contacto',
                        isActive: activeRoute == RouteNames.contact,
                        onTap: () => context.goNamed(RouteNames.contact),
                      ),
                      const SizedBox(width: 12),
                    ],

                    // ── Acciones extra (opcionales) ───────────────────
                    ...trailingActions,
                    if (trailingActions.isNotEmpty) const SizedBox(width: 4),

                    // ── Carrito ───────────────────────────────────────
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: onCartTap ??
                            () => context.pushNamed(RouteNames.cart),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTokens.brandPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                              if (cartCount > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '$cartCount',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // ── Auth ──────────────────────────────────────────
                    if (profile == null && screenW >= 700) ...[
                      OutlinedButton(
                        onPressed: () => context.goNamed(RouteNames.login),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTokens.brandPrimary,
                          side: const BorderSide(color: AppTokens.brandPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          textStyle: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Iniciar sesión'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () => context.goNamed(RouteNames.register),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTokens.brandPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          textStyle: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Registrarse'),
                      ),
                    ] else if (profile != null)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => context.goNamed(RouteNames.profile),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppTokens.brandPrimary
                                    .withValues(alpha: 0.15),
                                child: const Icon(
                                  Icons.person,
                                  color: AppTokens.brandPrimary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                profile.fullName?.split(' ').first ??
                                    profile.email.split('@').first,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Enlace de navegación con indicador de página activa y efecto hover.
class WebNavLink extends StatefulWidget {
  const WebNavLink({
    required this.label,
    required this.onTap,
    this.isActive = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  State<WebNavLink> createState() => _WebNavLinkState();
}

class _WebNavLinkState extends State<WebNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final highlight = _hovered || widget.isActive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor =
        isDark ? const Color(0xFFD0D0D0) : const Color(0xFF222222);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight:
                      highlight ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: 0.4,
                  color: highlight ? AppTokens.brandPrimary : inactiveColor,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2.5,
                width: highlight ? 20 : 0,
                decoration: BoxDecoration(
                  color: AppTokens.brandPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
