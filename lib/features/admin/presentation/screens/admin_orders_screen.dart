import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_extensions.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Tokens visuales compartidos (estilo dashboard/stats) ───────────────────
const _kPageBg = Color(0xFFF4F6F8);
const _kCardBorder = Color(0xFFEEEEEE);
const _kInk = Color(0xFF1A1A2E);
const _kInkMuted = Color(0xFF6B7280);
const _kInkSoft = Color(0xFF9CA3AF);

// ── Constantes de mapeo ───────────────────────────────────────────────────────

const _statusOptions = [
  'pending', 'confirmed', 'preparing', 'ready', 'delivering', 'delivered', 'cancelled',
];
const _statusLabels = {
  'pending': 'Pendiente',
  'confirmed': 'Confirmado',
  'preparing': 'Preparando',
  'ready': 'Listo',
  'delivering': 'En reparto',
  'delivered': 'Entregado',
  'cancelled': 'Cancelado',
};
const _typeLabels = {
  'delivery': 'Reparto',
  'domicilio': 'Domicilio',
  'recogida': 'Recogida',
  'encargo': 'Encargo',
  'mostrador': 'Mostrador',
};

Color _statusColor(String status) => switch (status) {
      'pending' => AppTokens.statusPendiente,
      'confirmed' => AppTokens.statusConfirmado,
      'preparing' => AppTokens.statusPreparando,
      'ready' => AppTokens.statusListo,
      'delivering' => AppTokens.statusReparto,
      'delivered' => AppTokens.statusEntregado,
      'cancelled' => AppTokens.statusCancelado,
      _ => const Color(0xFF9E9E9E),
    };

Color _statusBg(String status) => switch (status) {
      'pending' => AppTokens.statusPendienteBg,
      'confirmed' => AppTokens.statusConfirmadoBg,
      'preparing' => AppTokens.statusPreparandoBg,
      'ready' => AppTokens.statusListoBg,
      'delivering' => AppTokens.statusRepartoBg,
      'delivered' => AppTokens.statusEntregadoBg,
      'cancelled' => AppTokens.statusCanceladoBg,
      _ => const Color(0xFFE0E0E0),
    };

