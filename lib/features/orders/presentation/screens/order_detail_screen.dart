import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_item.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';

class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailProvider(orderId));
    final itemsAsync = ref.watch(orderItemsProvider(orderId));

    if (orderAsync.isLoading || itemsAsync.isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (orderAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del pedido')),
        body: ErrorView(
          message: orderAsync.error.toString(),
          onRetry: () => ref.invalidate(orderDetailProvider(orderId)),
        ),
      );
    }

    if (itemsAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del pedido')),
        body: ErrorView(
          message: itemsAsync.error.toString(),
          onRetry: () => ref.invalidate(orderItemsProvider(orderId)),
        ),
      );
    }

    final order = orderAsync.value!;
    final items = itemsAsync.value!;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del pedido')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OrderSummary(order: order),
          const SizedBox(height: 16),
          Text(
            'Productos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay productos asociados a este pedido.'),
              ),
            )
          else
            ...items.map(_OrderItemTile.new),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pedido ${order.id.substring(0, 8).toUpperCase()}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _InfoLine(label: 'Estado', value: order.status),
            _InfoLine(label: 'Tipo', value: order.orderType),
            _InfoLine(
              label: 'Creado',
              value: Formatters.dateTime(order.createdAt),
            ),
            if (order.scheduledAt != null)
              _InfoLine(
                label: 'Programado',
                value: Formatters.dateTime(order.scheduledAt!),
              ),
            _InfoLine(
              label: 'Subtotal',
              value: Formatters.price(order.subtotal),
            ),
            _InfoLine(
              label: 'Gastos envío',
              value: Formatters.price(order.deliveryFee),
            ),
            const Divider(height: 24),
            _InfoLine(
              label: 'Total',
              value: Formatters.price(order.total),
              isEmphasis: true,
            ),
            if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notas: ${order.notes}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.label,
    required this.value,
    this.isEmphasis = false,
  });

  final String label;
  final String value;
  final bool isEmphasis;

  @override
  Widget build(BuildContext context) {
    final style = isEmphasis
        ? Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            )
        : Theme.of(context).textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text('$label:')),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile(this.item);

  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(item.dishName ?? 'Plato'),
        subtitle: Text('Cantidad: ${item.quantity}'),
        trailing: Text(Formatters.price(item.subtotal)),
      ),
    );
  }
}
