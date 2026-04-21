import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

class DeliveryScreen extends ConsumerWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(deliveryOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Panel Reparto')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No hay pedidos para reparto'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (_, index) => _DeliveryOrderTile(order: orders[index]),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(deliveryOrdersProvider),
        ),
      ),
    );
  }
}

class _DeliveryOrderTile extends ConsumerWidget {
  const _DeliveryOrderTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isReady = order.status == 'ready';

    return Card(
      child: ListTile(
        title: Text('Pedido ${order.id.substring(0, 8).toUpperCase()}'),
        subtitle: Text(
          '${Formatters.dateTime(order.createdAt)} • '
          'Total ${Formatters.price(order.total)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isReady)
              TextButton(
                onPressed: () => ref
                    .read(employeeOrderActionProvider.notifier)
                    .assignToMe(order.id),
                child: const Text('Asignarme'),
              ),
            if (!isReady)
              TextButton(
                onPressed: () => ref
                    .read(employeeOrderActionProvider.notifier)
                    .updateStatus(orderId: order.id, newStatus: 'delivered'),
                child: const Text('Entregado'),
              ),
          ],
        ),
      ),
    );
  }
}
