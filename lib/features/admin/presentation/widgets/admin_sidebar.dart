import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/widgets/app_logo_text.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart'
    show AdminShell;

/// Entrada del menú lateral de admin.
class _SidebarItem {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;
}

const _kItems = [
  _SidebarItem(
    icon: Icons.dashboard_outlined,
    label: 'Dashboard',
    route: '/admin',
  ),
  _SidebarItem(
    icon: Icons.bar_chart_rounded,
    label: 'Estadísticas',
    route: '/admin/stats',
  ),
  _SidebarItem(
    icon: Icons.receipt_long_outlined,
    label: 'Pedidos',
    route: '/admin/orders',
  ),
  _SidebarItem(
    icon: Icons.restaurant_menu,
    label: 'Platos',
    route: '/admin/dishes',
  ),
  _SidebarItem(
    icon: Icons.category_outlined,
    label: 'Categorías',
    route: '/admin/categories',
  ),
  _SidebarItem(
    icon: Icons.people_outline,
    label: 'Usuarios',
    route: '/admin/users',
  ),
  _SidebarItem(
    icon: Icons.celebration_outlined,
    label: 'Catering',
    route: '/admin/catering',
  ),
  _SidebarItem(
    icon: Icons.assignment_outlined,
    label: 'Encargos',
    route: '/admin/encargos',
  ),
  _SidebarItem(
    icon: Icons.schedule_outlined,
    label: 'Horario',
    route: '/admin/schedule',
  ),
  _SidebarItem(
    icon: Icons.settings_outlined,
    label: 'Configuración',
    route: '/admin/config',
  ),
];

/// Sidebar fijo 240 px para la vista de escritorio/tablet del panel de admin.
///
/// Se usa dentro de [AdminShell]. No contiene estado propio — se reconstruye
/// cuando cambia la ruta activa.
class AdminSidebar extends StatelessWidget {
  const AdminSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Container(
      width: 240,
      color: AppTokens.surfaceDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo / título ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppLogoText(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Panel Admin',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF888886),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Separador ─────────────────────────────────────────────────
          Container(height: 0.5, color: const Color(0xFF2A2A2A)),
          const SizedBox(height: 8),

          // ── Ítems de navegación ────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              itemCount: _kItems.length,
              itemBuilder: (context, i) {
                final item = _kItems[i];
                final isActive =
                    currentRoute.startsWith(item.route) &&
                    (!(item.route == '/admin') || currentRoute == '/admin');
                return _SidebarTile(
                  item: item,
                  isActive: isActive,
                  onTap: () => context.go(item.route),
                );
              },
            ),
          ),

          // ── Footer ────────────────────────────────────────────────────
          Container(height: 0.5, color: const Color(0xFF2A2A2A)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: _SidebarTile(
              item: const _SidebarItem(
                icon: Icons.logout_rounded,
                label: 'Cerrar sesión',
                route: '/logout',
              ),
              isActive: false,
              onTap: () => context.go('/login'),
              danger: true,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarTile extends StatelessWidget {
  const _SidebarTile({
    required this.item,
    required this.isActive,
    required this.onTap,
    this.danger = false,
  });

  final _SidebarItem item;
  final bool isActive;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final fg = danger
        ? AppTokens.danger
        : isActive
        ? Colors.white
        : const Color(0xFF9A9A98);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: Colors.white.withValues(alpha: 0.05),
        highlightColor: Colors.white.withValues(alpha: 0.03),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? const Border(
                    left: BorderSide(color: AppTokens.brandPrimary, width: 3),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: fg),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
