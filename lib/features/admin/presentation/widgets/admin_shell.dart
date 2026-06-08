import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/layout/responsive.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_sidebar.dart';

void _goBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.goNamed(RouteNames.profile);
}

/// Shell responsivo para el panel de administración.
class AdminShell extends StatelessWidget {
  const AdminShell({
    required this.child,
    super.key,
    this.title,
    this.floatingActionButton,
    this.actions,
  });

  final Widget child;
  final String? title;
  final Widget? floatingActionButton;
  /// Botones de acción opcionales que aparecen en la cabecera de contenido.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    if (Responsive.isMobile(context)) {
      return _MobileAdminShell(
        title: title,
        floatingActionButton: floatingActionButton,
        actions: actions,
        child: child,
      );
    }
    return _DesktopAdminShell(
      title: title,
      floatingActionButton: floatingActionButton,
      actions: actions,
      child: child,
    );
  }
}

// ─── DESKTOP / TABLET ────────────────────────────────────────────────────────

class _DesktopAdminShell extends StatelessWidget {
  const _DesktopAdminShell({
    required this.child,
    this.title,
    this.floatingActionButton,
    this.actions,
  });
  final Widget child;
  final String? title;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: floatingActionButton,
      body: Row(
        children: [
          const AdminSidebar(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (title != null) _ContentHeader(title: title!, actions: actions),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MOBILE ──────────────────────────────────────────────────────────────────

class _MobileAdminShell extends StatelessWidget {
  const _MobileAdminShell({
    required this.child,
    this.title,
    this.floatingActionButton,
    this.actions,
  });
  final Widget child;
  final String? title;
  final Widget? floatingActionButton;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title ?? 'Admin',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A2E)),
          tooltip: 'Volver',
          onPressed: () => _goBack(context),
        ),
        actions: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF1A1A2E)),
              tooltip: 'Menú',
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          if (actions != null) ...actions!,
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      drawer: const Drawer(
        backgroundColor: Colors.white,
        width: 260,
        child: AdminSidebar(),
      ),
      body: child,
    );
  }
}

// ─── Cabecera de contenido (desktop) ─────────────────────────────────────────

class _ContentHeader extends StatelessWidget {
  const _ContentHeader({required this.title, this.actions});
  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _goBack(context),
            tooltip: 'Volver',
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

// ─── Helpers reutilizables ────────────────────────────────────────────────────

/// Cabecera de sección dentro del contenido (h2 estilo).
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        letterSpacing: 1.2,
        color: const Color(0xFF9CA3AF),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

/// Tarjeta de métrica para el dashboard.
class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    super.key,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF8A8FA8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1A2E),
                        height: 1,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF8A8FA8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.6,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de resumen oscura (usada en stats).
class DarkSummaryBar extends StatelessWidget {
  const DarkSummaryBar({required this.items, super.key});
  final List<MetricItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.1),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[i].label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i].value,
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: items[i].valueColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MetricItem {
  const MetricItem({
    required this.label,
    required this.value,
    this.valueColor,
  });
  final String label;
  final String value;
  final Color? valueColor;
}
