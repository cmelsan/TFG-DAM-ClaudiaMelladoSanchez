import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos')),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const _EmptyOrders();
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ordersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            ),
          );
        },
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(ordersProvider),
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes pedidos',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando finalices una compra aparecerá aquí tu historial.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(order.status);
    final color = _statusColor(context, order.status);

    return Card(
      child: ListTile(
        onTap: () => context.pushNamed(
          RouteNames.orderDetail,
          pathParameters: {'orderId': order.id},
        ),
        title: Text(
          'Pedido ${order.id.substring(0, 8).toUpperCase()}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Fecha: ${Formatters.dateTime(order.createdAt)}'),
            Text('Tipo: ${_orderTypeLabel(order.orderType)}'),
            Text('Total: ${Formatters.price(order.total)}'),
          ],
        ),
        trailing: Chip(
          label: Text(status),
          backgroundColor: color.withValues(alpha: 0.12),
          labelStyle: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
          ),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

String _orderTypeLabel(String value) {
  switch (value) {
    case 'mostrador':
      return 'Mostrador';
    case 'encargo':
      return 'Encargo';
    case 'domicilio':
      return 'Domicilio';
    case 'recogida':
      return 'Recogida';
    default:
      return value;
  }
}

String _statusLabel(String value) {
  switch (value) {
    case 'pending':
      return 'Pendiente';
    case 'confirmed':
      return 'Confirmado';
    case 'preparing':
      return 'Preparando';
    case 'ready':
      return 'Listo';
    case 'delivering':
      return 'En reparto';
    case 'delivered':
      return 'Entregado';
    case 'cancelled':
      return 'Cancelado';
    default:
      return value;
  }
}

Color _statusColor(BuildContext context, String status) {
  final scheme = Theme.of(context).colorScheme;
  switch (status) {
    case 'pending':
      return Colors.orange;
    case 'confirmed':
      return scheme.primary;
    case 'preparing':
      return Colors.deepOrange;
    case 'ready':
      return Colors.teal;
    case 'delivering':
      return Colors.blue;
    case 'delivered':
      return Colors.green;
    case 'cancelled':
      return scheme.error;
    default:
      return scheme.onSurfaceVariant;
  }
}
