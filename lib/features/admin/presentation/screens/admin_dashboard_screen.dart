import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PANTALLA PRINCIPAL DEL PANEL DE ADMINISTRACIÓN
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return AdminShell(
      // Sin título: el dashboard tiene su propio hero banner como cabecera
      child: statsAsync.when(
        data: (stats) => _DashboardBody(
          stats: stats,
          onRefresh: () => ref.invalidate(adminDashboardStatsProvider),
        ),
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(adminDashboardStatsProvider),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUERPO PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats, required this.onRefresh});
  final Map<String, dynamic> stats;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final revenue = (stats['revenue_total'] as num? ?? 0).toDouble();
    final ordersTotal = (stats['orders_total'] as num?)?.toInt() ?? 0;
    final ordersPending = (stats['orders_pending'] as num?)?.toInt() ?? 0;
    final usersTotal = (stats['users_total'] as num?)?.toInt() ?? 0;
    final contactsUnread = (stats['contacts_unread'] as num?)?.toInt() ?? 0;
    final eventsTotal = (stats['events_total'] as num?)?.toInt() ?? 0;

    final kpis = [
      _KpiData(
        label: 'Ingresos hoy',
        value: Formatters.price(revenue),
        icon: Icons.payments_rounded,
        color: AppTokens.brandPrimary,
        subtitle: 'Ventas del día',
      ),
      _KpiData(
        label: 'Pedidos totales',
        value: '$ordersTotal',
        icon: Icons.receipt_long_rounded,
        color: AppTokens.info,
        subtitle: 'Registrados hoy',
      ),
      _KpiData(
        label: 'Pendientes',
        value: '$ordersPending',
        icon: Icons.pending_actions_rounded,
        color: ordersPending > 0 ? AppTokens.warning : AppTokens.brandPrimary,
        subtitle: ordersPending > 0 ? 'Requieren atención' : 'Al día ✓',
      ),
      _KpiData(
        label: 'Usuarios',
        value: '$usersTotal',
        icon: Icons.people_rounded,
        color: AppTokens.brandDark,
        subtitle: 'Clientes registrados',
      ),
      _KpiData(
        label: 'Mensajes sin leer',
        value: '$contactsUnread',
        icon: Icons.mark_email_unread_rounded,
        color: contactsUnread > 0 ? AppTokens.danger : const Color(0xFF6B7280),
        subtitle: contactsUnread > 0 ? 'Respuesta pendiente' : 'Sin mensajes nuevos',
      ),
      _KpiData(
        label: 'Eventos catering',
        value: '$eventsTotal',
        icon: Icons.celebration_rounded,
        color: const Color(0xFF7C3AED),
        subtitle: 'Solicitudes activas',
      ),
    ];

    return ColoredBox(
      color: const Color(0xFFF4F6F8),
      child: CustomScrollView(
        slivers: [
          // ── Hero banner con gradiente verde ─────────────────────────
          SliverToBoxAdapter(
            child: _HeroBanner(
              onRefresh: onRefresh,
              ordersPending: ordersPending,
              contactsUnread: contactsUnread,
            ).animate().fadeIn(duration: 350.ms),
          ),

          // ── Alertas urgentes (solo si hay pendientes) ────────────────
          if (ordersPending > 0 || contactsUnread > 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _AlertsRow(
                  ordersPending: ordersPending,
                  contactsUnread: contactsUnread,
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
              ),
            ),

          // ── Label: métricas ──────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
            sliver: SliverToBoxAdapter(child: _SectionLabel('Métricas del día')),
          ),

          // ── Grid de KPIs ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.crossAxisExtent >= 900
                    ? 3
                    : constraints.crossAxisExtent >= 560
                        ? 2
                        : 1;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: cols == 1 ? 3.5 : 2.2,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _KpiCard(data: kpis[i])
                        .animate(delay: Duration(milliseconds: i * 55))
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.08),
                    childCount: kpis.length,
                  ),
                );
              },
            ),
          ),

          // ── Estado del servicio ──────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
            sliver: SliverToBoxAdapter(child: _SectionLabel('Estado del servicio')),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverToBoxAdapter(
              child: _ServiceStatusBar()
                  .animate()
                  .fadeIn(duration: 300.ms, delay: 200.ms),
            ),
          ),

          // ── Accesos rápidos ──────────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
            sliver: SliverToBoxAdapter(child: _SectionLabel('Accesos rápidos')),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 12, 24, 48),
            sliver: SliverToBoxAdapter(child: _QuickActions()),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.onRefresh,
    required this.ordersPending,
    required this.contactsUnread,
  });
  final VoidCallback onRefresh;
  final int ordersPending;
  final int contactsUnread;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 20
            ? 'Buenas tardes'
            : 'Buenas noches';
    final greetIcon = hour < 12
        ? Icons.wb_sunny_rounded
        : hour < 20
            ? Icons.wb_cloudy_rounded
            : Icons.nights_stay_rounded;

    final weekdays = [
      'lunes', 'martes', 'miércoles', 'jueves',
      'viernes', 'sábado', 'domingo',
    ];
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    final dateStr =
        '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]} de ${now.year}';

    final alerts = ordersPending + contactsUnread;
    final subtitle = alerts > 0
        ? '$alerts elemento${alerts == 1 ? "" : "s"} require${alerts == 1 ? "" : "n"} tu atención.'
        : 'Todo en orden. Aquí tienes el resumen de hoy.';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A5A45), Color(0xFF1D9E75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Texto ────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(greetIcon,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(width: 6),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  greeting,
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // ── Controles ────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Tooltip(
                message: 'Actualizar estadísticas',
                child: GestureDetector(
                  onTap: onRefresh,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppTokens.radiusPill),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF86EFAC),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Sistema activo',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ALERTAS URGENTES
// ─────────────────────────────────────────────────────────────────────────────

class _AlertsRow extends StatelessWidget {
  const _AlertsRow({
    required this.ordersPending,
    required this.contactsUnread,
  });
  final int ordersPending;
  final int contactsUnread;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      children: [
        if (ordersPending > 0)
          _AlertChip(
            icon: Icons.pending_actions_rounded,
            label:
                '$ordersPending pedido${ordersPending > 1 ? "s" : ""} pendiente${ordersPending > 1 ? "s" : ""}',
            color: AppTokens.warning,
            bg: AppTokens.warningBg,
            onTap: () => context.go('/admin/orders'),
          ),
        if (contactsUnread > 0)
          _AlertChip(
            icon: Icons.mark_email_unread_rounded,
            label:
                '$contactsUnread mensaje${contactsUnread > 1 ? "s" : ""} sin leer',
            color: AppTokens.danger,
            bg: AppTokens.dangerBg,
            onTap: () => context.go('/admin/config'),
          ),
      ],
    );
  }
}

