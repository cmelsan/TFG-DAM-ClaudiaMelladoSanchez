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
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kActiveStatuses = {'pending', 'confirmed', 'preparing', 'ready'};

// ── Screen ────────────────────────────────────────────────────────────────────

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  String _group = 'all';
  String _type = 'all';
  bool _isScrolled = false;
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
    _scrollCtrl = ScrollController()
      ..addListener(() {
        final s = _scrollCtrl.offset > 10;
        if (s != _isScrolled) setState(() => _isScrolled = s);
      });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<Order> _applyFilter(List<Order> orders) {
    return orders.where((o) {
      final groupOk = switch (_group) {
        'active' => _kActiveStatuses.contains(o.status),
        'done' => o.status == 'delivered',
        'cancelled' => o.status == 'cancelled',
        _ => true,
      };
      return groupOk && (_type == 'all' || o.orderType == _type);
    }).toList();
  }

  int _count(List<Order> orders, String group) => switch (group) {
        'active' =>
          orders.where((o) => _kActiveStatuses.contains(o.status)).length,
        'done' => orders.where((o) => o.status == 'delivered').length,
        'cancelled' => orders.where((o) => o.status == 'cancelled').length,
        _ => orders.length,
      };

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final screenW = MediaQuery.sizeOf(context).width;
    final hPad = screenW > 1200 ? (screenW - 1200) / 2 + 24.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.white,
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
          final avgTicket =
              allOrders.isEmpty ? 0.0 : total / allOrders.length;
          final activeCount = _count(allOrders, 'active');
          final filtered = _applyFilter(allOrders);

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
                    hPad: hPad,
                  ),
                ),
                // ── Barra de filtros ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: _FilterBar(
                    allOrders: allOrders,
                    group: _group,
                    type: _type,
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
                      }),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 80),
                    sliver: SliverList.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _OrderCard(order: filtered[i]),
                      ),
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
    required this.hPad,
  });

  final double total;
  final int count;
  final double avgTicket;
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
            padding: EdgeInsets.fromLTRB(hPad, 28, hPad, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botón volver
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
                  'Mis Pedidos',
                  style: GoogleFonts.inter(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: AppTokens.surfaceDark,
                    letterSpacing: -1.2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Consulta y gestiona tu historial de compras',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF888886),
                  ),
                ),
              ],
            ),
          ),
          // Stats bar
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 20),
            child: Row(
              children: [
                _StatChip(
                  icon: Icons.payments_outlined,
                  label: 'Total gastado',
                  value: Formatters.price(total),
                  color: AppTokens.brandPrimary,
                ),
                const _StatDivider(),
                _StatChip(
                  icon: Icons.receipt_long_outlined,
                  label: 'Pedidos',
                  value: '$count',
                  color: AppTokens.info,
                ),
                const _StatDivider(),
                _StatChip(
                  icon: Icons.show_chart_rounded,
                  label: 'Ticket medio',
                  value: count == 0 ? '—' : Formatters.price(avgTicket),
                  color: AppTokens.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF999897),
                letterSpacing: 0.3,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTokens.surfaceDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        width: 1,
        height: 36,
        color: const Color(0xFFE4E2E0),
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
    required this.typeOptions,
    required this.countFn,
    required this.onGroupChange,
    required this.onTypeChange,
    required this.hPad,
  });

  final List<Order> allOrders;
  final String group;
  final String type;
  final List<(String, String, IconData)> typeOptions;
  final int Function(List<Order>, String) countFn;
  final ValueChanged<String> onGroupChange;
  final ValueChanged<String> onTypeChange;
  final double hPad;

  static const _groups = <(String, String)>[
    ('all', 'Todos'),
    ('active', 'En curso'),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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

class _OrderCard extends StatefulWidget {
  const _OrderCard({required this.order});
  final Order order;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _hovering = false;

  static Color _statusColor(String s) => switch (s) {
        'pending' => AppTokens.statusPendiente,
        'confirmed' => AppTokens.statusConfirmado,
        'preparing' => AppTokens.statusPreparando,
        'ready' => AppTokens.statusListo,
        'delivered' => AppTokens.statusEntregado,
        'cancelled' => AppTokens.statusCancelado,
        _ => AppTokens.brandPrimary,
      };

  static IconData _typeIcon(String t) => switch (t) {
        'domicilio' => Icons.delivery_dining_rounded,
        'recogida' => Icons.directions_walk_rounded,
        'encargo' => Icons.assignment_rounded,
        _ => Icons.storefront_rounded,
      };

  static IconData _paymentIcon(String? pm) => switch (pm) {
        'efectivo' => Icons.payments_rounded,
        'tarjeta' || 'stripe' => Icons.credit_card_rounded,
        _ => Icons.payment_rounded,
      };

  static String _paymentLabel(String? pm) => switch (pm) {
        'efectivo' => 'Efectivo',
        'tarjeta' => 'Tarjeta',
        'stripe' => 'Stripe',
        _ => 'Pago',
      };

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
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black.withValues(alpha: _hovering ? 0.09 : 0.04),
              blurRadius: _hovering ? 18 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: sc),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: sc.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(
                                  AppTokens.radiusMd,
                                ),
                              ),
                              child: Icon(
                                _typeIcon(o.orderType),
                                color: sc,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '#${o.id.substring(0, 8).toUpperCase()}',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTokens.surfaceDark,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OrderTypeBadge.fromString(o.orderType),
                                      if (isActive) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTokens.brandLight,
                                            borderRadius:
                                                BorderRadius.circular(
                                              AppTokens.radiusPill,
                                            ),
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
                                              const SizedBox(width: 4),
                                              Text(
                                                'En curso',
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTokens.brandDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule_rounded,
                                        size: 12,
                                        color: Color(0xFFAAAAAA),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        Formatters.dateTime(o.createdAt),
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: const Color(0xFF9E9D9B),
                                        ),
                                      ),
                                      if (o.paymentMethod != null) ...[
                                        const SizedBox(width: 10),
                                        Icon(
                                          _paymentIcon(o.paymentMethod),
                                          size: 12,
                                          color: const Color(0xFFAAAAAA),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _paymentLabel(o.paymentMethod),
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: const Color(0xFF9E9D9B),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  Formatters.price(o.total),
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppTokens.brandDark,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                if (o.discountAmount > 0)
                                  Text(
                                    '− ${Formatters.price(o.discountAmount)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppTokens.brandPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            StatusBadge.fromString(o.status),
                            const Spacer(),
                            _ActionButton(
                              label: 'Repetir',
                              icon: Icons.replay_rounded,
                              onTap: () => context.pushNamed(
                                RouteNames.orderDetail,
                                pathParameters: {'orderId': o.id},
                              ),
                              filled: false,
                            ),
                            const SizedBox(width: 8),
                            _ActionButton(
                              label: 'Ver detalles',
                              icon: Icons.arrow_forward_ios_rounded,
                              iconSize: 10,
                              onTap: () => context.pushNamed(
                                RouteNames.orderDetail,
                                pathParameters: {'orderId': o.id},
                              ),
                              filled: _hovering,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusPill),
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
                      shape: const StadiumBorder(),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 28),
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
