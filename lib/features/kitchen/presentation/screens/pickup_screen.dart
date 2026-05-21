import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/status_badge.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

class PickupScreen extends ConsumerWidget {
  const PickupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrders = ref.watch(pickupReadyOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recogidas listas'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Escanear QR',
            onPressed: () => context.pushNamed(RouteNames.scanner),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizar',
            onPressed: () => ref.invalidate(pickupReadyOrdersProvider),
          ),
        ],
      ),
      body: asyncOrders.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(pickupReadyOrdersProvider),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sin pedidos listos para recoger',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los pedidos de recogida listos aparecerán aquí',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(pickupReadyOrdersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, i) =>
                  _PickupOrderCard(order: orders[i], index: i),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pickup Order Card
// ─────────────────────────────────────────────────────────────────────────────

class _PickupOrderCard extends ConsumerWidget {
  const _PickupOrderCard({required this.order, required this.index});
  final Order order;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = DateTime.now().difference(order.createdAt).inMinutes;
    final isUrgent = elapsed > 20;
    final isPendingPayment = order.paymentStatus == 'pending';

    return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              left: BorderSide(
                color: isUrgent
                    ? AppTokens.danger
                    : AppTokens.badgeRecogidaFg,
                width: 4,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.id.substring(0, 8).toUpperCase()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.dateTime(order.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tiempo transcurrido
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (isUrgent ? AppTokens.danger : AppTokens.badgeRecogidaFg)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: isUrgent
                                ? AppTokens.danger
                                : AppTokens.badgeRecogidaFg,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${elapsed}min',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isUrgent
                                  ? AppTokens.danger
                                  : AppTokens.badgeRecogidaFg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Badges
                Wrap(
                  spacing: 6,
                  children: [
                    OrderTypeBadge.fromString(order.orderType),
                    StatusBadge.fromString(order.status),
                    if (isPendingPayment)
                      _PaymentBadge(paymentMethod: order.paymentMethod ?? ''),
                  ],
                ),
                const SizedBox(height: 10),
                // Total
                Row(
                  children: [
                    Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Formatters.price(order.total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    // Botón escanear QR
                    OutlinedButton.icon(
                      onPressed: () => context.pushNamed(RouteNames.scanner),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTokens.badgeRecogidaFg),
                        foregroundColor: AppTokens.badgeRecogidaFg,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 16),
                      label: const Text('Escanear QR', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    // Botón entregar y cobrar
                    FilledButton.icon(
                      onPressed: () => _confirmDelivery(context, ref, order),
                      style: FilledButton.styleFrom(
                        backgroundColor: isPendingPayment
                            ? Colors.teal
                            : AppTokens.brandPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: Text(
                        isPendingPayment ? 'Entregar y cobrar' : 'Entregar',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 250.ms, delay: (index * 40).ms)
        .slideX(begin: -0.04, end: 0, duration: 250.ms, delay: (index * 40).ms);
  }

  void _confirmDelivery(BuildContext context, WidgetRef ref, Order order) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar entrega'),
        content: Text(
          '¿Entregar el pedido #${order.id.substring(0, 8).toUpperCase()} '
          'y marcarlo como cobrado?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(employeeOrderActionProvider.notifier)
                  .markDeliveredAndPaid(order.id);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.paymentMethod});
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final label = switch (paymentMethod) {
      'cash' => 'Efectivo pendiente',
      'tpv' => 'TPV pendiente',
      _ => 'Pago pendiente',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.orange,
        ),
      ),
    );
  }
}
