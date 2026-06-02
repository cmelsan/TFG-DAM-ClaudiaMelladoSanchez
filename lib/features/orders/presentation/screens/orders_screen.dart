import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/status_badge.dart';
import 'package:sabor_de_casa/core/widgets/web_footer.dart';
import 'package:sabor_de_casa/core/widgets/web_navbar.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_extensions.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_item.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kActiveStatuses = {
  'pending',
  'confirmed',
  'preparing',
  'ready',
  'delivering',
};

// ── Screen ────────────────────────────────────────────────────────────────────

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _group = 'all';
  String _type = 'all';
  String _query = '';
  bool _isScrolled = false;
  late final TextEditingController _searchCtrl;
  late final ScrollController _scrollCtrl;

  static const _typeOptions = <(String, String, IconData)>[
    ('all', 'Todos', Icons.all_inclusive_rounded),
    ('mostrador', 'Mostrador', Icons.storefront_rounded),
    ('encargo', 'Encargo', Icons.assignment_rounded),
    ('domicilio', 'Domicilio', Icons.delivery_dining_rounded),
    ('recogida', 'Recogida', Icons.directions_walk_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController()
      ..addListener(() {
        final value = _searchCtrl.text.trim().toLowerCase();
        if (value != _query) setState(() => _query = value);
      });
    _scrollCtrl = ScrollController()
      ..addListener(() {
        final s = _scrollCtrl.offset > 10;
        if (s != _isScrolled) setState(() => _isScrolled = s);
      });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<Order> _applyFilter(List<Order> orders) {
    return orders.where((o) {
      final groupOk = switch (_group) {
        'active' => _kActiveStatuses.contains(o.status),
        'scheduled' => o.scheduledAt != null && o.status != 'cancelled',
        'done' => o.status == 'delivered',
        'cancelled' => o.status == 'cancelled',
        _ => true,
      };
      if (!groupOk || (_type != 'all' && o.orderType != _type)) return false;
      if (_query.isEmpty) return true;

      final searchable = [
        o.id,
        o.shortId,
        o.orderType,
        o.status,
        o.paymentMethod,
        o.notes,
      ].whereType<String>().join(' ').toLowerCase();
      return searchable.contains(_query);
    }).toList();
  }

  int _count(List<Order> orders, String group) => switch (group) {
    'active' => orders.where((o) => _kActiveStatuses.contains(o.status)).length,
    'scheduled' =>
      orders
          .where((o) => o.scheduledAt != null && o.status != 'cancelled')
          .length,
    'done' => orders.where((o) => o.status == 'delivered').length,
    'cancelled' => orders.where((o) => o.status == 'cancelled').length,
    _ => orders.length,
  };

  Map<String, List<Order>> _groupByDate(List<Order> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(now.year, now.month);
    final grouped = <String, List<Order>>{};

    for (final order in orders) {
      final created = order.createdAt;
      final day = DateTime(created.year, created.month, created.day);
      final label = day == today
          ? 'Hoy'
          : day.isAfter(weekStart.subtract(const Duration(days: 1)))
          ? 'Esta semana'
          : day.isAfter(monthStart.subtract(const Duration(days: 1)))
          ? 'Este mes'
          : 'Anteriores';
      grouped.putIfAbsent(label, () => <Order>[]).add(order);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final screenW = MediaQuery.sizeOf(context).width;
    final hPad = screenW > 1200 ? (screenW - 1200) / 2 + 24.0 : 24.0;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: WebNavbar(
          isScrolled: _isScrolled,
          activeRoute: RouteNames.orders,
        ),
      ),
      body: ordersAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(ordersProvider),
        ),
        data: (allOrders) {
          final total = allOrders.fold<double>(0, (s, o) => s + o.total);
          final avgTicket = allOrders.isEmpty ? 0.0 : total / allOrders.length;
          final activeCount = _count(allOrders, 'active');
          final filtered = _applyFilter(allOrders);
          final activeOrder = allOrders
              .where((order) => _kActiveStatuses.contains(order.status))
              .firstOrNull;
          final grouped = _groupByDate(filtered);

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(ordersProvider),
            child: CustomScrollView(
              controller: _scrollCtrl,
              slivers: [
                // ── Cabecera compacta ──────────────────────────────────────
                SliverToBoxAdapter(
                  child: _PageHeader(
                    total: total,
                    count: allOrders.length,
                    avgTicket: avgTicket,
                    activeOrder: activeOrder,
                    hPad: hPad,
                  ),
                ),
                // ── Barra de filtros ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: _FilterBar(
                    allOrders: allOrders,
                    group: _group,
                    type: _type,
                    searchCtrl: _searchCtrl,
                    typeOptions: _typeOptions,
                    countFn: _count,
                    onGroupChange: (v) => setState(() => _group = v),
                    onTypeChange: (v) => setState(() => _type = v),
                    hPad: hPad,
                  ),
                ),
                // ── Banner en curso ────────────────────────────────────────
                if ((_group == 'all' || _group == 'active') && activeCount > 0)
                  SliverToBoxAdapter(
                    child: _ActiveBanner(count: activeCount, hPad: hPad),
                  ),
                // ── Contenido ─────────────────────────────────────────────
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      isFiltered: _group != 'all' || _type != 'all',
                      onClear: () => setState(() {
                        _group = 'all';
                        _type = 'all';
                        _searchCtrl.clear();
                      }),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 80),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        for (final entry in grouped.entries) ...[
                          _DateSectionHeader(
                            label: entry.key,
                            count: entry.value.length,
                          ),
                          const SizedBox(height: 12),
                          for (final order in entry.value)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _OrderCard(order: order),
                            ),
                          const SizedBox(height: 12),
                        ],
                      ]),
                    ),
                  ),
                // ── Footer ────────────────────────────────────────────────
                const SliverToBoxAdapter(child: WebFooter()),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.total,
    required this.count,
    required this.avgTicket,
    required this.activeOrder,
    required this.hPad,
  });

  final double total;
  final int count;
  final double avgTicket;
  final Order? activeOrder;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEECEA))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 30, hPad, 30),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 860;
                final titleBlock = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 13,
                              color: Color(0xFF888886),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Volver',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF888886),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Mis pedidos',
                      style: GoogleFonts.inter(
                        fontSize: wide ? 42 : 34,
                        fontWeight: FontWeight.w900,
                        color: AppTokens.surfaceDark,
                        letterSpacing: -1.1,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sigue tus pedidos activos y consulta compras anteriores.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF777673),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _StatPill(
                          icon: Icons.receipt_long_outlined,
                          label: '$count pedidos',
                        ),
                        _StatPill(
                          icon: Icons.payments_outlined,
                          label: Formatters.price(total),
                        ),
                        _StatPill(
                          icon: Icons.show_chart_rounded,
                          label: count == 0
                              ? 'Sin ticket medio'
                              : 'Ticket medio ${Formatters.price(avgTicket)}',
                        ),
                      ],
                    ),
                  ],
                );

                final activeCard = activeOrder == null
                    ? _NoActiveOrderCard(
                        onTap: () => context.goNamed(RouteNames.menu),
                      )
                    : _ActiveOrderCard(order: activeOrder!);

                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      titleBlock,
                      const SizedBox(height: 22),
                      activeCard,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: titleBlock),
                    const SizedBox(width: 32),
                    SizedBox(width: 430, child: activeCard),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4F1),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppTokens.brandPrimary),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTokens.brandDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusProgress extends StatelessWidget {
  const _StatusProgress({required this.status});
  final String status;

  static const _steps = ['pending', 'confirmed', 'preparing', 'ready'];

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = status == 'delivering' || status == 'delivered'
        ? 'ready'
        : status;
    final current = status == 'cancelled'
        ? -1
        : _steps.indexOf(effectiveStatus).clamp(0, _steps.length - 1);
    final color = status == 'cancelled'
        ? AppTokens.statusCancelado
        : StatusBadge.colorFor(status);

    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 6,
              decoration: BoxDecoration(
                color: i <= current ? color : const Color(0xFFE9E3DD),
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
            ),
          ),
          if (i < _steps.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _OrderUi {
  const _OrderUi._();

  static IconData typeIcon(String type) => switch (type) {
    'domicilio' => Icons.delivery_dining_rounded,
    'recogida' => Icons.directions_walk_rounded,
    'encargo' => Icons.assignment_rounded,
    _ => Icons.storefront_rounded,
  };

  static IconData paymentIcon(String? method) => switch (method) {
    'efectivo' => Icons.payments_rounded,
    'tarjeta' || 'stripe' => Icons.credit_card_rounded,
    _ => Icons.payment_rounded,
  };

  static String paymentLabel(String? method) => switch (method) {
    'efectivo' => 'Efectivo',
    'tarjeta' => 'Tarjeta',
    'stripe' => 'Stripe',
    _ => 'Pago',
  };

  static String subtitle(Order order) {
    if (order.status == 'ready' && order.orderType == 'recogida') {
      return 'Ya puedes recogerlo. En el detalle tienes el QR.';
    }
    if (order.status == 'delivering') {
      return 'Va de camino a tu direccion.';
    }
    if (order.status == 'delivered') {
      return 'Pedido completado. Puedes descargar el ticket o valorarlo.';
    }
    if (order.status == 'cancelled') {
      return 'Pedido cancelado.';
    }
    if (order.scheduledAt != null) {
      return 'Programado para ${Formatters.dateTime(order.scheduledAt!)}.';
    }
    return switch (order.status) {
      'pending' => 'Estamos revisando tu pedido.',
      'confirmed' => 'Pedido confirmado y en cola de cocina.',
      'preparing' => 'Cocina esta preparando tu pedido.',
      'ready' => 'Tu pedido esta listo.',
      _ => 'Consulta todos los detalles del pedido.',
    };
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final color = StatusBadge.colorFor(order.status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF4),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: AppTokens.brandPrimary.withValues(alpha: 0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTokens.brandPrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: Icon(_OrderUi.typeIcon(order.orderType), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido en curso',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTokens.brandPrimary,
                      ),
                    ),
                    Text(
                      order.shortId,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTokens.surfaceDark,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge.fromString(order.status),
            ],
          ),
          const SizedBox(height: 18),
          _StatusProgress(status: order.status),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  _OrderUi.subtitle(order),
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    height: 1.4,
                    color: const Color(0xFF6F6257),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => context.pushNamed(
                  RouteNames.orderDetail,
                  pathParameters: {'orderId': order.id},
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Seguir'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTokens.brandPrimary,
                  minimumSize: const Size(0, 40),
                  shape: const StadiumBorder(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoActiveOrderCard extends StatelessWidget {
  const _NoActiveOrderCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7F5),
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFE7E2DD)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: AppTokens.brandPrimary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No tienes pedidos activos',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTokens.surfaceDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'El menú está listo cuando quieras repetir.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF777673),
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: onTap,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppTokens.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.allOrders,
    required this.group,
    required this.type,
    required this.searchCtrl,
    required this.typeOptions,
    required this.countFn,
    required this.onGroupChange,
    required this.onTypeChange,
    required this.hPad,
  });

  final List<Order> allOrders;
  final String group;
  final String type;
  final TextEditingController searchCtrl;
  final List<(String, String, IconData)> typeOptions;
  final int Function(List<Order>, String) countFn;
  final ValueChanged<String> onGroupChange;
  final ValueChanged<String> onTypeChange;
  final double hPad;

  static const _groups = <(String, String)>[
    ('all', 'Todos'),
    ('active', 'En curso'),
    ('scheduled', 'Programados'),
    ('done', 'Completados'),
    ('cancelled', 'Cancelados'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEECEA))),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 18, hPad, 4),
            child: TextField(
              controller: searchCtrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar por numero, estado, tipo o nota',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: searchCtrl.clear,
                        icon: const Icon(Icons.close_rounded),
                      ),
                filled: true,
                fillColor: const Color(0xFFF7F5F2),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  borderSide: const BorderSide(color: Color(0xFFE8E2DC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  borderSide: const BorderSide(color: AppTokens.brandPrimary),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: hPad),
              itemCount: _groups.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final (value, label) = _groups[i];
                final cnt = countFn(allOrders, value);
                return _GroupTab(
                  label: label,
                  count: cnt,
                  selected: group == value,
                  onTap: () => onGroupChange(value),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: typeOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final (value, label, icon) = typeOptions[i];
                  return _TypeChip(
                    label: label,
                    icon: icon,
                    selected: type == value,
                    onTap: () => onTypeChange(value),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTab extends StatelessWidget {
  const _GroupTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppTokens.brandPrimary : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? AppTokens.brandPrimary
                    : const Color(0xFF666664),
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTokens.brandPrimary
                      : const Color(0xFFEEECEA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : const Color(0xFF666664),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppTokens.brandPrimary.withValues(alpha: 0.10)
              : const Color(0xFFF2F1EF),
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(
            color: selected ? AppTokens.brandPrimary : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected
                  ? AppTokens.brandPrimary
                  : const Color(0xFF888886),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? AppTokens.brandPrimary
                    : const Color(0xFF666664),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Active orders banner ──────────────────────────────────────────────────────

class _ActiveBanner extends StatelessWidget {
  const _ActiveBanner({required this.count, required this.hPad});
  final int count;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTokens.brandLight,
      padding: EdgeInsets.fromLTRB(hPad, 10, hPad, 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTokens.brandPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$count pedido${count == 1 ? '' : 's'} en curso'
            ' — te avisaremos cuando estén listos',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTokens.brandDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Order card ────────────────────────────────────────────────────────────────

class _DateSectionHeader extends StatelessWidget {
  const _DateSectionHeader({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTokens.surfaceDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF0ECE8),
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF746C64),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _hovering = false;
  bool _repeating = false;

  static Color _statusColor(String s) => switch (s) {
    'pending' => AppTokens.statusPendiente,
    'confirmed' => AppTokens.statusConfirmado,
    'preparing' => AppTokens.statusPreparando,
    'ready' => AppTokens.statusListo,
    'delivering' => AppTokens.statusReparto,
    'delivered' => AppTokens.statusEntregado,
    'cancelled' => AppTokens.statusCancelado,
    _ => AppTokens.brandPrimary,
  };

  Future<void> _repeatOrder() async {
    if (_repeating) return;
    setState(() => _repeating = true);
    try {
      final items = await ref.read(orderItemsProvider(widget.order.id).future);
      if (items.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este pedido no tiene productos para repetir.'),
          ),
        );
        return;
      }

      for (final item in items) {
        ref
            .read(cartNotifierProvider.notifier)
            .addItem(
              CartItem(
                dishId: item.dishId,
                name: item.dishName ?? 'Plato del pedido',
                unitPrice: item.unitPrice,
                quantity: item.quantity,
                imageUrl: item.dishImageUrl,
              ),
            );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${items.length} producto${items.length == 1 ? '' : 's'} añadido${items.length == 1 ? '' : 's'} al carrito',
          ),
          action: SnackBarAction(
            label: 'Ver carrito',
            onPressed: () => context.goNamed(RouteNames.cart),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se ha podido repetir el pedido.')),
      );
    } finally {
      if (mounted) setState(() => _repeating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final sc = _statusColor(o.status);
    final isActive = _kActiveStatuses.contains(o.status);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(
            color: _hovering
                ? const Color(0xFFE4D8CC)
                : const Color(0xFFEDEAE6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovering ? 0.09 : 0.04),
              blurRadius: _hovering ? 22 : 8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          child: Container(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: sc, width: 5)),
            ),
            padding: const EdgeInsets.all(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 760;
                final header = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: sc.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      ),
                      child: Icon(
                        _OrderUi.typeIcon(o.orderType),
                        color: sc,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                o.shortId,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTokens.surfaceDark,
                                ),
                              ),
                              OrderTypeBadge.fromString(o.orderType),
                              if (isActive) const _LiveBadge(),
                            ],
                          ),
                          const SizedBox(height: 7),
                          Wrap(
                            spacing: 12,
                            runSpacing: 6,
                            children: [
                              _MetaItem(
                                icon: Icons.schedule_rounded,
                                label: Formatters.dateTime(o.createdAt),
                              ),
                              if (o.paymentMethod != null)
                                _MetaItem(
                                  icon: _OrderUi.paymentIcon(o.paymentMethod),
                                  label: _OrderUi.paymentLabel(o.paymentMethod),
                                ),
                              if (o.scheduledAt != null)
                                _MetaItem(
                                  icon: Icons.event_available_rounded,
                                  label:
                                      'Programado ${Formatters.dateTime(o.scheduledAt!)}',
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (wide) ...[
                      const SizedBox(width: 16),
                      _TotalBlock(order: o),
                    ],
                  ],
                );

                final actions = Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: [
                    _ActionButton(
                      label: _repeating ? 'Añadiendo...' : 'Repetir',
                      icon: Icons.replay_rounded,
                      onTap: _repeatOrder,
                      filled: false,
                    ),
                    _ActionButton(
                      label: o.status == 'delivered'
                          ? 'Ticket y valorar'
                          : 'Ver detalle',
                      icon: Icons.arrow_forward_ios_rounded,
                      iconSize: 10,
                      onTap: () => context.pushNamed(
                        RouteNames.orderDetail,
                        pathParameters: {'orderId': o.id},
                      ),
                      filled: _hovering,
                    ),
                  ],
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    if (!wide) ...[
                      const SizedBox(height: 14),
                      _TotalBlock(order: o),
                    ],
                    const SizedBox(height: 16),
                    _OrderItemsPreview(orderId: o.id),
                    const SizedBox(height: 16),
                    _StatusProgress(status: o.status),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        StatusBadge.fromString(o.status),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _OrderUi.subtitle(o),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF777673),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: wide ? 1 : 2,
                          ),
                        ),
                        if (wide) actions,
                      ],
                    ),
                    if (!wide) ...[
                      const SizedBox(height: 14),
                      Align(alignment: Alignment.centerRight, child: actions),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TotalBlock extends StatelessWidget {
  const _TotalBlock({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          Formatters.price(order.total),
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppTokens.brandDark,
            letterSpacing: -0.5,
          ),
        ),
        if (order.discountAmount > 0)
          Text(
            '- ${Formatters.price(order.discountAmount)} dto.',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTokens.brandPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTokens.brandLight,
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTokens.brandPrimary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'En curso',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppTokens.brandDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFFAAA39B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: const Color(0xFF8D8780),
          ),
        ),
      ],
    );
  }
}

