import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminDashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: statsAsync.when(
        data: (stats) {
          final cards = [
            ('Pedidos', stats['orders_total']?.toInt() ?? 0, Icons.receipt),
            (
              'Pendientes',
              stats['orders_pending']?.toInt() ?? 0,
              Icons.pending_actions,
            ),
            ('Usuarios', stats['users_total']?.toInt() ?? 0, Icons.group),
            ('Eventos', stats['events_total']?.toInt() ?? 0, Icons.event),
            (
              'Mensajes no leídos',
              stats['contacts_unread']?.toInt() ?? 0,
              Icons.mark_email_unread,
            ),
          ];

          final revenue = stats['revenue_total'] ?? 0;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Facturación total'),
                  subtitle: Text(
                    Formatters.price(revenue),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...cards.map(
                (card) => Card(
                  child: ListTile(
                    leading: Icon(card.$3),
                    title: Text(card.$1),
                    trailing: Text(card.$2.toString()),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _NavChip('Platos', RouteNames.adminDishes),
                  _NavChip('Pedidos', RouteNames.adminOrders),
                  _NavChip('Catering', RouteNames.adminCatering),
                  _NavChip('Usuarios', RouteNames.adminUsers),
                  _NavChip('Config', RouteNames.adminConfig),
                  _NavChip('Horario', RouteNames.adminSchedule),
                  _NavChip('Stats', RouteNames.adminStats),
                ].map((chip) {
                  return ActionChip(
                    label: Text(chip.label),
                    onPressed: () => context.goNamed(chip.route),
                  );
                }).toList(),
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

class _NavChip {
  const _NavChip(this.label, this.route);

  final String label;
  final String route;
}
