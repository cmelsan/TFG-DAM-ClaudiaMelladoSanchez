import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/filter_chips.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/order_card.dart';
import 'package:sabor_de_casa/core/widgets/status_badge.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';

class _FilterState {
  const _FilterState({this.selectedStatus = 'all', this.selectedType = 'all'});
  final String selectedStatus;
  final String selectedType;
  _FilterState copyWith({String? selectedStatus, String? selectedType}) =>
      _FilterState(
        selectedStatus: selectedStatus ?? this.selectedStatus,
        selectedType: selectedType ?? this.selectedType,
      );
}

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  _FilterState _filter = const _FilterState();

  static const _statusOptions = [
    FilterOption(label: 'Todos', value: 'all'),
    FilterOption(label: 'Pendiente', value: 'pending'),
    FilterOption(label: 'Confirmado', value: 'confirmed'),
    FilterOption(label: 'En cocina', value: 'preparing'),
    FilterOption(label: 'Listo', value: 'ready'),
    FilterOption(label: 'Entregado', value: 'delivered'),
    FilterOption(label: 'Cancelado', value: 'cancelled'),
  ];

  static const _typeOptions = [
    TypeChipOption(
      label: 'Todos',
      value: 'all',
      icon: Icons.all_inclusive_rounded,
    ),
    TypeChipOption(
      label: 'Mostrador',
      value: 'mostrador',
      icon: Icons.storefront_rounded,
    ),
    TypeChipOption(
      label: 'Encargo',
      value: 'encargo',
      icon: Icons.assignment_rounded,
    ),
    TypeChipOption(
      label: 'Domicilio',
      value: 'domicilio',
      icon: Icons.delivery_dining_rounded,
    ),
    TypeChipOption(
      label: 'Recogida',
      value: 'recogida',
      icon: Icons.directions_walk_rounded,
    ),
  ];

  List<Order> _applyFilter(List<Order> orders) {
    return orders.where((o) {
      final statusOk =
          _filter.selectedStatus == 'all' || o.status == _filter.selectedStatus;
      final typeOk =
          _filter.selectedType == 'all' || o.orderType == _filter.selectedType;
      return statusOk && typeOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis pedidos'), centerTitle: true),
      body: ordersAsync.when(
        data: (allOrders) {
          final total = allOrders.fold<double>(0, (s, o) => s + o.total);
          final avgTicket = allOrders.isEmpty ? 0.0 : total / allOrders.length;
          final filtered = _applyFilter(allOrders);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ordersProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: DarkSummaryBar(
                    items: [
                      MetricItem(
                        label: 'Total gastado',
                        value: Formatters.price(total),
                      ),
                      MetricItem(
                        label: 'Pedidos',
                        value: '${allOrders.length}',
                      ),
                      MetricItem(
                        label: 'Ticket medio',
                        value: Formatters.price(avgTicket),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: FilterChipRow(
                    options: _statusOptions,
                    selected: _filter.selectedStatus,
                    onSelected: (v) => setState(
                      () => _filter = _filter.copyWith(selectedStatus: v),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: TypeChipRow(
                    options: _typeOptions,
                    selected: _filter.selectedType,
                    onSelected: (v) => setState(
                      () => _filter = _filter.copyWith(selectedType: v),
                    ),
                  ),
                ),
                if (filtered.isEmpty)
                  const SliverFillRemaining(child: _EmptyOrders())
                else ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
                      child: SectionHeader('Historial'),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ClientOrderCard(order: filtered[i]),
                        ),
                        childCount: filtered.length,
                      ),
                    ),
                  ),
                ],
              ],
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

class _ClientOrderCard extends StatelessWidget {
  const _ClientOrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE8E8E6);

    return InkWell(
      onTap: () => context.pushNamed(
        RouteNames.orderDetail,
        pathParameters: {'orderId': order.id},
      ),
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: borderColor, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.id.substring(0, 8).toUpperCase()}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  StatusBadge.fromString(order.status),
                ],
              ),
            ),
            Divider(height: 0.5, thickness: 0.5, color: borderColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTokens.brandLight,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: const Icon(
                      Icons.fastfood_rounded,
                      color: AppTokens.brandPrimary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OrderTypeBadge.fromString(order.orderType),
                        const SizedBox(height: 4),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.price(order.total),
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Text(
                            'Ver detalles',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTokens.brandPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 2),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 10,
                            color: AppTokens.brandPrimary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
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
                Icons.receipt_long_rounded,
                size: 34,
                color: AppTokens.brandPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin pedidos',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTokens.surfaceDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando finalices una compra,\naparecerá aquí tu historial.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.goNamed(RouteNames.home),
                child: const Text('Empezar a pedir'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
