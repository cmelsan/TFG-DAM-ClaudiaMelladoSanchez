import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/order_card.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';

class AdminStatsScreen extends ConsumerWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return AdminShell(
      title: 'Estadísticas',
      child: statsAsync.when(
        data: (stats) {
          final total = (stats['orders_total'] as num?)?.toInt() ?? 0;
          final pending = (stats['orders_pending'] as num?)?.toInt() ?? 0;
          final revenue = (stats['revenue_total'] as num? ?? 0).toDouble();

          final metrics = [
            MetricItem(
              label: 'Facturación',
              value: Formatters.price(revenue),
              valueColor: AppTokens.brandPrimary,
            ),
            MetricItem(label: 'Pedidos totales', value: total.toString()),
            MetricItem(
              label: 'Pedidos pendientes',
              value: pending.toString(),
              valueColor: AppTokens.warning,
            ),
          ];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DarkSummaryBar(items: metrics),
              const SizedBox(height: 24),
              const SectionHeader('Desglose'),
              const SizedBox(height: 12),
              for (final e in stats.entries)
                if (e.key != 'revenue_total')
                  _StatRow(label: e.key, value: e.value.toString()),
            ],
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminDashboardStatsProvider),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
