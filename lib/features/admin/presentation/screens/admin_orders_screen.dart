import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Pedidos')),
      body: ordersAsync.when(
        data: (orders) => ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (_, index) {
            final order = orders[index];
            return Card(
              child: ListTile(
                title: Text('Pedido ${order.id.substring(0, 8).toUpperCase()}'),
                subtitle: Text(
                  '${Formatters.dateTime(order.createdAt)} • '
                  '${Formatters.price(order.total)}',
                ),
                trailing: DropdownButton<String>(
                  value: order.status,
                  items: const [
                    DropdownMenuItem(
                      value: 'pending',
                      child: Text('Pendiente'),
                    ),
                    DropdownMenuItem(
                      value: 'confirmed',
                      child: Text('Confirmado'),
                    ),
                    DropdownMenuItem(
                      value: 'preparing',
                      child: Text('Preparando'),
                    ),
                    DropdownMenuItem(value: 'ready', child: Text('Listo')),
                    DropdownMenuItem(
                      value: 'delivering',
                      child: Text('Reparto'),
                    ),
                    DropdownMenuItem(
                      value: 'delivered',
                      child: Text('Entregado'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('Cancelado'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(adminActionProvider.notifier).updateOrderStatus(
                          orderId: order.id,
                          status: value,
                        );
                  },
                ),
              ),
            );
          },
        ),
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(adminOrdersProvider),
        ),
      ),
    );
  }
}
