import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/app_surface.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/status_badge.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

class KitchenScreen extends ConsumerWidget {
  const KitchenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('KDS – Cocina'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Actualizar',
              onPressed: () {
                ref
                  ..invalidate(kitchenOrdersProvider)
                  ..invalidate(encargoKitchenOrdersProvider);
              },
            ),
          ],
          bottom: TabBar(
            indicatorColor: AppTokens.brandPrimary,
            labelColor: AppTokens.brandPrimary,
            unselectedLabelColor: Colors.grey.shade500,
            indicatorWeight: 2.5,
            tabs: const [
              Tab(
                icon: Icon(Icons.local_fire_department_rounded),
                text: 'Cocina',
              ),
              Tab(icon: Icon(Icons.assignment_rounded), text: 'Encargos'),
            ],
          ),
        ),
        body: const TabBarView(children: [_KitchenTab(), _EncargosTab()]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COCINA TAB
// ─────────────────────────────────────────────────────────────────────────────

class _KitchenTab extends ConsumerWidget {
  const _KitchenTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(kitchenOrdersProvider);
    return ordersAsync.when(
      data: (orders) {
        if (orders.isEmpty) {
          return const _EmptyKitchen(
            label: 'Cocina limpia — sin tickets activos',
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 380,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 270,
          ),
          itemCount: orders.length,
          itemBuilder: (_, i) => _KitchenOrderCard(order: orders[i]),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(kitchenOrdersProvider),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENCARGOS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _EncargosTab extends ConsumerWidget {
  const _EncargosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encargosAsync = ref.watch(encargoKitchenOrdersProvider);
    return encargosAsync.when(
      data: (encargos) {
        if (encargos.isEmpty) {
          return const _EmptyKitchen(label: 'Sin encargos en preparación');
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: encargos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _EncargoKitchenCard(order: encargos[i]),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(encargoKitchenOrdersProvider),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COCINA ORDER CARD
// ─────────────────────────────────────────────────────────────────────────────

class _KitchenOrderCard extends ConsumerWidget {
  const _KitchenOrderCard({required this.order});
  final Order order;

  // Urgencia: hace cuánto se creó el pedido
  Color _accentColor() {
    final elapsed = DateTime.now().difference(order.createdAt).inMinutes;
    if (elapsed > 15) return AppTokens.danger;
    if (order.status == 'preparing') return AppTokens.warning;
    return AppTokens.brandPrimary;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPreparing = order.status == 'preparing';
    final accent = _accentColor();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border(left: BorderSide(color: accent, width: 4)),
          boxShadow: [AppTokens.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.id.substring(0, 6).toUpperCase()}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.surfaceDark,
                      ),
                    ),
                  ),
                  StatusBadge.fromString(order.status),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(
                children: [
                  OrderTypeBadge.fromString(order.orderType),
                  const Spacer(),
                  Text(
                    TimeOfDay.fromDateTime(order.createdAt).format(context),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            const Divider(height: 0.5, thickness: 0.5),
            // Timer / elapsed
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  Icon(Icons.timer_rounded, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Text(
                    _elapsedLabel(order.createdAt),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Action button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                height: 44,
                child: FilledButton(
                  onPressed: () {
                    final newStatus = isPreparing ? 'ready' : 'preparing';
                    ref
                        .read(employeeOrderActionProvider.notifier)
                        .updateStatus(orderId: order.id, newStatus: newStatus);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: isPreparing
                        ? AppTokens.success
                        : AppTokens.brandPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                  ),
                  child: Text(
                    isPreparing ? 'MARCAR LISTO' : 'EMPEZAR',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _elapsedLabel(DateTime createdAt) {
    final min = DateTime.now().difference(createdAt).inMinutes;
    if (min < 1) return 'Ahora';
    if (min < 60) return 'Hace ${min}min';
    return 'Hace ${(min / 60).floor()}h ${min % 60}min';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ENCARGO CARD
// ─────────────────────────────────────────────────────────────────────────────

class _EncargoKitchenCard extends ConsumerWidget {
  const _EncargoKitchenCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduledDate = order.scheduledAt;
    final daysUntil = scheduledDate?.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil != null && daysUntil <= 1;
    final isPreparing = order.status == 'preparing';
    final accentColor = isUrgent ? AppTokens.danger : AppTokens.warning;

    return AppSurface(
      borderColor: accentColor.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header fila
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${order.id.substring(0, 6).toUpperCase()}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTokens.surfaceDark,
                  ),
                ),
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTokens.danger,
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  ),
                  child: Text(
                    daysUntil == 0 ? 'HOY' : 'MAÑANA',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Fecha encargo
          if (scheduledDate != null)
            Row(
              children: [
                Icon(Icons.event_rounded, size: 15, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  Formatters.date(scheduledDate),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                if (daysUntil != null && !isUrgent)
                  Text(
                    ' (en $daysUntil días)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
              ],
            ),
          // Notes
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notes_rounded,
                  size: 15,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.notes!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Botón acción
          FilledButton(
            onPressed: () {
              final newStatus = isPreparing ? 'ready' : 'preparing';
              ref
                  .read(employeeOrderActionProvider.notifier)
                  .updateStatus(orderId: order.id, newStatus: newStatus);
            },
            style: FilledButton.styleFrom(
              backgroundColor: isPreparing
                  ? AppTokens.success
                  : AppTokens.warning,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
            ),
            child: Text(
              isPreparing ? 'MARCAR COMO LISTO' : 'EMPEZAR A PREPARAR',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyKitchen extends StatelessWidget {
  const _EmptyKitchen({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppTokens.brandLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 36,
              color: AppTokens.brandPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
