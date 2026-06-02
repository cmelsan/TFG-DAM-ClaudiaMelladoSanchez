import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

const _kPageBg = Color(0xFFF4F6F8);
const _kCardBorder = Color(0xFFEEEEEE);
const _kInk = Color(0xFF1A1A2E);
const _kInkMuted = Color(0xFF6B7280);
const _kInkSoft = Color(0xFF9CA3AF);

class AdminStatsScreen extends ConsumerWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return AdminShell(
      title: 'Estadisticas',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.refresh_rounded,
            color: AppTokens.brandPrimary,
          ),
          tooltip: 'Actualizar',
          onPressed: () {
            ref
              ..invalidate(adminDashboardStatsProvider)
              ..invalidate(adminRevenueLast7DaysProvider)
              ..invalidate(adminRevenueLast30DaysProvider)
              ..invalidate(adminTopDishesProvider)
              ..invalidate(adminUsersStatsProvider)
              ..invalidate(adminUsersProvider)
              ..invalidate(adminOrdersProvider);
          },
        ),
        const SizedBox(width: 8),
      ],
      child: statsAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, _) => Center(
          child: ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(adminDashboardStatsProvider),
          ),
        ),
        data: (stats) => _StatsBody(stats: stats),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────────────────

class _StatsBody extends ConsumerWidget {
  const _StatsBody({required this.stats});
  final Map<String, dynamic> stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueToday = (stats['revenue_today'] as num? ?? 0).toDouble();
    final revenueWeek = (stats['revenue_week'] as num? ?? 0).toDouble();
    final revenueMonth = (stats['revenue_month'] as num? ?? 0).toDouble();
    final revenueTotal = (stats['revenue_total'] as num? ?? 0).toDouble();
    final ordersToday = (stats['orders_today'] as num?)?.toInt() ?? 0;
    final ordersWeek = (stats['orders_week'] as num?)?.toInt() ?? 0;
    final ordersMonth = (stats['orders_month'] as num?)?.toInt() ?? 0;
    final ordersTotal = (stats['orders_total'] as num?)?.toInt() ?? 0;
    final pending = (stats['orders_pending'] as num?)?.toInt() ?? 0;
    final confirmed = (stats['orders_confirmed'] as num?)?.toInt() ?? 0;
    final preparing = (stats['orders_preparing'] as num?)?.toInt() ?? 0;
    final ready = (stats['orders_ready'] as num?)?.toInt() ?? 0;
    final cancelled = (stats['orders_cancelled'] as num?)?.toInt() ?? 0;
    final avgTicketMonth = (stats['avg_ticket_month'] as num? ?? 0).toDouble();
    final avgTicketToday = (stats['avg_ticket_today'] as num? ?? 0).toDouble();
    final usersNewWeek = (stats['users_new_week'] as num?)?.toInt() ?? 0;
    final clientsTotal = (stats['clients_total'] as num?)?.toInt() ?? 0;
    final contactsUnread = (stats['contacts_unread'] as num?)?.toInt() ?? 0;
    final eventsPending = (stats['events_pending'] as num?)?.toInt() ?? 0;

    final cancelRate = ordersTotal == 0
        ? 0.0
        : (cancelled / ordersTotal) * 100;

