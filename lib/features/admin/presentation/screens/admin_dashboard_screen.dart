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

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.stats, required this.onRefresh});
  final Map<String, dynamic> stats;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueToday = (stats['revenue_today'] as num? ?? 0).toDouble();
    final revenueWeek = (stats['revenue_week'] as num? ?? 0).toDouble();
    final revenueMonth = (stats['revenue_month'] as num? ?? 0).toDouble();
    final ordersToday = (stats['orders_today'] as num?)?.toInt() ?? 0;
    final ordersPending = (stats['orders_pending'] as num?)?.toInt() ?? 0;
    final avgTicketToday = (stats['avg_ticket_today'] as num? ?? 0).toDouble();
    final clientsTotal = (stats['clients_total'] as num?)?.toInt() ?? 0;
    final usersNewWeek = (stats['users_new_week'] as num?)?.toInt() ?? 0;
    final supportUnread = (stats['support_unread'] as num?)?.toInt() ?? 0;
    final eventsPending = (stats['events_pending'] as num?)?.toInt() ?? 0;

    // Serie de los últimos 7 días para el minigráfico.
    final revenue7d = ref.watch(adminRevenueLast7DaysProvider).valueOrNull ?? const [];
    final series = revenue7d
        .map((e) => (e['total'] as num? ?? 0).toDouble())
        .toList(growable: false);
    // Variación respecto al día anterior (penúltimo de la serie).
    double? deltaPct;
    if (series.length >= 2) {
      final yesterday = series[series.length - 2];
      if (yesterday > 0) {
        deltaPct = ((revenueToday - yesterday) / yesterday) * 100;
      } else if (revenueToday > 0) {
        deltaPct = 100;
      }
    }

    final secondaryKpis = [
      _KpiData(
        label: 'Ingresos semana',
        value: Formatters.price(revenueWeek),
        icon: Icons.calendar_view_week_rounded,
        color: AppTokens.brandDark,
        subtitle: 'Lunes a hoy',
      ),
      _KpiData(
        label: 'Ingresos mes',
        value: Formatters.price(revenueMonth),
        icon: Icons.calendar_month_rounded,
        color: const Color(0xFF7C3AED),
        subtitle: 'Acumulado',
      ),
      _KpiData(
        label: 'Clientes',
        value: '$clientsTotal',
        icon: Icons.people_rounded,
        color: const Color(0xFF0F6E56),
        subtitle: usersNewWeek > 0
            ? '+$usersNewWeek esta semana'
            : 'Sin altas nuevas',
      ),
      _KpiData(
        label: 'Mensajes',
        value: '$supportUnread',
        icon: Icons.mark_email_unread_rounded,
        color: supportUnread > 0
            ? AppTokens.danger
            : const Color(0xFF6B7280),
        subtitle: supportUnread > 0 ? 'Soporte sin leer' : 'Bandeja al día',
      ),
      _KpiData(
        label: 'Catering',
        value: '$eventsPending',
        icon: Icons.celebration_rounded,
        color: eventsPending > 0
            ? AppTokens.warning
            : const Color(0xFF7C3AED),
        subtitle: eventsPending > 0 ? 'Por revisar' : 'Sin solicitudes',
      ),
      _KpiData(
        label: 'Ticket medio',
        value: Formatters.price(avgTicketToday),
        icon: Icons.local_atm_rounded,
        color: AppTokens.info,
        subtitle: 'Promedio hoy',
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
              contactsUnread: supportUnread,
            ).animate().fadeIn(duration: 350.ms),
          ),

          // ── Alertas urgentes (solo si hay pendientes) ────────────────
          if (ordersPending > 0 ||
              supportUnread > 0 ||
              eventsPending > 0)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _AlertsRow(
                  ordersPending: ordersPending,
                  contactsUnread: supportUnread,
                  eventsPending: eventsPending,
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
              ),
            ),

          // ── Tarjeta destacada con resumen del día ────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            sliver: SliverToBoxAdapter(
              child: _TodayHeroCard(
                revenueToday: revenueToday,
                ordersToday: ordersToday,
                ordersPending: ordersPending,
                avgTicket: avgTicketToday,
                series: series,
                deltaPct: deltaPct,
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),
            ),
          ),

          // ── Label: otras métricas ────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
            sliver: SliverToBoxAdapter(child: _SectionLabel('Otras métricas')),
          ),

          // ── Grid de KPIs secundarios (denso) ─────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.crossAxisExtent;
                final cols = w >= 1200
                    ? 6
                    : w >= 900
                        ? 3
                        : w >= 560
                            ? 2
                            : 1;
                final ratio = cols == 1
                    ? 3.4
                    : cols == 2
                        ? 2.6
                        : cols == 3
                            ? 2.1
                            : 1.55;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: ratio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _KpiCard(data: secondaryKpis[i])
                        .animate(delay: Duration(milliseconds: i * 45))
                        .fadeIn(duration: 280.ms)
                        .slideY(begin: 0.06),
                    childCount: secondaryKpis.length,
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
              child: const _AcceptingOrdersCard()
                  .animate()
                  .fadeIn(duration: 300.ms),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
            sliver: SliverToBoxAdapter(
              child: const _ServiceStatusBar()
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
    required this.eventsPending,
  });
  final int ordersPending;
  final int contactsUnread;
  final int eventsPending;

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
            onTap: () => context.go('/admin/support'),
          ),
        if (eventsPending > 0)
          _AlertChip(
            icon: Icons.celebration_rounded,
            label:
                '$eventsPending evento${eventsPending > 1 ? "s" : ""} de catering por revisar',
            color: const Color(0xFF7C3AED),
            bg: const Color(0xFFEFE6FE),
            onTap: () => context.go('/admin/catering'),
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
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, size: 16, color: data.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9CA3AF),
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              data.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
                height: 1.05,
              ),
            ),
          ),
          Text(
            data.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TARJETA DESTACADA — RESUMEN DEL DÍA con sparkline
// ─────────────────────────────────────────────────────────────────────────────

class _TodayHeroCard extends StatelessWidget {
  const _TodayHeroCard({
    required this.revenueToday,
    required this.ordersToday,
    required this.ordersPending,
    required this.avgTicket,
    required this.series,
    required this.deltaPct,
  });

  final double revenueToday;
  final int ordersToday;
  final int ordersPending;
  final double avgTicket;
  final List<double> series;
  final double? deltaPct;

  @override
  Widget build(BuildContext context) {
    final delta = deltaPct;
    final positive = (delta ?? 0) >= 0;
    final deltaColor = positive ? AppTokens.success : AppTokens.danger;

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 720;
        final leftBlock = Padding(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusPill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payments_rounded,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'INGRESOS DE HOY',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (delta != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: deltaColor.withValues(alpha: 0.18),
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            positive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            size: 13,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${positive ? '+' : ''}${delta.toStringAsFixed(1)}%',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'vs ayer',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                Formatters.price(revenueToday),
                style: GoogleFonts.inter(
                  fontSize: 44,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Facturación del día en curso',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 24,
                runSpacing: 10,
                children: [
                  _MiniStat(
                      label: 'Pedidos hoy',
                      value: '$ordersToday',
                      icon: Icons.receipt_long_rounded),
                  _MiniStat(
                      label: 'Pendientes',
                      value: '$ordersPending',
                      icon: Icons.pending_actions_rounded,
                      highlight: ordersPending > 0),
                  _MiniStat(
                      label: 'Ticket medio',
                      value: Formatters.price(avgTicket),
                      icon: Icons.local_atm_rounded),
                ],
              ),
            ],
          ),
        );

        final rightBlock = Padding(
          padding: narrow
              ? const EdgeInsets.fromLTRB(20, 0, 20, 18)
              : const EdgeInsets.fromLTRB(0, 22, 24, 22),
          child: SizedBox(
            height: narrow ? 120 : double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EVOLUCIÓN · 7 DÍAS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: series.isEmpty
                      ? Center(
                          child: Text(
                            'Sin datos disponibles',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      : CustomPaint(
                          painter: _SparklinePainter(series: series),
                          size: Size.infinite,
                        ),
                ),
              ],
            ),
          ),
        );

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F6E56), Color(0xFF1D9E75), Color(0xFF22B47C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTokens.brandPrimary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [leftBlock, rightBlock],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 5, child: leftBlock),
                      Expanded(flex: 4, child: rightBlock),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 16,
            color: highlight
                ? const Color(0xFFFFD27A)
                : Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: Colors.white.withValues(alpha: 0.7),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.series});
  final List<double> series;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;
    final maxV = series.reduce((a, b) => a > b ? a : b);
    final minV = series.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 0.01 ? 1.0 : (maxV - minV);
    final stepX = series.length > 1 ? size.width / (series.length - 1) : 0.0;

    Offset pointAt(int i) {
      final v = series[i];
      final norm = (v - minV) / range;
      final y = size.height - (norm * (size.height - 8)) - 4;
      return Offset(stepX * i, y);
    }

    final path = Path();
    final fill = Path();
    for (var i = 0; i < series.length; i++) {
      final p = pointAt(i);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
        fill
          ..moveTo(p.dx, size.height)
          ..lineTo(p.dx, p.dy);
      } else {
        final prev = pointAt(i - 1);
        final cx = (prev.dx + p.dx) / 2;
        path.cubicTo(cx, prev.dy, cx, p.dy, p.dx, p.dy);
        fill.cubicTo(cx, prev.dy, cx, p.dy, p.dx, p.dy);
      }
    }
    fill
      ..lineTo(size.width, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.32),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fill, fillPaint);

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Punto final destacado
    final last = pointAt(series.length - 1);
    canvas
      ..drawCircle(last, 5, Paint()..color = Colors.white)
      ..drawCircle(last, 3, Paint()..color = const Color(0xFF0F6E56));
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.series != series;
}

