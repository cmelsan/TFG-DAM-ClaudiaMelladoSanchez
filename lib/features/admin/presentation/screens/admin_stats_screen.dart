import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';

class AdminStatsScreen extends ConsumerWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Estadísticas')),
      body: statsAsync.when(
        data: (stats) {
          final total = stats['orders_total'] ?? 0;
          final pending = stats['orders_pending'] ?? 0;
          final deliveredRate = total == 0
              ? 0
              : ((total - pending) / total) * 100;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Facturación'),
                  subtitle: Text(Formatters.price(stats['revenue_total'] ?? 0)),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Pedidos totales'),
                  subtitle: Text(
                    (stats['orders_total'] ?? 0).toStringAsFixed(0),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Pedidos pendientes'),
                  subtitle: Text(
                    (stats['orders_pending'] ?? 0).toStringAsFixed(0),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Tasa de avance'),
                  subtitle: Text('${deliveredRate.toStringAsFixed(1)}%'),
                ),
              ),
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
