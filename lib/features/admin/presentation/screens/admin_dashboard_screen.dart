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

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return AdminShell(
      title: 'Dashboard',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTokens.brandPrimary),
          tooltip: 'Actualizar',
          onPressed: () => ref.invalidate(adminDashboardStatsProvider),
        ),
        const SizedBox(width: 8),
      ],
      child: statsAsync.when(
        data: (stats) => _DashboardBody(stats: stats),
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

// ── Cuerpo del dashboard ──────────────────────────────────────────────────────

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats});
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context) {
    final revenue = (stats['revenue_total'] as num? ?? 0).toDouble();
    final ordersTotal = (stats['orders_total'] as num?)?.toInt() ?? 0;
    final ordersPending = (stats['orders_pending'] as num?)?.toInt() ?? 0;
    final usersTotal = (stats['users_total'] as num?)?.toInt() ?? 0;
    final contactsUnread = (stats['contacts_unread'] as num?)?.toInt() ?? 0;
    final eventsTotal = (stats['events_total'] as num?)?.toInt() ?? 0;

    final kpis = [
      _Kpi(
        label: 'Ventas hoy',
        value: Formatters.price(revenue),
        icon: Icons.payments_rounded,
        color: AppTokens.brandPrimary,
        subtitle: 'Ingresos del día',
      ),
      _Kpi(
        label: 'Pedidos totales',
        value: ordersTotal.toString(),
        icon: Icons.receipt_long_rounded,
        color: AppTokens.info,
        subtitle: 'Pedidos registrados hoy',
      ),
      _Kpi(
        label: 'Pendientes',
        value: ordersPending.toString(),
        icon: Icons.pending_actions_rounded,
        color: AppTokens.warning,
        subtitle: 'Requieren atención',
      ),
      _Kpi(
        label: 'Usuarios',
        value: usersTotal.toString(),
        icon: Icons.people_rounded,
        color: AppTokens.brandDark,
        subtitle: 'Clientes registrados',
      ),
      _Kpi(
        label: 'Mensajes sin leer',
        value: contactsUnread.toString(),
        icon: Icons.mark_email_unread_rounded,
        color: AppTokens.danger,
        subtitle: 'Mensajes nuevos',
      ),
      _Kpi(
        label: 'Eventos catering',
        value: eventsTotal.toString(),
        icon: Icons.celebration_rounded,
        color: const Color(0xFF7C3AED),
        subtitle: 'Solicitudes activas',
      ),
    ];

    return CustomScrollView(
      slivers: [
        // ── Saludo ──────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _Greeting().animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),
        ),

        // ── KPI grid ────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.crossAxisExtent >= 900
                  ? 3
                  : constraints.crossAxisExtent >= 580
                      ? 2
                      : 1;
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: cols == 1 ? 2.5 : 1.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => MetricCard(
                    label: kpis[i].label,
                    value: kpis[i].value,
                    icon: kpis[i].icon,
                    color: kpis[i].color,
                    subtitle: kpis[i].subtitle,
                  )
                      .animate(delay: Duration(milliseconds: i * 70))
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.08),
                  childCount: kpis.length,
                ),
              );
            },
          ),
        ),

        // ── Accesos rápidos ──────────────────────────────────────────────
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
          sliver: SliverToBoxAdapter(child: SectionHeader('Accesos rápidos')),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, 40),
          sliver: SliverToBoxAdapter(child: _QuickActions()),
        ),
      ],
    );
  }
}

// ── Saludo ────────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Buenos días'
        : hour < 20
            ? 'Buenas tardes'
            : 'Buenas noches';
    final weekdays = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    final months = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
    final dateStr = '${weekdays[now.weekday - 1]}, ${now.day} de ${months[now.month - 1]} de ${now.year}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTokens.brandPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF8A8FA8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  greeting,
                  style: GoogleFonts.syne(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Aquí tienes el resumen de hoy.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF8A8FA8),
                  ),
                ),
              ],
            ),
          ),
          // Marca decorativa
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.storefront_rounded,
                    size: 14, color: AppTokens.brandPrimary),
                const SizedBox(width: 6),
                Text(
                  'Sabor de Casa',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTokens.brandDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Accesos rápidos ───────────────────────────────────────────────────────────

const _kQuickActions = [
  (label: 'Ver pedidos', icon: Icons.receipt_long_rounded, route: '/admin/orders', color: AppTokens.info),
  (label: 'Gestionar platos', icon: Icons.restaurant_menu_rounded, route: '/admin/dishes', color: AppTokens.brandPrimary),
  (label: 'Estadísticas', icon: Icons.bar_chart_rounded, route: '/admin/stats', color: Color(0xFF7C3AED)),
  (label: 'Usuarios', icon: Icons.people_rounded, route: '/admin/users', color: AppTokens.brandDark),
  (label: 'Catering', icon: Icons.celebration_rounded, route: '/admin/catering', color: AppTokens.warning),
  (label: 'Configuración', icon: Icons.settings_rounded, route: '/admin/config', color: const Color(0xFF6B7280)),
];

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth >= 800 ? 6 : constraints.maxWidth >= 500 ? 4 : 3;
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
            color: _hovered
                ? widget.color.withValues(alpha: 0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(
              color: _hovered ? widget.color.withValues(alpha: 0.3) : const Color(0xFFEEEEEE),
            ),
            boxShadow: [if (_hovered) AppTokens.cardShadow],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: _hovered ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, size: 20, color: widget.color),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _hovered ? const Color(0xFF1A1A2E) : const Color(0xFF555570),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Modelo interno ────────────────────────────────────────────────────────────

class _Kpi {
  const _Kpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
}