// ── Pantalla ──────────────────────────────────────────────────────────────────

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  String _statusFilter = 'all';
  String _typeFilter = 'all';
  String _search = '';
  Timer? _autoRefresh;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _autoRefresh = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshAll(),
    );
    _setupRealtime();
  }

  void _setupRealtime() {
    _realtimeChannel = ref
        .read(supabaseClientProvider)
        .channel('admin-orders-rt')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (_) {
            if (mounted) _refreshAll();
          },
        )
        .subscribe();
  }

  void _refreshAll() {
    ref
      ..invalidate(adminOrdersProvider)
      ..invalidate(adminOrdersTodayProvider)
      ..invalidate(adminOrdersWeekProvider);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _autoRefresh?.cancel();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayAsync = ref.watch(adminOrdersTodayProvider);

    return AdminShell(
      title: 'Pedidos',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded,
              color: AppTokens.brandPrimary),
          tooltip: 'Actualizar',
          onPressed: _refreshAll,
        ),
        const SizedBox(width: 8),
      ],
      child: ColoredBox(
        color: _kPageBg,
        child: Column(
          children: [
            // ── KPI strip (siempre sobre los datos de hoy) ───────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: todayAsync.when(
                loading: () => const _KpiStripSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
                data: (orders) => _OrdersKpiStrip(orders: orders),
              ),
            ),
            // ── Toolbar con búsqueda y filtros ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: _ToolbarCard(
                statusFilter: _statusFilter,
                typeFilter: _typeFilter,
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onTypeChanged: (v) => setState(() => _typeFilter = v),
                onSearchChanged: (v) =>
                    setState(() => _search = v.toLowerCase().trim()),
              ),
            ),
            // ── Tab bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTokens.radiusLg)),
                  border: Border.all(color: _kCardBorder),
                ),
                child: TabBar(
                  controller: _tabCtrl,
                  indicatorColor: AppTokens.brandPrimary,
                  indicatorWeight: 3,
                  labelColor: AppTokens.brandPrimary,
                  unselectedLabelColor: _kInkMuted,
                  labelStyle: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  unselectedLabelStyle: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.today_rounded, size: 18),
                      text: 'Hoy',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                    Tab(
                      icon: Icon(Icons.date_range_rounded, size: 18),
                      text: 'Semana',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                    Tab(
                      icon: Icon(Icons.history_rounded, size: 18),
                      text: 'Histórico',
                      iconMargin: EdgeInsets.only(bottom: 2),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppTokens.radiusLg)),
                    border: Border.all(color: _kCardBorder),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  clipBehavior: Clip.antiAlias,
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      _TodayTab(
                        statusFilter: _statusFilter,
                        typeFilter: _typeFilter,
                        search: _search,
                      ),
                      _WeekTab(
                        statusFilter: _statusFilter,
                        typeFilter: _typeFilter,
                        search: _search,
                      ),
                      _HistoricoTab(
                        statusFilter: _statusFilter,
                        typeFilter: _typeFilter,
                        search: _search,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── KPI strip ──────────────────────────────────────────────────────────────

class _OrdersKpiStrip extends StatelessWidget {
  const _OrdersKpiStrip({required this.orders});
  final List<Order> orders;

  @override
  Widget build(BuildContext context) {
    final total = orders.length;
    final pending = orders.where((o) => o.status == 'pending').length;
    final preparing = orders
        .where((o) => o.status == 'preparing' || o.status == 'confirmed')
        .length;
    final delivering = orders.where((o) => o.status == 'delivering').length;
    final paid = orders.where((o) => o.paymentStatus == 'paid').toList();
    final revenue = paid.fold<double>(0, (s, o) => s + o.total);
    final ticket = paid.isEmpty ? 0.0 : revenue / paid.length;

    return _KpiStrip(
      items: [
        _Kpi(
          icon: Icons.receipt_long_rounded,
          color: AppTokens.brandPrimary,
          label: 'Pedidos hoy',
          value: '$total',
        ),
        _Kpi(
          icon: Icons.hourglass_top_rounded,
          color: AppTokens.warning,
          label: 'Pendientes',
          value: '$pending',
          subtitle: pending > 0 ? 'Requieren atención' : 'Sin pendientes',
        ),
        _Kpi(
          icon: Icons.outdoor_grill_rounded,
          color: AppTokens.info,
          label: 'En cocina',
          value: '$preparing',
          subtitle: '$delivering en reparto',
        ),
        _Kpi(
          icon: Icons.euro_rounded,
          color: AppTokens.success,
          label: 'Ingresos hoy',
          value: Formatters.price(revenue),
          subtitle: 'Tícket medio ${Formatters.price(ticket)}',
        ),
      ],
    );
  }
}

class _KpiStripSkeleton extends StatelessWidget {
  const _KpiStripSkeleton();
  @override
  Widget build(BuildContext context) =>
      const SizedBox(height: 84); // espacio reservado mientras carga
}

// ─── Toolbar (búsqueda + filtros) ───────────────────────────────────────────

class _ToolbarCard extends StatelessWidget {
  const _ToolbarCard({
    required this.statusFilter,
    required this.typeFilter,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onSearchChanged,
  });
  final String statusFilter;
  final String typeFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar por #ID o notas...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: _kInkSoft, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8F8FA),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kCardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kCardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppTokens.brandPrimary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Estados
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Pill(
                  label: 'Todos',
                  selected: statusFilter == 'all',
                  color: _kInk,
                  onTap: () => onStatusChanged('all'),
                ),
                for (final s in _statusOptions)
                  _Pill(
                    label: _statusLabels[s]!,
                    selected: statusFilter == s,
                    color: _statusColor(s),
                    onTap: () => onStatusChanged(s),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tipos
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Pill(
                  label: 'Todos los tipos',
                  selected: typeFilter == 'all',
                  color: _kInk,
                  onTap: () => onTypeChanged('all'),
                ),
                for (final e in _typeLabels.entries)
                  _Pill(
                    label: e.value,
                    selected: typeFilter == e.key,
                    color: AppTokens.brandPrimary,
                    onTap: () => onTypeChanged(e.key),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : color,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tabs ────────────────────────────────────────────────────────────────────

class _TodayTab extends ConsumerWidget {
  const _TodayTab({
    required this.statusFilter,
    required this.typeFilter,
    required this.search,
  });
  final String statusFilter;
  final String typeFilter;
  final String search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(adminOrdersTodayProvider).when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => Center(
              child: ErrorView(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(adminOrdersTodayProvider))),
          data: (orders) => _OrdersList(
            orders: _applyFilters(orders, statusFilter, typeFilter, search),
            emptyIcon: Icons.today_rounded,
            emptyLabel: search.isNotEmpty
                ? 'Sin resultados para "$search"'
                : 'Sin pedidos hoy con estos filtros',
          ),
        );
  }
}

class _WeekTab extends ConsumerWidget {
  const _WeekTab({
    required this.statusFilter,
    required this.typeFilter,
    required this.search,
  });
  final String statusFilter;
  final String typeFilter;
  final String search;

  static const _dayNames = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(adminOrdersWeekProvider).when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => Center(
              child: ErrorView(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(adminOrdersWeekProvider))),
          data: (allOrders) {
            final filtered =
                _applyFilters(allOrders, statusFilter, typeFilter, search);
            if (filtered.isEmpty) {
              return const _EmptyState(
                icon: Icons.date_range_rounded,
                label: 'Sin pedidos esta semana',
              );
            }
            final grouped = <String, List<Order>>{};
            for (final o in filtered) {
              final d = o.createdAt;
              final key = '${_dayNames[d.weekday - 1]} ${d.day}/${d.month}';
              grouped.putIfAbsent(key, () => []).add(o);
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: grouped.length,
              itemBuilder: (_, gi) {
                final day = grouped.keys.elementAt(gi);
                final dayOrders = grouped[day]!;
                final dayTotal = dayOrders.fold<double>(
                    0, (s, o) => s + o.total);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 14, color: _kInkMuted),
                          const SizedBox(width: 6),
                          Text(
                            day,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _kInkMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTokens.brandPrimary
                                  .withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(
                                  AppTokens.radiusPill),
                            ),
                            child: Text(
                              '${dayOrders.length}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTokens.brandPrimary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            Formatters.price(dayTotal),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _kInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...dayOrders.asMap().entries.map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _OrderCard(
                              order: e.value, index: e.key),
                        )),
                  ],
                );
              },
            );
          },
        );
  }
}

