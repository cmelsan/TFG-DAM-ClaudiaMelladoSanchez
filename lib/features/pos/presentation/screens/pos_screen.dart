import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(posOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('TPV Mostrador')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: FilledButton.icon(
              onPressed: () => context.goNamed(RouteNames.menu),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Nuevo pedido mostrador (desde menú)'),
            ),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(
                    child: Text('Sin pedidos mostrador hoy'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: orders.length,
                  itemBuilder: (_, index) {
                    final order = orders[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          'Pedido ${order.id.substring(0, 8).toUpperCase()}',
                        ),
                        subtitle: Text(
                          '${Formatters.dateTime(order.createdAt)} • '
                          'Estado ${order.status}',
                        ),
                        trailing: Text(Formatters.price(order.total)),
                      ),
                    );
                  },
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, _) => ErrorView(
                message: error.toString(),
                onRetry: () => ref.invalidate(posOrdersProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