class _AlertChip extends StatelessWidget {
  const _AlertChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 11, color: color.withValues(alpha: 0.7)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TARJETA KPI
// ─────────────────────────────────────────────────────────────────────────────

class _KpiData {
  const _KpiData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.data});
  final _KpiData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: const Color(0xFFEEF2F7)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Row(
        children: [
          // Barra de acento izquierda
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: data.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTokens.radiusMd),
                bottomLeft: Radius.circular(AppTokens.radiusMd),
              ),
            ),
          ),
          // Contenido central
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.label.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.value,
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: data.color,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Icono a la derecha
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Icon(data.icon, size: 22, color: data.color),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO DEL SERVICIO
// ─────────────────────────────────────────────────────────────────────────────

const _kServices = [
  (
    label: 'Cocina',
    icon: Icons.outdoor_grill_rounded,
    route: '/admin/orders',
    color: AppTokens.brandPrimary
  ),
  (
    label: 'Delivery',
    icon: Icons.delivery_dining_rounded,
    route: '/admin/orders',
    color: AppTokens.info
  ),
  (
    label: 'TPV',
    icon: Icons.point_of_sale_rounded,
    route: '/admin/orders',
    color: Color(0xFF7C3AED)
  ),
  (
    label: 'Catering',
    icon: Icons.celebration_rounded,
    route: '/admin/catering',
    color: AppTokens.warning
  ),
  (
    label: 'Encargos',
    icon: Icons.assignment_rounded,
    route: '/admin/encargos',
    color: AppTokens.brandDark
  ),
];

class _ServiceStatusBar extends StatelessWidget {
  const _ServiceStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: const Color(0xFFEEF2F7)),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _kServices
            .map(
              (s) => _ServiceChip(
                label: s.label,
                icon: s.icon,
                color: s.color,
                onTap: () => context.go(s.route),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ServiceChip extends StatefulWidget {
  const _ServiceChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ServiceChip> createState() => _ServiceChipState();
}

class _ServiceChipState extends State<_ServiceChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.1)
                : const Color(0xFFF8FAFB),
            borderRadius:
                BorderRadius.circular(AppTokens.radiusSm),
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.4)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _hovered
                      ? widget.color
                      : AppTokens.brandPrimary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.icon,
                size: 15,
                color: _hovered
                    ? widget.color
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _hovered
                      ? widget.color
                      : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACCESOS RÁPIDOS
// ─────────────────────────────────────────────────────────────────────────────

const _kQuickActions = [
  (
    label: 'Ver pedidos',
    icon: Icons.receipt_long_rounded,
    route: '/admin/orders',
    color: AppTokens.info
  ),
  (
    label: 'Gestionar platos',
    icon: Icons.restaurant_menu_rounded,
    route: '/admin/dishes',
    color: AppTokens.brandPrimary
  ),
  (
    label: 'Estadísticas',
    icon: Icons.bar_chart_rounded,
    route: '/admin/stats',
    color: Color(0xFF7C3AED)
  ),
  (
    label: 'Usuarios',
    icon: Icons.people_rounded,
    route: '/admin/users',
    color: AppTokens.brandDark
  ),
  (
    label: 'Catering',
    icon: Icons.celebration_rounded,
    route: '/admin/catering',
    color: AppTokens.warning
  ),
  (
    label: 'Configuración',
    icon: Icons.settings_rounded,
    route: '/admin/config',
    color: Color(0xFF6B7280)
  ),
];

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 800
            ? 6
            : constraints.maxWidth >= 500
                ? 4
                : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _kQuickActions.length,
          itemBuilder: (ctx, i) {
            final qa = _kQuickActions[i];
            return _QuickActionCard(
              label: qa.label,
              icon: qa.icon,
              color: qa.color,
              onTap: () => context.go(qa.route),
            );
          },
        );
      },
    );
  }
}

class _QuickActionCard extends StatefulWidget {
  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered ? widget.color : Colors.white,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(
              color: _hovered
                  ? widget.color
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: [
              if (_hovered)
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              else
                AppTokens.cardShadow,
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _hovered
                      ? Colors.white.withValues(alpha: 0.2)
                      : widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.icon,
                  size: 22,
                  color: _hovered ? Colors.white : widget.color,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hovered
                      ? Colors.white
                      : const Color(0xFF374151),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: label de sección con acento verde
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppTokens.brandPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6B7280),
            letterSpacing: 0.9,
          ),
        ),
      ],
    );
  }
}