class _HistoricoTab extends ConsumerWidget {
  const _HistoricoTab({
    required this.statusFilter,
    required this.typeFilter,
    required this.search,
  });
  final String statusFilter;
  final String typeFilter;
  final String search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(adminOrdersProvider).when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => Center(
              child: ErrorView(
                  message: e.toString(),
                  onRetry: () =>
                      ref.invalidate(adminOrdersProvider))),
          data: (orders) => _OrdersList(
            orders: _applyFilters(orders, statusFilter, typeFilter, search),
            emptyIcon: Icons.inbox_rounded,
            emptyLabel: 'Sin pedidos con estos filtros',
          ),
        );
  }
}

// ─── Helpers de filtrado y lista ────────────────────────────────────────────

List<Order> _applyFilters(
  List<Order> orders,
  String statusFilter,
  String typeFilter,
  String search,
) {
  return orders.where((o) {
    if (statusFilter != 'all' && o.status != statusFilter) return false;
    if (typeFilter != 'all' && o.orderType != typeFilter) return false;
    if (search.isNotEmpty) {
      final hay =
          '${o.shortId} ${o.notes ?? ''} ${o.orderType}'.toLowerCase();
      if (!hay.contains(search)) return false;
    }
    return true;
  }).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({
    required this.orders,
    required this.emptyIcon,
    required this.emptyLabel,
  });
  final List<Order> orders;
  final IconData emptyIcon;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return _EmptyState(icon: emptyIcon, label: emptyLabel);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _OrderCard(order: orders[i], index: i),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: _kInkSoft),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.inter(color: _kInkMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─── KPI helpers (estilo dashboard) ─────────────────────────────────────────

class _Kpi {
  const _Kpi({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.subtitle,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String? subtitle;
}

class _KpiStrip extends StatelessWidget {
  const _KpiStrip({required this.items});
  final List<_Kpi> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = c.maxWidth >= 900
            ? 4
            : c.maxWidth >= 560
                ? 2
                : 1;
        const spacing = 14.0;
        final w = cols == 1
            ? c.maxWidth
            : (c.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final k in items)
              SizedBox(width: w, child: _KpiTile(data: k)),
          ],
        );
      },
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.data});
  final _Kpi data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kCardBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: _kInkMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _kInk,
                    height: 1.05,
                  ),
                ),
                if (data.subtitle != null)
                  Text(
                    data.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: _kInkSoft,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de pedido ─────────────────────────────────────────────────────────

class _OrderCard extends ConsumerStatefulWidget {
  const _OrderCard({required this.order, required this.index});
  final Order order;
  final int index;

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _expanded = false;

  Order get o => widget.order;

  bool get _isCancelled => o.status == 'cancelled';
  bool get _needsPayment =>
      o.paymentStatus == 'pending' &&
      (o.paymentMethod == 'cash' || o.paymentMethod == 'tpv') &&
      (o.orderType == 'recogida' ||
          o.orderType == 'encargo' ||
          o.orderType == 'mostrador') &&
      o.status == 'ready';

  void _showCancelDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
        title: Text('Cancelar pedido',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Motivo de cancelación…',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm)),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Volver', style: GoogleFonts.inter()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTokens.danger),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(adminActionProvider.notifier).cancelOrderWithReason(
                    orderId: o.id,
                    reason: controller.text.trim(),
                  );
            },
            child: Text('Confirmar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadTicketPdf(BuildContext context) async {
    final items =
        await ref.read(adminOrderItemsProvider(o.id).future);
    final pdf = pw.Document()
      ..addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(24),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'Sabor de Casa',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Ticket del pedido',
                  style: const pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              _pdfRow('Pedido', '#${o.shortId}'),
              _pdfRow('Tipo', _typeLabels[o.orderType] ?? o.orderType),
              _pdfRow('Fecha', Formatters.dateTime(o.createdAt)),
              _pdfRow('Estado', _statusLabels[o.status] ?? o.status),
              pw.SizedBox(height: 12),
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              for (final item in items) ...[
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '${item.quantity}x ${item.dishName ?? "Plato"}',
                      style: const pw.TextStyle(fontSize: 13),
                    ),
                    pw.Text(
                      _ticketPrice(item.subtotal),
                      style: const pw.TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
              ],
              pw.Divider(thickness: 1, color: PdfColors.grey400),
              pw.SizedBox(height: 8),
              _pdfRow('Subtotal', _ticketPrice(o.subtotal)),
              if (o.deliveryFee > 0)
                _pdfRow('Envio', _ticketPrice(o.deliveryFee)),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TOTAL',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    _ticketPrice(o.total),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Center(
                child: pw.Text(
                  'Gracias por tu pedido!',
                  style: pw.TextStyle(
                    fontSize: 13,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'ticket_${o.shortId}.pdf',
    );
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(
                color: PdfColors.grey700,
                fontSize: 13,
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  String _ticketPrice(double value) =>
      Formatters.price(value).replaceAll('€', 'EUR');

  /// Genera la factura formal A4 con IVA desglosado para el admin.
  Future<void> _downloadFacturaPdf(BuildContext context) async {
    final items = await ref.read(adminOrderItemsProvider(o.id).future);
    final user = o.userId != null
        ? await ref.read(adminUserProfileProvider(o.userId!).future)
        : null;

    final facturaNum = 'FAC-${o.shortId}';
    final fecha =
        '${o.createdAt.day.toString().padLeft(2, '0')}/${o.createdAt.month.toString().padLeft(2, '0')}/${o.createdAt.year}';
    final hora =
        '${o.createdAt.hour.toString().padLeft(2, '0')}:${o.createdAt.minute.toString().padLeft(2, '0')}';
    final baseImponible = o.total / 1.10;
    final iva = o.total - baseImponible;
    final totalItems = items.fold<int>(0, (s, i) => s + i.quantity);

    final pdf = pw.Document()
      ..addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ── Cabecera empresa + número factura ───────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Sabor de Casa',
                        style: pw.TextStyle(
                            fontSize: 22, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text('CIF: B12345678',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('Calle Principal 1, 28001 Madrid',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('Tel: +34 910 000 000',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey600)),
                      pw.Text('info@sabordecasa.es',
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey600)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FACTURA',
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange800,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        facturaNum,
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Fecha: $fecha',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600),
                      ),
                      pw.Text(
                        'Hora: $hora',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1.5, color: PdfColors.grey400),
              pw.SizedBox(height: 12),
              // ── Datos del cliente + detalle del pedido ────────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'FACTURAR A:',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          user?.fullName ?? 'Cliente',
                          style: pw.TextStyle(
                              fontSize: 13, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          user?.email ?? '',
                          style: const pw.TextStyle(
                              fontSize: 11, color: PdfColors.grey700),
                        ),
                        if (user?.phone != null && (user?.phone ?? '').isNotEmpty)
                          pw.Text(
                            user!.phone!,
                            style: const pw.TextStyle(
                                fontSize: 11, color: PdfColors.grey700),
                          ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'DETALLE DEL PEDIDO:',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Tipo: ${_typeLabels[o.orderType] ?? o.orderType}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          'Estado: ${_statusLabels[o.status] ?? o.status}',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        pw.Text(
                          'Nº platos: $totalItems uds.',
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                        if (o.paymentMethod != null)
                          pw.Text(
                            'Pago: ${o.paymentMethod!.toUpperCase()}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        if (o.scheduledAt != null)
                          pw.Text(
                            'Programado: ${o.scheduledAt!.day.toString().padLeft(2, '0')}/${o.scheduledAt!.month.toString().padLeft(2, '0')}/${o.scheduledAt!.year}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              // ── Tabla de productos ────────────────────────────────────
              pw.Container(
                decoration: pw.BoxDecoration(
                  border:
                      pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  children: [
                    pw.Container(
                      color: PdfColors.grey100,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: pw.Row(
                        children: [
                          pw.Expanded(
                            flex: 4,
                            child: pw.Text(
                              'DESCRIPCIÓN',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              'CANT.',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              'P. UNIT.',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Expanded(
                            flex: 2,
                            child: pw.Text(
                              'SUBTOTAL',
                              style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.grey700,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Divider(
                        height: 1,
                        thickness: 1,
                        color: PdfColors.grey300),
                    for (int i = 0; i < items.length; i++) ...[
                      pw.Container(
                        color: i.isOdd
                            ? PdfColors.grey50
                            : PdfColors.white,
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        child: pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              children: [
                                pw.Expanded(
                                  flex: 4,
                                  child: pw.Text(
                                    items[i].dishName ?? 'Plato',
                                    style: const pw.TextStyle(
                                        fontSize: 11),
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Text(
                                    '${items[i].quantity}',
                                    style: const pw.TextStyle(
                                        fontSize: 11),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Text(
                                    Formatters.price(
                                        items[i].unitPrice),
                                    style: const pw.TextStyle(
                                        fontSize: 11),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Text(
                                    Formatters.price(
                                        items[i].subtotal),
                                    style: pw.TextStyle(
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                    textAlign: pw.TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            if (items[i].notes != null &&
                                items[i].notes!.isNotEmpty)
                              pw.Padding(
                                padding:
                                    const pw.EdgeInsets.only(top: 2),
                                child: pw.Text(
                                  '- ${items[i].notes}',
                                  style: const pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (i < items.length - 1)
                        pw.Divider(
                            height: 1,
                            thickness: 0.5,
                            color: PdfColors.grey200),
                    ],
                  ],
                ),
              ),
              pw.SizedBox(height: 16),
              // ── Totales con IVA ────────────────────────────────────────
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.SizedBox(
                    width: 240,
                    child: pw.Column(
                      children: [
                        _pdfAdminRow(
                            'Subtotal productos',
                            Formatters.price(o.subtotal)),
                        if (o.deliveryFee > 0)
                          _pdfAdminRow(
                              'Gastos de envío',
                              Formatters.price(o.deliveryFee)),
                        if (o.discountAmount > 0)
                          _pdfAdminRow(
                              'Descuento',
                              '−${Formatters.price(o.discountAmount)}'),
                        pw.SizedBox(height: 4),
                        pw.Divider(
                            thickness: 1, color: PdfColors.grey400),
                        _pdfAdminRow(
                          'Base imponible (sin IVA)',
                          Formatters.price(baseImponible),
                          muted: true,
                        ),
                        _pdfAdminRow(
                          'IVA 10% (Restauración)',
                          Formatters.price(iva),
                          muted: true,
                        ),
                        pw.Divider(
                            thickness: 1.5, color: PdfColors.black),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 5),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'TOTAL (IVA incl.)',
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                Formatters.price(o.total),
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (o.notes != null && o.notes!.isNotEmpty) ...[
                pw.SizedBox(height: 10),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'Notas: ${o.notes}',
                    style: const pw.TextStyle(
                        fontSize: 11, color: PdfColors.grey700),
                  ),
                ),
              ],
              pw.Spacer(),
              // ── Pie ──────────────────────────────────────────────────
              pw.Divider(color: PdfColors.grey300),
              pw.Center(
                child: pw.Text(
                  'Sabor de Casa · CIF B12345678 · Factura simplificada conforme art. 226 Directiva 2006/112/CE',
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey500),
                ),
              ),
            ],
          ),
        ),
      );
    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'factura_${o.shortId}.pdf',
    );
  }

  pw.Widget _pdfAdminRow(
    String label,
    String value, {
    bool muted = false,
  }) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                color: muted ? PdfColors.grey600 : PdfColors.black,
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: muted ? PdfColors.grey600 : PdfColors.black,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final sc = _statusColor(o.status);
    final sbg = _statusBg(o.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: _needsPayment
              ? AppTokens.warning
              : const Color(0xFFEEEEEE),
          width: _needsPayment ? 1.5 : 1,
        ),
        boxShadow: [AppTokens.cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Barra de color superior ──────────────────────────────────
          Container(height: 3, color: sc),

          // ── Cabecera ─────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  // ID
                  Text(
                    '#${o.shortId}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Tipo badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: Text(
                      _typeLabels[o.orderType] ?? o.orderType,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF555570)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: sbg,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: Text(
                      _statusLabels[o.status] ?? o.status,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: sc),
                    ),
                  ),
                  const Spacer(),
                  // Fecha
                  Text(
                    Formatters.dateTime(o.createdAt),
                    style: GoogleFonts.inter(
                        fontSize: 11, color: const Color(0xFF8A8FA8)),
                  ),
                  const SizedBox(width: 12),
                  // Total
                  Text(
                    Formatters.price(o.total),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF9E9E9E),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // ── Detalle expandible ────────────────────────────────────────
          if (_expanded) ...[
            Container(height: 1, color: const Color(0xFFF0F0F0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges de pago
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _Badge(
                        label: o.paymentStatus == 'paid'
                            ? '✓ Pagado'
                            : 'Pendiente de pago',
                        color: o.paymentStatus == 'paid'
                            ? AppTokens.success
                            : AppTokens.warning,
                      ),
                      if (o.paymentMethod != null)
                        _Badge(
                          label: o.paymentMethod!.toUpperCase(),
                          color: AppTokens.info,
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Datos del cliente
                  if (o.userId != null)
                    _CustomerSection(userId: o.userId!),

                  // Ítems del pedido
                  _OrderItemsSection(orderId: o.id),
                  const SizedBox(height: 14),

                  // Notas
                  if (o.notes != null && o.notes!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFC),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes_rounded,
                              size: 14, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              o.notes!,
                              style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF555570)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Cambiar estado
                  if (!_isCancelled) ...[
                    Text(
                      'CAMBIAR ESTADO',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: const Color(0xFF9E9E9E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: o.status,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                          borderSide:
                              const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                          borderSide:
                              const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        isDense: true,
                      ),
                      items: _statusOptions
                          .where((s) => s != 'cancelled')
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _statusColor(s),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(_statusLabels[s] ?? s,
                                        style: GoogleFonts.inter(fontSize: 13)),
                                  ],
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v == null || v == o.status) return;
                        ref
                            .read(adminActionProvider.notifier)
                            .updateOrderStatus(orderId: o.id, status: v);
                      },
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Acciones
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (!_isCancelled)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppTokens.danger,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                          ),
                          onPressed: _showCancelDialog,
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: Text('Cancelar pedido',
                              style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTokens.brandPrimary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          side: const BorderSide(
                              color: AppTokens.brandPrimary),
                        ),
                        onPressed: () => _downloadTicketPdf(context),
                        icon: const Icon(
                            Icons.receipt_outlined,
                            size: 16),
                        label: Text(
                          'Ticket',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B4226),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          side: const BorderSide(
                              color: Color(0xFF6B4226)),
                        ),
                        onPressed: () => _downloadFacturaPdf(context),
                        icon: const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 16),
                        label: Text(
                          'Factura PDF',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (_needsPayment)
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppTokens.brandPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                          ),
                          onPressed: () => ref
                              .read(adminActionProvider.notifier)
                              .markDeliveredAndPaid(o.id),
                          icon: const Icon(Icons.done_all_rounded, size: 16),
                          label: Text('Entregar y cobrar',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms, delay: (widget.index * 25).ms)
        .slideY(begin: 0.04, end: 0, duration: 250.ms,
            delay: (widget.index * 25).ms);
  }
}

// ── Ítems del pedido ──────────────────────────────────────────────────────────

class _OrderItemsSection extends ConsumerWidget {
  const _OrderItemsSection({required this.orderId});
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(adminOrderItemsProvider(orderId)).when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRODUCTOS',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFC),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < items.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            color: Color(0xFFEEEEEE),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              // Imagen del plato
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: items[i].dishImageUrl != null &&
                                        items[i].dishImageUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: items[i].dishImageUrl!,
                                        width: 44,
                                        height: 44,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) =>
                                            _AdminDishPlaceholder(),
                                        placeholder: (_, __) =>
                                            _AdminDishPlaceholder(),
                                      )
                                    : _AdminDishPlaceholder(),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppTokens.brandPrimary
                                      .withValues(alpha: 0.1),
                                  borderRadius:
                                      BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${items[i].quantity}×',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppTokens.brandPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      items[i].dishName ?? 'Producto',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                    Text(
                                      '${Formatters.price(items[i].unitPrice)} / ud.',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF8A8FA8),
                                      ),
                                    ),
                                    if (items[i].notes != null &&
                                        items[i].notes!.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.notes_rounded,
                                            size: 11,
                                            color: Color(0xFF9E9E9E),
                                          ),
                                          const SizedBox(width: 3),
                                          Flexible(
                                            child: Text(
                                              items[i].notes!,
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: const Color(0xFF555570),
                                                fontStyle: FontStyle.italic,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                Formatters.price(items[i].subtotal),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── _CustomerSection ───────────────────────────────────────────────────────────

class _CustomerSection extends ConsumerWidget {
  const _CustomerSection({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId.isEmpty) return const SizedBox.shrink();
    final userAsync = ref.watch(adminUserProfileProvider(userId));
    return userAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CLIENTE',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFC),
                border: Border.all(color: const Color(0xFFEEEEEE)),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 14, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 8),
                      Text(
                        user.fullName ?? 'Sin nombre',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 14, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          user.email,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: const Color(0xFF555570)),
                        ),
                      ),
                    ],
                  ),
                  if (user.phone != null && user.phone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: Color(0xFF9E9E9E)),
                        const SizedBox(width: 8),
                        Text(
                          user.phone!,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: const Color(0xFF555570)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        );
      },
    );
  }
}

// ── _AdminDishPlaceholder ──────────────────────────────────────────────────────

class _AdminDishPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(
        Icons.restaurant_menu_rounded,
        size: 20,
        color: Color(0xFFBBBBBB),
      ),
    );
  }
}
