import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';

// ── Modelo de ítem ────────────────────────────────────────────────────────────

class _SidebarItem {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    this.section,
  });
  final IconData icon;
  final String label;
  final String route;
  final String? section; // label del grupo (primer ítem del grupo lo lleva)
}

// ── Ítems de navegación ───────────────────────────────────────────────────────

const _kItems = [
  _SidebarItem(
    icon: Icons.dashboard_rounded,
    label: 'Dashboard',
    route: '/admin',
    section: 'GENERAL',
  ),
  _SidebarItem(
    icon: Icons.bar_chart_rounded,
    label: 'Estadísticas',
    route: '/admin/stats',
  ),
  _SidebarItem(
    icon: Icons.receipt_long_rounded,
    label: 'Pedidos',
    route: '/admin/orders',
    section: 'GESTIÓN',
  ),
  _SidebarItem(
    icon: Icons.assignment_rounded,
    label: 'Encargos',
    route: '/admin/encargos',
  ),
  _SidebarItem(
    icon: Icons.restaurant_menu_rounded,
    label: 'Platos',
    route: '/admin/dishes',
    section: 'CATÁLOGO',
  ),
  _SidebarItem(
    icon: Icons.category_rounded,
    label: 'Categorías',
    route: '/admin/categories',
  ),
  _SidebarItem(
    icon: Icons.today_rounded,
    label: 'Menú del día',
    route: '/admin/daily-special',
  ),
  _SidebarItem(
    icon: Icons.people_rounded,
    label: 'Usuarios',
    route: '/admin/users',
    section: 'CLIENTES',
  ),
  _SidebarItem(
    icon: Icons.celebration_rounded,
    label: 'Catering',
    route: '/admin/catering',
    section: 'SERVICIO',
  ),
  _SidebarItem(
    icon: Icons.schedule_rounded,
    label: 'Horario',
    route: '/admin/schedule',
  ),
  _SidebarItem(
    icon: Icons.settings_rounded,
    label: 'Configuración',
    route: '/admin/config',
    section: 'SISTEMA',
  ),
];

// ── Widget principal ──────────────────────────────────────────────────────────

/// Sidebar fijo 260 px para la vista de escritorio/tablet del panel de admin.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  // Colores internos del sidebar
  static const _bg = Color(0xFF12131A);
  static const _border = Color(0xFF252634);
  static const _textMuted = Color(0xFF606272);
  static const _textNormal = Color(0xFFAAABBF);

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 260,
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ───────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTokens.brandPrimary, AppTokens.brandDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SABOR DE CASA',
                      style: GoogleFonts.syne(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTokens.brandPrimary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'PANEL ADMIN',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppTokens.brandPrimary,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(height: 1, color: _border),
          const SizedBox(height: 8),

          // ── Ítems de nav ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              itemCount: _kItems.length,
              itemBuilder: (context, i) {
                final item = _kItems[i];
                final isActive = currentRoute.startsWith(item.route) &&
                    (item.route != '/admin' || currentRoute == '/admin');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.section != null) ...[
                      if (i != 0) const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 4, 0, 6),
                        child: Text(
                          item.section!,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _textMuted,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                    _NavTile(
                      item: item,
                      isActive: isActive,
                      onTap: () => context.go(item.route),
                      textNormal: _textNormal,
                    ),
                  ],
                );
              },
            ),
          ),

          // ── Footer: logout ─────────────────────────────────────────────
          Container(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            child: _NavTile(
              item: const _SidebarItem(
                icon: Icons.logout_rounded,
                label: 'Cerrar sesión',
                route: '',
              ),
              isActive: false,
              onTap: () => context.go('/login'),
              danger: true,
              textNormal: _textNormal,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ítem de nav ───────────────────────────────────────────────────────────────

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.isActive,
    required this.onTap,
    required this.textNormal,
    this.danger = false,
  });

  final _SidebarItem item;
  final bool isActive;
  final VoidCallback onTap;
  final Color textNormal;
  final bool danger;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color fg;
    if (widget.danger) {
      fg = _hovered ? AppTokens.danger : AppTokens.danger.withValues(alpha: 0.7);
    } else if (widget.isActive) {
      fg = Colors.white;
    } else {
      fg = _hovered ? Colors.white : widget.textNormal;
    }

    final Color bg;
    if (widget.isActive) {
      bg = AppTokens.brandPrimary.withValues(alpha: 0.15);
    } else if (_hovered && !widget.danger) {
      bg = Colors.white.withValues(alpha: 0.04);
    } else if (_hovered && widget.danger) {
      bg = AppTokens.danger.withValues(alpha: 0.07);
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            border: widget.isActive
                ? const Border(
                    left: BorderSide(color: AppTokens.brandPrimary, width: 3),
                  )
                : Border.all(color: Colors.transparent, width: 3),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 17,
                color: widget.isActive
                    ? AppTokens.brandPrimary
                    : widget.danger
                        ? fg
                        : _hovered ? Colors.white : widget.textNormal,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: fg,
                  ),
                ),
              ),
              if (widget.isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTokens.brandPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