    return ColoredBox(
      color: _kPageBg,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
        children: [
          // ── Hero "Hoy" con sparkline + delta ──────────────────────────
          _HeroToday(
            revenueToday: revenueToday,
            ordersToday: ordersToday,
            avgTicketToday: avgTicketToday,
            pending: pending,
          ),
          const SizedBox(height: 20),

          // ── Resumen oscuro con periodos ───────────────────────────────
          _DarkSummary(
            tiles: [
              _SummaryTile(
                label: 'Hoy',
                value: Formatters.price(revenueToday),
                sub: '$ordersToday pedidos',
              ),
              _SummaryTile(
                label: 'Esta semana',
                value: Formatters.price(revenueWeek),
                sub: '$ordersWeek pedidos',
              ),
              _SummaryTile(
                label: 'Este mes',
                value: Formatters.price(revenueMonth),
                sub: '$ordersMonth pedidos',
                highlight: true,
              ),
              _SummaryTile(
                label: 'Historico',
                value: Formatters.price(revenueTotal),
                sub: '$ordersTotal pedidos',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── KPIs ─────────────────────────────────────────────────────
          _KpiGrid(
            kpis: [
              _MiniKpiData(
                icon: Icons.payments_rounded,
                color: AppTokens.brandPrimary,
                label: 'Ticket medio mes',
                value: Formatters.price(avgTicketMonth),
              ),
              _MiniKpiData(
                icon: Icons.point_of_sale_rounded,
                color: AppTokens.brandDark,
                label: 'Ticket medio hoy',
                value: Formatters.price(avgTicketToday),
              ),
              _MiniKpiData(
                icon: Icons.pending_actions_rounded,
                color: AppTokens.warning,
                label: 'Pedidos pendientes',
                value: '$pending',
              ),
              _MiniKpiData(
                icon: Icons.cancel_rounded,
                color: AppTokens.danger,
                label: 'Tasa cancelacion',
                value: '${cancelRate.toStringAsFixed(1)}%',
                subtitle: '$cancelled de $ordersTotal',
              ),
              _MiniKpiData(
                icon: Icons.person_add_rounded,
                color: AppTokens.info,
                label: 'Nuevos clientes (sem.)',
                value: '$usersNewWeek',
                subtitle: '$clientsTotal totales',
              ),
              _MiniKpiData(
                icon: Icons.mark_email_unread_rounded,
                color: AppTokens.brandPrimary,
                label: 'Mensajes pendientes',
                value: '$contactsUnread',
                subtitle: '$eventsPending eventos',
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Gráfico ingresos 30 días ──────────────────────────────────
          const _SectionHeader('Ingresos · ultimos 30 dias'),
          const SizedBox(height: 12),
          const _RevenueChartCard(),
          const SizedBox(height: 28),

          // ── Estados + tipos en dos columnas ───────────────────────────
          LayoutBuilder(
            builder: (ctx, c) {
              final twoCol = c.maxWidth >= 1000;
              final statusCard = _SectionWithCard(
                title: 'Pedidos por estado',
                child: _StatusBarsCard(
                  data: [
                    ('Pendientes', pending, AppTokens.warning),
                    ('Confirmados', confirmed, AppTokens.info),
                    ('Preparando', preparing, AppTokens.brandPrimary),
                    ('Listos', ready, AppTokens.brandDark),
                    ('Cancelados', cancelled, AppTokens.danger),
                  ],
                ),
              );
              const typesCard = _SectionWithCard(
                title: 'Pedidos por tipo',
                child: _OrderTypeDonutCard(),
              );
              if (twoCol) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: statusCard),
                    const SizedBox(width: 20),
                    const Expanded(child: typesCard),
                  ],
                );
              }
              return Column(
                children: [
                  statusCard,
                  const SizedBox(height: 20),
                  typesCard,
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // ── Día de la semana + Hora del día ───────────────────────────
          LayoutBuilder(
            builder: (ctx, c) {
              final twoCol = c.maxWidth >= 1000;
              const dowCard = _SectionWithCard(
                title: 'Distribucion por dia de la semana',
                child: _DayOfWeekCard(),
              );
              const hourCard = _SectionWithCard(
                title: 'Distribucion por hora del dia',
                child: _HourOfDayCard(),
              );
              if (twoCol) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: dowCard),
                    SizedBox(width: 20),
                    Expanded(child: hourCard),
                  ],
                );
              }
              return const Column(
                children: [
                  dowCard,
                  SizedBox(height: 20),
                  hourCard,
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // ── Top platos + Top clientes ─────────────────────────────────
          LayoutBuilder(
            builder: (ctx, c) {
              final twoCol = c.maxWidth >= 1000;
              const topDishes = _SectionWithCard(
                title: 'Top 5 platos · ultimos 30 dias',
                child: _TopDishesCard(),
              );
              const topCustomers = _SectionWithCard(
                title: 'Top 5 clientes · histórico',
                child: _TopCustomersCard(),
              );
              if (twoCol) {
                return const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: topDishes),
                    SizedBox(width: 20),
                    Expanded(child: topCustomers),
                  ],
                );
              }
              return const Column(
                children: [
                  topDishes,
                  SizedBox(height: 20),
                  topCustomers,
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO "HOY"
// ─────────────────────────────────────────────────────────────────────────────

class _HeroToday extends ConsumerWidget {
  const _HeroToday({
    required this.revenueToday,
    required this.ordersToday,
    required this.avgTicketToday,
    required this.pending,
  });

  final double revenueToday;
  final int ordersToday;
  final double avgTicketToday;
  final int pending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revenueSeriesAsync = ref.watch(adminRevenueLast7DaysProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F6E56), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandPrimary.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (ctx, c) {
          final wide = c.maxWidth >= 720;
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INGRESOS DE HOY',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  letterSpacing: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                Formatters.price(revenueToday),
                style: GoogleFonts.inter(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 12),
              revenueSeriesAsync.when(
                loading: () => const SizedBox(height: 18),
                error: (_, __) => const SizedBox.shrink(),
                data: (series) {
                  if (series.length < 2) return const SizedBox.shrink();
                  final todayVal =
                      (series.last['total'] as num? ?? 0).toDouble();
                  final yesterdayVal =
                      (series[series.length - 2]['total'] as num? ?? 0)
                          .toDouble();
                  String delta;
                  Color color;
                  IconData icon;
                  if (yesterdayVal == 0 && todayVal == 0) {
                    delta = 'Sin movimiento';
                    color = Colors.white.withValues(alpha: 0.7);
                    icon = Icons.remove_rounded;
                  } else if (yesterdayVal == 0) {
                    delta = 'Primera venta del periodo';
                    color = Colors.greenAccent.shade100;
                    icon = Icons.trending_up_rounded;
                  } else {
                    final pct =
                        ((todayVal - yesterdayVal) / yesterdayVal) * 100;
                    final up = pct >= 0;
                    delta =
                        '${up ? '+' : ''}${pct.toStringAsFixed(1)}% vs ayer';
                    color = up
                        ? Colors.greenAccent.shade100
                        : Colors.redAccent.shade100;
                    icon = up
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded;
                  }
                  return Row(
                    children: [
                      Icon(icon, color: color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        delta,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 20,
                runSpacing: 12,
                children: [
                  _HeroStat(label: 'Pedidos hoy', value: '$ordersToday'),
                  _HeroStat(label: 'Pendientes', value: '$pending'),
                  _HeroStat(
                    label: 'Ticket medio',
                    value: Formatters.price(avgTicketToday),
                  ),
                ],
              ),
            ],
          );

          final sparkline = revenueSeriesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (series) {
              if (series.isEmpty) return const SizedBox.shrink();
              final values = series
                  .map((e) => (e['total'] as num? ?? 0).toDouble())
                  .toList();
              return SizedBox(
                height: 110,
                width: wide ? 260 : double.infinity,
                child: CustomPaint(painter: _SparklinePainter(series: values)),
              );
            },
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: left),
                const SizedBox(width: 24),
                Align(alignment: Alignment.bottomRight, child: sparkline),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              left,
              const SizedBox(height: 12),
              sparkline,
            ],
          );
        },
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            letterSpacing: 0.3,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION + CARD WRAPPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _kInk,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _SectionWithCard extends StatelessWidget {
  const _SectionWithCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

Widget _cardShell({required Widget child, EdgeInsets? padding}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      border: Border.all(color: _kCardBorder),
      boxShadow: [AppTokens.cardShadow],
    ),
    child: child,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOQUE OSCURO DE RESUMEN
// ─────────────────────────────────────────────────────────────────────────────

class _DarkSummary extends StatelessWidget {
  const _DarkSummary({required this.tiles});
  final List<_SummaryTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F6E56), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandPrimary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (ctx, c) {
          final cols = c.maxWidth >= 760 ? 4 : (c.maxWidth >= 480 ? 2 : 1);
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final t in tiles)
                SizedBox(
                  width: cols == 1
                      ? c.maxWidth
                      : (c.maxWidth - 16 * (cols - 1)) / cols,
                  child: t,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.sub,
    this.highlight = false,
  });
  final String label;
  final String value;
  final String sub;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: highlight ? 26 : 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KPI GRID
// ─────────────────────────────────────────────────────────────────────────────

class _MiniKpiData {
  const _MiniKpiData({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? subtitle;
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({required this.kpis});
  final List<_MiniKpiData> kpis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= 1200
            ? 6
            : c.maxWidth >= 900
                ? 3
                : c.maxWidth >= 560
                    ? 2
                    : 1;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: cols,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: cols == 1
              ? 4
              : cols == 6
                  ? 1.35
                  : 2.4,
          children: [for (final k in kpis) _MiniKpi(data: k)],
        );
      },
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({required this.data});
  final _MiniKpiData data;

  @override
  Widget build(BuildContext context) {
    return _cardShell(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: _kInkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            data.value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _kInk,
              height: 1.05,
            ),
          ),
          if (data.subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              data.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 11, color: _kInkSoft),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRÁFICO DE INGRESOS (línea, últimos 30 días)
// ─────────────────────────────────────────────────────────────────────────────

class _RevenueChartCard extends ConsumerWidget {
  const _RevenueChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminRevenueLast30DaysProvider);

    return _cardShell(
      child: async.when(
        loading: () => const SizedBox(
          height: 240,
          child: Center(child: LoadingIndicator()),
        ),
        error: (e, _) => SizedBox(
          height: 240,
          child: Center(
            child: Text(
              'Error: $e',
              style: GoogleFonts.inter(
                color: AppTokens.danger,
                fontSize: 12,
              ),
            ),
          ),
        ),
        data: (series) {
          if (series.isEmpty) {
            return SizedBox(
              height: 240,
              child: Center(
                child: Text(
                  'Sin datos en los ultimos 30 dias',
                  style: GoogleFonts.inter(
                    color: _kInkMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }
          final spots = <FlSpot>[];
          double maxY = 0;
          double sum = 0;
          for (var i = 0; i < series.length; i++) {
            final total = (series[i]['total'] as num).toDouble();
            spots.add(FlSpot(i.toDouble(), total));
            if (total > maxY) maxY = total;
            sum += total;
          }
          maxY = maxY == 0 ? 10 : maxY * 1.18;
          final avg = sum / series.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const _LegendDot(color: AppTokens.brandPrimary, label: 'Ingresos'),
                  const SizedBox(width: 16),
                  _LegendDot(
                    color: AppTokens.brandDark.withValues(alpha: 0.55),
                    label: 'Promedio (${Formatters.price(avg)})',
                    dashed: true,
                  ),
                  const Spacer(),
                  Text(
                    'Total 30 dias: ${Formatters.price(sum)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY,
                    extraLinesData: ExtraLinesData(
                      horizontalLines: [
                        HorizontalLine(
                          y: avg,
                          color: AppTokens.brandDark.withValues(alpha: 0.55),
                          strokeWidth: 1.5,
                          dashArray: [6, 4],
                        ),
                      ],
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => const FlLine(
                        color: Color(0xFFF0F0F0),
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 44,
                          getTitlesWidget: (v, _) => Text(
                            v >= 1000
                                ? '${(v / 1000).toStringAsFixed(1)}k'
                                : v.toStringAsFixed(0),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: _kInkSoft,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: (series.length / 6).ceilToDouble(),
                          getTitlesWidget: (v, _) {
                            final i = v.toInt();
                            if (i < 0 || i >= series.length) {
                              return const SizedBox.shrink();
                            }
                            final d = series[i]['date'] as DateTime;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${d.day}/${d.month}',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: _kInkSoft,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => _kInk,
                        getTooltipItems: (touchedSpots) =>
                            touchedSpots.map((s) {
                          final i = s.x.toInt();
                          final d = series[i]['date'] as DateTime;
                          return LineTooltipItem(
                            '${d.day}/${d.month} · ${Formatters.price(s.y)}',
                            GoogleFonts.inter(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: AppTokens.brandPrimary,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppTokens.brandPrimary.withValues(alpha: 0.28),
                              AppTokens.brandPrimary.withValues(alpha: 0.02),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.dashed = false,
  });
  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: _kInkMuted,
            fontWeight: FontWeight.w500,
            fontStyle: dashed ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BARRAS DE ESTADO DE PEDIDOS
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBarsCard extends StatelessWidget {
  const _StatusBarsCard({required this.data});
  final List<(String, int, Color)> data;

  @override
  Widget build(BuildContext context) {
    final maxV = data.fold<int>(0, (m, e) => e.$2 > m ? e.$2 : m);
    final divisor = maxV == 0 ? 1 : maxV;
    final total = data.fold<int>(0, (s, e) => s + e.$2);

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in data)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      item.$1,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          Container(
                            height: 10,
                            color: const Color(0xFFF3F4F6),
                          ),
                          FractionallySizedBox(
                            widthFactor: item.$2 / divisor,
                            child: Container(height: 10, color: item.$3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 44,
                    child: Text(
                      '${item.$2}',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: _kInk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            'Total: $total pedidos',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: _kInkSoft,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DONUT POR TIPO DE PEDIDO (delivery / pickup / encargo / local)
// ─────────────────────────────────────────────────────────────────────────────

class _OrderTypeDonutCard extends ConsumerWidget {
  const _OrderTypeDonutCard();

  static const _typeLabels = {
    'delivery': 'Domicilio',
    'pickup': 'Recogida',
    'encargo': 'Encargo',
    'local': 'En local',
  };

  static const _typeColors = {
    'delivery': AppTokens.brandPrimary,
    'pickup': AppTokens.info,
    'encargo': AppTokens.warning,
    'local': AppTokens.brandDark,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return _cardShell(
      child: ordersAsync.when(
        loading: () => const SizedBox(
          height: 220,
          child: Center(child: LoadingIndicator()),
        ),
        error: (e, _) => SizedBox(
          height: 220,
          child: Center(
            child: Text(
              'Error: $e',
              style: GoogleFonts.inter(color: AppTokens.danger, fontSize: 12),
            ),
          ),
        ),
        data: (orders) {
          final counts = <String, int>{};
          for (final o in orders.where((o) => o.status != 'cancelled')) {
            counts[o.orderType] = (counts[o.orderType] ?? 0) + 1;
          }
          final total = counts.values.fold<int>(0, (s, v) => s + v);
          if (total == 0) {
            return SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'Sin pedidos registrados',
                  style: GoogleFonts.inter(color: _kInkMuted, fontSize: 13),
                ),
              ),
            );
          }
          final entries = counts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          return SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 48,
                      sections: [
                        for (final e in entries)
                          PieChartSectionData(
                            value: e.value.toDouble(),
                            color: _typeColors[e.key] ?? AppTokens.brandPrimary,
                            title: '${(e.value / total * 100).round()}%',
                            titleStyle: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            radius: 50,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final e in entries) ...[
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _typeColors[e.key] ??
                                    AppTokens.brandPrimary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _typeLabels[e.key] ?? e.key,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: _kInk,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${e.value}',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                color: _kInk,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DÍA DE LA SEMANA
// ─────────────────────────────────────────────────────────────────────────────

class _DayOfWeekCard extends ConsumerWidget {
  const _DayOfWeekCard();

  static const _labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return _cardShell(
      child: ordersAsync.when(
        loading: () => const SizedBox(
          height: 220,
          child: Center(child: LoadingIndicator()),
        ),
        error: (e, _) => SizedBox(
          height: 220,
          child: Center(
            child: Text(
              'Error: $e',
              style: GoogleFonts.inter(color: AppTokens.danger, fontSize: 12),
            ),
          ),
        ),
        data: (orders) {
          final counts = List<int>.filled(7, 0);
          final revenue = List<double>.filled(7, 0);
          for (final o in orders.where((o) => o.status != 'cancelled')) {
            final ref = _refDate(o);
            final idx = ref.weekday - 1;
            counts[idx]++;
            revenue[idx] += o.total;
          }
          final maxC = counts.fold<int>(0, math.max);
          final total = counts.fold<int>(0, (a, b) => a + b);
          if (total == 0) {
            return SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'Sin pedidos para analizar',
                  style: GoogleFonts.inter(color: _kInkMuted, fontSize: 13),
                ),
              ),
            );
          }
          var bestIdx = 0;
          for (var i = 1; i < counts.length; i++) {
            if (counts[i] > counts[bestIdx]) bestIdx = i;
          }
          return SizedBox(
            height: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dia mas fuerte: ${_dayName(bestIdx)} · ${counts[bestIdx]} pedidos',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _kInkMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${counts[i]}',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: _kInk,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius:
                                      const BorderRadius.vertical(
                                          top: Radius.circular(6)),
                                  child: Container(
                                    height: maxC == 0
                                        ? 0
                                        : (counts[i] / maxC) * 120,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: i == bestIdx
                                            ? [
                                                AppTokens.brandPrimary,
                                                AppTokens.brandDark,
                                              ]
                                            : [
                                                AppTokens.brandPrimary
                                                    .withValues(alpha: 0.5),
                                                AppTokens.brandPrimary
                                                    .withValues(alpha: 0.25),
                                              ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _labels[i],
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: i == bestIdx
                                        ? AppTokens.brandDark
                                        : _kInkSoft,
                                    fontWeight: i == bestIdx
                                        ? FontWeight.w800
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _dayName(int idx) =>
      const ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'][idx];
}

DateTime _refDate(Order o) =>
    o.orderType == 'encargo' && o.scheduledAt != null
        ? o.scheduledAt!
        : o.createdAt;

// ─────────────────────────────────────────────────────────────────────────────
// HORA DEL DÍA
// ─────────────────────────────────────────────────────────────────────────────

class _HourOfDayCard extends ConsumerWidget {
  const _HourOfDayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return _cardShell(
      child: ordersAsync.when(
        loading: () => const SizedBox(
          height: 220,
          child: Center(child: LoadingIndicator()),
        ),
        error: (e, _) => SizedBox(
          height: 220,
          child: Center(
            child: Text(
              'Error: $e',
              style: GoogleFonts.inter(color: AppTokens.danger, fontSize: 12),
            ),
          ),
        ),
        data: (orders) {
          final counts = List<int>.filled(24, 0);
          for (final o in orders.where((o) => o.status != 'cancelled')) {
            counts[_refDate(o).hour]++;
          }
          final maxC = counts.fold<int>(0, math.max);
          final total = counts.fold<int>(0, (a, b) => a + b);
          if (total == 0) {
            return SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  'Sin pedidos para analizar',
                  style: GoogleFonts.inter(color: _kInkMuted, fontSize: 13),
                ),
              ),
            );
          }
          var peakHour = 0;
          for (var i = 1; i < 24; i++) {
            if (counts[i] > counts[peakHour]) peakHour = i;
          }
          return SizedBox(
            height: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hora pico: ${peakHour.toString().padLeft(2, '0')}:00 · ${counts[peakHour]} pedidos',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _kInkMuted,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (ctx, c) {
                      final barW = (c.maxWidth - 24 * 2) / 24;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < 24; i++)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1),
                              child: Tooltip(
                                message:
                                    '${i.toString().padLeft(2, '0')}:00 - ${counts[i]} pedidos',
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: barW.clamp(6, 24),
                                      height: maxC == 0
                                          ? 0
                                          : (counts[i] / maxC) * 140,
                                      decoration: BoxDecoration(
                                        color: i == peakHour
                                            ? AppTokens.brandDark
                                            : AppTokens.brandPrimary
                                                .withValues(alpha: 0.55),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(3),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (i % 3 == 0)
                                      Text(
                                        i.toString().padLeft(2, '0'),
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          color: i == peakHour
                                              ? AppTokens.brandDark
                                              : _kInkSoft,
                                          fontWeight: i == peakHour
                                              ? FontWeight.w800
                                              : FontWeight.w500,
                                        ),
                                      )
                                    else
                                      const SizedBox(height: 11),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP PLATOS
// ─────────────────────────────────────────────────────────────────────────────

class _TopDishesCard extends ConsumerWidget {
  const _TopDishesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminTopDishesProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: async.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: LoadingIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Error: $e',
            style: GoogleFonts.inter(color: AppTokens.danger, fontSize: 12),
          ),
        ),
        data: (dishes) {
          if (dishes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Aun no hay platos vendidos en este periodo',
                  style: GoogleFonts.inter(color: _kInkMuted, fontSize: 13),
                ),
              ),
            );
          }
          return Column(
            children: [
              for (var i = 0; i < dishes.length; i++) ...[
                if (i > 0)
                  Container(height: 1, color: const Color(0xFFF0F0F0)),
                _TopDishRow(rank: i + 1, data: dishes[i]),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TopDishRow extends StatelessWidget {
  const _TopDishRow({required this.rank, required this.data});
  final int rank;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final name = data['name'] as String? ?? '—';
    final qty = (data['quantity'] as num?)?.toInt() ?? 0;
    final revenue = (data['revenue'] as num?)?.toDouble() ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _RankBadge(rank: rank),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _kInk,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$qty uds',
            style: GoogleFonts.inter(fontSize: 12, color: _kInkMuted),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(
              Formatters.price(revenue),
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppTokens.brandPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP CLIENTES
// ─────────────────────────────────────────────────────────────────────────────

class _TopCustomersCard extends ConsumerWidget {
  const _TopCustomersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminUsersStatsProvider);
    final usersAsync = ref.watch(adminUsersProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: statsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(40),
          child: Center(child: LoadingIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Error: $e',
            style: GoogleFonts.inter(color: AppTokens.danger, fontSize: 12),
          ),
        ),
        data: (stats) {
          if (stats.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'Sin clientes con pedidos aun',
                  style: GoogleFonts.inter(color: _kInkMuted, fontSize: 13),
                ),
              ),
            );
          }
          final entries = stats.entries.toList()
            ..sort((a, b) => (b.value['total_spent'] as double)
                .compareTo(a.value['total_spent'] as double));
          final top = entries.take(5).toList();

          final users = usersAsync.valueOrNull ?? const [];
          String nameFor(String uid) {
            for (final u in users) {
              if (u.id == uid) {
                return u.fullName?.trim().isNotEmpty ?? false
                    ? u.fullName!
                    : u.email;
              }
            }
            return 'Cliente';
          }

          return Column(
            children: [
              for (var i = 0; i < top.length; i++) ...[
                if (i > 0)
                  Container(height: 1, color: const Color(0xFFF0F0F0)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      _RankBadge(rank: i + 1),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameFor(top[i].key),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _kInk,
                              ),
                            ),
                            Text(
                              '${top[i].value['orders_count']} pedidos',
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                color: _kInkMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 90,
                        child: Text(
                          Formatters.price(
                              top[i].value['total_spent'] as double),
                          textAlign: TextAlign.right,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppTokens.brandPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    final isPodium = rank <= 3;
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: isPodium
            ? const LinearGradient(
                colors: [AppTokens.brandPrimary, AppTokens.brandDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPodium ? null : AppTokens.brandLight,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        '$rank',
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w800,
          fontSize: 13,
          color: isPodium ? Colors.white : AppTokens.brandDark,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPARKLINE PAINTER (duplicado para no exponer api privada del dashboard)
// ─────────────────────────────────────────────────────────────────────────────

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

    final last = pointAt(series.length - 1);
    canvas
      ..drawCircle(last, 5, Paint()..color = Colors.white)
      ..drawCircle(last, 3, Paint()..color = const Color(0xFF0F6E56));
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.series != series;
}
