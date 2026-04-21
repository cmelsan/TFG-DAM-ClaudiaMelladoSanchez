import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

class KitchenScreen extends ConsumerWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(kitchenOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Panel Cocina')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No hay pedidos en cocina'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (_, index) => _KitchenOrderTile(order: orders[index]),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(kitchenOrdersProvider),
        ),
      ),
    );
  }
}

class _KitchenOrderTile extends ConsumerWidget {
  const _KitchenOrderTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text('Pedido ${order.id.substring(0, 8).toUpperCase()}'),
        subtitle: Text(
          'Tipo: ${order.orderType} • ${Formatters.dateTime(order.createdAt)}',
        ),
        trailing: DropdownButton<String>(
          value: order.status,
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
            DropdownMenuItem(value: 'confirmed', child: Text('Confirmado')),
            DropdownMenuItem(value: 'preparing', child: Text('Preparando')),
            DropdownMenuItem(value: 'ready', child: Text('Listo')),
          ],
          onChanged: (value) {
            if (value == null) return;
            ref.read(employeeOrderActionProvider.notifier).updateStatus(
                  orderId: order.id,
                  newStatus: value,
                );
          },
        ),
      ),
    );
  }
}
