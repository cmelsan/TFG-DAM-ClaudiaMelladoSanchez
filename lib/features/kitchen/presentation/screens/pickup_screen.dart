import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/status_badge.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_extensions.dart';

// ── Design tokens (unificados) ──────────────────────────────────────────────

const _kBg = Color(0xFFF7F8FA);
const _kSurface = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFEAEBF0);
const _kTextPrimary = Color(0xFF111827);
const _kTextMuted = Color(0xFF6B7280);

class PickupScreen extends ConsumerWidget {
  const PickupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncOrders = ref.watch(pickupReadyOrdersProvider);

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Recogidas listas',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.qr_code_scanner_rounded, color: _kTextPrimary),
            tooltip: 'Escanear QR',
            onPressed: () => context.pushNamed(RouteNames.scanner),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppTokens.brandPrimary),
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppTokens.brandLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 38,
                      color: AppTokens.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Sin pedidos listos para recoger',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Los pedidos de recogida listos aparecerán aquí',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: _kTextMuted),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTokens.brandPrimary,
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
            color: _kSurface,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            border: Border.all(color: _kBorder),
            boxShadow: [AppTokens.cardShadow],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isUrgent
                        ? AppTokens.danger
                        : AppTokens.badgeRecogidaFg,
                    width: 4,
                  ),
                ),
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
                            '#${order.shortId}',
                            style: GoogleFonts.jetBrainsMono(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: _kTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.dateTime(order.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _kTextMuted,
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
                        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
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
                            style: GoogleFonts.inter(
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
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _kTextMuted,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Formatters.price(order.total),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _kTextPrimary,
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
        ),   // close inner Container (left border decoration)
        ),   // close ClipRRect
        )    // close outer Container
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
          '¿Entregar el pedido #${order.shortId} '
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