// ─────────────────────────────────────────────────────────────────────────────
// ACEPTAR PEDIDOS
// ─────────────────────────────────────────────────────────────────────────────

class _AcceptingOrdersCard extends ConsumerWidget {
  const _AcceptingOrdersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAccepting = ref.watch(acceptingOrdersProvider);
    final isLoading = ref.watch(
      adminActionProvider.select((v) => v.isLoading),
    );
    final accepting = asyncAccepting.valueOrNull ?? true;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      decoration: BoxDecoration(
        color: accepting ? Colors.white : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(
          color: accepting
              ? const Color(0xFFEEF2F7)
              : const Color(0xFFFFC107).withValues(alpha: 0.5),
        ),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accepting
                  ? AppTokens.success.withValues(alpha: 0.1)
                  : AppTokens.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              accepting
                  ? Icons.storefront_rounded
                  : Icons.pause_circle_outline_rounded,
              color: accepting ? AppTokens.success : AppTokens.warning,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accepting ? 'Aceptando pedidos' : 'Pedidos pausados',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: accepting
                        ? const Color(0xFF111111)
                        : const Color(0xFF856404),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  accepting
                      ? 'Los clientes pueden realizar pedidos ahora'
                      : 'El checkout est\u00e1 bloqueado para domicilio y recogida',
                  style: TextStyle(
                    fontSize: 12,
                    color: accepting
                        ? const Color(0xFF6B7280)
                        : const Color(0xFF856404).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch(
            value: accepting,
            activeThumbColor: AppTokens.success,
            inactiveTrackColor: AppTokens.warning.withValues(alpha: 0.3),
            onChanged: isLoading || asyncAccepting.isLoading
                ? null
                : (v) => ref
                    .read(adminActionProvider.notifier)
                    .toggleAcceptingOrders(accepting: v),
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