class _OrderItemsPreview extends ConsumerWidget {
  const _OrderItemsPreview({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(orderItemsProvider(orderId));
    return itemsAsync.when(
      loading: () =>
          const _PreviewShell(label: 'Cargando productos...', items: []),
      error: (_, __) => const _PreviewShell(
        label: 'No se pudieron cargar los productos',
        items: [],
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _PreviewShell(
            label: 'Sin productos asociados',
            items: [],
          );
        }
        final names = items
            .take(2)
            .map((item) => item.dishName ?? 'Plato')
            .join(', ');
        final remaining = items.length - 2;
        final label = remaining > 0 ? '$names y $remaining mas' : names;
        return _PreviewShell(label: label, items: items);
      },
    );
  }
}

class _PreviewShell extends StatelessWidget {
  const _PreviewShell({required this.label, required this.items});
  final String label;
  final List<OrderItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: const Color(0xFFEDE7E1)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            height: 34,
            child: Stack(
              children: [
                for (final indexed in items.take(3).indexed)
                  Positioned(
                    left: indexed.$1 * 24,
                    child: _DishThumb(item: indexed.$2),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTokens.surfaceDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DishThumb extends StatelessWidget {
  const _DishThumb({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.dishImageUrl;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null || imageUrl.isEmpty
          ? const Icon(
              Icons.restaurant_rounded,
              size: 16,
              color: AppTokens.brandPrimary,
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.restaurant_rounded,
                size: 16,
                color: AppTokens.brandPrimary,
              ),
            ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.filled,
    this.iconSize = 14,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? AppTokens.brandPrimary : AppTokens.brandLight,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : AppTokens.brandPrimary,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              icon,
              size: iconSize,
              color: filled ? Colors.white : AppTokens.brandPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isFiltered, required this.onClear});
  final bool isFiltered;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTokens.brandLight,
                  borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                ),
                child: Icon(
                  isFiltered
                      ? Icons.filter_list_off_rounded
                      : Icons.receipt_long_rounded,
                  size: 38,
                  color: AppTokens.brandPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isFiltered ? 'Sin resultados' : 'Aún no tienes pedidos',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTokens.surfaceDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isFiltered
                    ? 'No hay pedidos que coincidan\ncon los filtros seleccionados.'
                    : 'Cuando realices tu primer pedido\naparecerá aquí.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF999898),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (isFiltered)
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTokens.brandLight,
                      borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                    ),
                    child: Text(
                      'Limpiar filtros',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTokens.brandPrimary,
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: () => context.goNamed(RouteNames.menu),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTokens.brandPrimary,
                      minimumSize: const Size(0, 44),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                    ),
                    child: Text(
                      'Ver menú',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
