import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';

// Etiquetas legibles para claves del mapa de stats
const _kStatLabels = {
  'orders_total': 'Pedidos totales',
  'orders_pending': 'Pedidos pendientes',
  'orders_today': 'Pedidos hoy',
  'users_total': 'Usuarios registrados',
  'contacts_unread': 'Mensajes sin leer',
  'events_total': 'Eventos de catering',
};

class AdminStatsScreen extends ConsumerWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return AdminShell(
      title: 'Estadísticas',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTokens.brandPrimary),
          tooltip: 'Actualizar',
          onPressed: () => ref.invalidate(adminDashboardStatsProvider),
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
        data: (stats) {
          final total = (stats['orders_total'] as num?)?.toInt() ?? 0;
          final pending = (stats['orders_pending'] as num?)?.toInt() ?? 0;
          final revenue = (stats['revenue_total'] as num? ?? 0).toDouble();

          final topMetrics = [
            MetricItem(
              label: 'Facturación total',
              value: Formatters.price(revenue),
              valueColor: AppTokens.brandPrimary,
            ),
            MetricItem(label: 'Pedidos totales', value: total.toString()),
            MetricItem(
              label: 'Pendientes',
              value: pending.toString(),
              valueColor: AppTokens.warning,
            ),
          ];

          // Resto de métricas (sin revenue_total que ya está en topMetrics)
          final detailEntries = stats.entries
              .where((e) => e.key != 'revenue_total')
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            children: [
              // Barra de resumen oscura
              DarkSummaryBar(items: topMetrics),
              const SizedBox(height: 28),

              // Ingresos destacados
              const SectionHeader('Ingresos'),
              const SizedBox(height: 12),
              _RevenueCard(revenue: revenue),
              const SizedBox(height: 24),

              // Desglose de métricas
              const SectionHeader('Métricas generales'),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: [AppTokens.cardShadow],
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < detailEntries.length; i++) ...[
                      if (i > 0)
                        Container(height: 1, color: const Color(0xFFF0F0F0)),
                      _StatRow(
                        label: _kStatLabels[detailEntries[i].key] ??
                            detailEntries[i].key,
                        value: detailEntries[i].value.toString(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Tarjeta de ingresos destacada ─────────────────────────────────────────────

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.revenue});
  final double revenue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D9E75), Color(0xFF0F6E56)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandPrimary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.payments_rounded,
                size: 26, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Facturación acumulada',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                Formatters.price(revenue),
                style: GoogleFonts.syne(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Fila de estadística ───────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: const Color(0xFF555570),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}
