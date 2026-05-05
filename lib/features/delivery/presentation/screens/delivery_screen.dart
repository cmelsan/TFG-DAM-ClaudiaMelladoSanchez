import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
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
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(
        title: const Text('Panel Reparto'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(deliveryOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.two_wheeler,
                    size: 80,
                    color: const Color(0xFFE5E5E3).withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay pedidos para repartir',
                    style: TextStyle(color: Colors.black54, fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
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
    final cardColor = isReady
        ? Colors.white
        : AppTokens.brandPrimary.withValues(alpha: 0.05);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isReady ? const Color(0xFFE5E5E3) : AppTokens.brandPrimary,
          width: isReady ? 1 : 2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cabecera del ticket
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isReady ? const Color(0xFFE5E5E3) : AppTokens.brandPrimary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id.substring(0, 6).toUpperCase()}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isReady ? const Color(0xFF111111) : Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    TimeOfDay.fromDateTime(order.createdAt).format(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Información de entrega
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Dirección de entrega',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.addressId != null
                      ? 'Dirección registrada\n(ID: ${order.addressId!.substring(0, 8)}…)'
                      : 'Sin dirección registrada',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.black54, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Cliente',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.userId != null
                      ? 'Cliente: ${order.userId!.substring(0, 8)}…'
                      : 'Sin datos de cliente',
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Importe a cobrar:',
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    Text(
                      Formatters.price(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Badge indicando si cobra efectivo o ya está pagado
                _PaymentBadge(order: order),
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(16).copyWith(top: 0),
            child: SizedBox(
              height: 56,
              child: isReady
                  ? FilledButton.icon(
                      onPressed: () => ref
                          .read(employeeOrderActionProvider.notifier)
                          .assignToMe(order.id),
                      icon: const Icon(Icons.delivery_dining),
                      label: const Text(
                        'Comenzar reparto',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTokens.brandPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : _buildDeliverButton(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  /// Si el pago es en efectivo → al entregar se marca entregado + cobrado en una llamada.
  /// Si ya está pagado con tarjeta → solo actualiza estado.
  Widget _buildDeliverButton(BuildContext context, WidgetRef ref) {
    final isCash = order.paymentMethod == 'cash';
    final label = isCash ? 'Entregado y cobrado' : 'Marcar como entregado';
    final icon = isCash ? Icons.payments_outlined : Icons.check_circle_outline;

    return FilledButton.icon(
      onPressed: () async {
        if (isCash) {
          // Doble confirmación: se le recuerda al repartidor que tiene que cobrar
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Confirmar cobro'),
              content: Text(
                '¿Has cobrado ${Formatters.price(order.total)} en efectivo al cliente?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Sí, cobrado'),
                ),
              ],
            ),
          );
          if (confirmed ?? false) {
            await ref
                .read(employeeOrderActionProvider.notifier)
                .markDeliveredAndPaid(order.id);
          }
        } else {
          await ref
              .read(employeeOrderActionProvider.notifier)
              .updateStatus(orderId: order.id, newStatus: 'delivered');
        }
      },
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: isCash ? Colors.orange.shade700 : Colors.blue.shade700,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

/// Badge que muestra el estado del pago en la tarjeta del repartidor.
class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    // Ya pagado (tarjeta online)
    if (order.paymentStatus == 'paid') {
      return _chip(
        Icons.check_circle,
        'Pagado con tarjeta',
        Colors.green.shade700,
      );
    }
    // Pendiente en efectivo → el repartidor tiene que cobrar
    if (order.paymentMethod == 'cash') {
      return _chip(
        Icons.money,
        'COBRAR EN EFECTIVO',
        Colors.orange.shade800,
        bold: true,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _chip(IconData icon, String label, Color color, {bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
