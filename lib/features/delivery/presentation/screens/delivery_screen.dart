import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/status_badge.dart';
import 'package:sabor_de_casa/features/delivery/presentation/providers/delivery_provider.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_extensions.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Design tokens (unificados) ──────────────────────────────────────────────

const _kBg = Color(0xFFF7F8FA);
const _kSurface = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFEAEBF0);
const _kTextPrimary = Color(0xFF111827);
const _kTextMuted = Color(0xFF6B7280);

// ── Pantalla principal ────────────────────────────────────────────────────────

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key});

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  Timer? _autoRefresh;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _autoRefresh =
        Timer.periodic(const Duration(seconds: 30), (_) => _refreshAll());
    _setupRealtime();
  }

  void _setupRealtime() {
    _realtimeChannel = ref
        .read(supabaseClientProvider)
        .channel('delivery-orders-rt')
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
      ..invalidate(deliveryDetailProvider)
      ..invalidate(deliveryHistoryTodayProvider)
      ..invalidate(deliveryHistoryWeekProvider);
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
    ref.listen<AsyncValue<void>>(employeeOrderActionProvider, (_, next) {
      next.whenOrNull(
        error: (e, __) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTokens.danger,
            content: Text(
              'Error: $e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ),
      );
    });

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _kTextPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Panel Reparto',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppTokens.brandPrimary,
            ),
            tooltip: 'Actualizar',
            onPressed: _refreshAll,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Column(
            children: [
              TabBar(
                controller: _tabCtrl,
                labelColor: AppTokens.brandPrimary,
                unselectedLabelColor: _kTextMuted,
                indicatorColor: AppTokens.brandPrimary,
                indicatorWeight: 2.5,
                labelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Activos'),
                  Tab(text: 'Historial'),
                ],
              ),
              Container(height: 1, color: _kBorder),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _ActivosTab(onRefresh: _refreshAll),
          _HistorialTab(onRefresh: _refreshAll),
        ],
      ),
    );
  }
}

// ── Tab 1: Pedidos activos ────────────────────────────────────────────────────

class _ActivosTab extends ConsumerStatefulWidget {
  const _ActivosTab({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  ConsumerState<_ActivosTab> createState() => _ActivosTabState();
}

class _ActivosTabState extends ConsumerState<_ActivosTab> {
  String _statusFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(deliveryDetailProvider);

    return detailAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: widget.onRefresh,
      ),
      data: (allOrders) {
        final ready =
            allOrders.where((d) => d.order.status == 'ready').toList();
        final delivering =
            allOrders.where((d) => d.order.status == 'delivering').toList();

        final filtered = switch (_statusFilter) {
          'ready' => ready,
          'delivering' => delivering,
          _ => allOrders,
        };

        return Column(
          children: [
            // ── Filter chips ──────────────────────────────────────────
            Container(
              color: _kSurface,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  for (final (value, label, count) in [
                    ('all', 'Todos', allOrders.length),
                    ('ready', 'Para recoger', ready.length),
                    ('delivering', 'En reparto', delivering.length),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          count > 0 ? '$label ($count)' : label,
                          style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        selected: _statusFilter == value,
                        onSelected: (_) =>
                            setState(() => _statusFilter = value),
                        selectedColor:
                            AppTokens.brandPrimary.withValues(alpha: 0.15),
                        checkmarkColor: AppTokens.brandPrimary,
                        labelStyle: TextStyle(
                          color: _statusFilter == value
                              ? AppTokens.brandPrimary
                              : _kTextMuted,
                        ),
                        side: BorderSide(
                          color: _statusFilter == value
                              ? AppTokens.brandPrimary
                              : _kBorder,
                        ),
                        backgroundColor: _kSurface,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 1, color: _kBorder),
            // ── Lista ─────────────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyDelivery()
                  : RefreshIndicator(
                      color: AppTokens.brandPrimary,
                      onRefresh: () async => widget.onRefresh(),
                      child: ListView(
                        padding:
                            const EdgeInsets.fromLTRB(16, 20, 16, 32),
                        children: filtered
                            .map((d) => Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: 12),
                                  child: _DeliveryCard(detail: d),
                                ))
                            .toList(),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ── Tab 2: Historial de entregas ──────────────────────────────────────────────

class _HistorialTab extends ConsumerStatefulWidget {
  const _HistorialTab({required this.onRefresh});
  final VoidCallback onRefresh;

  @override
  ConsumerState<_HistorialTab> createState() => _HistorialTabState();
}

class _HistorialTabState extends ConsumerState<_HistorialTab> {
  String _period = 'today';

  @override
  Widget build(BuildContext context) {
    final histAsync = _period == 'today'
        ? ref.watch(deliveryHistoryTodayProvider)
        : ref.watch(deliveryHistoryWeekProvider);

    return Column(
      children: [
        // ── Period chips ───────────────────────────────────────────────
        Container(
          color: _kSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              for (final (value, label) in [
                ('today', 'Hoy'),
                ('week', 'Esta semana'),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      label,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    selected: _period == value,
                    onSelected: (_) => setState(() => _period = value),
                    selectedColor:
                        AppTokens.brandPrimary.withValues(alpha: 0.15),
                    checkmarkColor: AppTokens.brandPrimary,
                    labelStyle: TextStyle(
                      color: _period == value
                          ? AppTokens.brandPrimary
                          : _kTextMuted,
                    ),
                    side: BorderSide(
                      color: _period == value
                          ? AppTokens.brandPrimary
                          : _kBorder,
                    ),
                    backgroundColor: _kSurface,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 2),
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: _kBorder),
        Expanded(
          child: histAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (e, _) =>
                ErrorView(message: e.toString(), onRetry: widget.onRefresh),
            data: (orders) {
              if (orders.isEmpty) return _EmptyHistory();
              return RefreshIndicator(
                color: AppTokens.brandPrimary,
                onRefresh: () async => widget.onRefresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  itemCount: orders.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _HistoryCard(detail: orders[i]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta historial (solo lectura) ──────────────────────────────────────────

class _HistoryCard extends ConsumerWidget {
  const _HistoryCard({required this.detail});
  final DeliveryDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final o = detail.order;
    final itemsAsync = ref.watch(orderItemsProvider(o.id));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kBorder),
        boxShadow: [AppTokens.cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: AppTokens.success),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      '#${o.shortId}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTokens.success.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusSm),
                        border: Border.all(
                          color: AppTokens.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 13,
                            color: AppTokens.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Entregado',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTokens.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      TimeOfDay.fromDateTime(o.createdAt).format(context),
                      style: GoogleFonts.inter(
                          fontSize: 12, color: _kTextMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Dirección ───────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 15, color: AppTokens.danger),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        detail.fullAddress,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _kTextMuted,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // ── Cliente ──────────────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.person_rounded,
                        size: 15, color: AppTokens.info),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        detail.clientDisplay,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: _kTextMuted),
                      ),
                    ),
                    if (detail.clientPhone != null)
                      Text(
                        detail.clientPhone!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTokens.brandPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          Container(height: 1, color: _kBorder),
          // ── Artículos ─────────────────────────────────────────────────
          itemsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTokens.brandPrimary,
                  ),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (items) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTokens.brandPrimary
                                .withValues(alpha: 0.10),
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusSm),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTokens.brandPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.dishName ?? 'Plato',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: _kTextPrimary),
                          ),
                        ),
                        Text(
                          Formatters.price(item.subtotal),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: _kTextMuted),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          // ── Notas ─────────────────────────────────────────────────────
          if (o.notes != null && o.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTokens.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  border: Border.all(
                      color: AppTokens.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sticky_note_2_rounded,
                        size: 14, color: AppTokens.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        o.notes!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTokens.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // ── Importe + método de pago ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _PaymentBadge(order: o),
                const Spacer(),
                Text(
                  Formatters.price(o.total),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _kTextPrimary,
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

// ── Empty historial ───────────────────────────────────────────────────────────

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppTokens.brandLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 38,
              color: AppTokens.brandPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Sin entregas en este período',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Los pedidos entregados aparecerán aquí',
            style: GoogleFonts.inter(fontSize: 14, color: _kTextMuted),
          ),
        ],
      ),
    );
  }
}

// ── Tarjeta de pedido de reparto ──────────────────────────────────────────────

class _DeliveryCard extends ConsumerStatefulWidget {
  const _DeliveryCard({required this.detail});
  final DeliveryDetail detail;

  @override
  ConsumerState<_DeliveryCard> createState() => _DeliveryCardState();
}

class _DeliveryCardState extends ConsumerState<_DeliveryCard> {
  bool _loading = false;

  DeliveryDetail get d => widget.detail;
  Order get o => d.order;

  bool get _isReady => o.status == 'ready';
  bool get _isDelivering => o.status == 'delivering';
  bool get _isCash => o.paymentMethod == 'cash';

  Color get _accentColor =>
      _isReady ? AppTokens.brandPrimary : AppTokens.warning;

  Future<void> _primaryAction() async {
    setState(() => _loading = true);
    try {
      if (_isReady) {
        // Asignar al repartidor + pasar a 'delivering'
        await ref
            .read(employeeOrderActionProvider.notifier)
            .assignToMe(o.id);
      } else if (_isDelivering) {
        if (_isCash) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusLg),
              ),
              title: Text(
                'Confirmar cobro',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
              content: Text(
                '¿Has cobrado ${Formatters.price(o.total)} en efectivo?',
                style: GoogleFonts.inter(height: 1.5),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('No', style: GoogleFonts.inter()),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTokens.brandPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTokens.radiusSm),
                    ),
                  ),
                  child: Text(
                    'Sí, cobrado',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          );
          if (confirmed != true) {
            setState(() => _loading = false);
            return;
          }
          await ref
              .read(employeeOrderActionProvider.notifier)
              .markDeliveredAndPaid(o.id);
        } else {
          await ref
              .read(employeeOrderActionProvider.notifier)
              .updateStatus(orderId: o.id, newStatus: 'delivered');
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(orderItemsProvider(o.id));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [AppTokens.cardShadow],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Barra lateral de color + header ────────────────────────────
          Container(
            height: 4,
            color: _accentColor,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text(
                  '#${o.shortId}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _kTextPrimary,
                  ),
                ),
                const Spacer(),
                StatusBadge.fromString(o.status),
                const SizedBox(width: 10),
                Text(
                  TimeOfDay.fromDateTime(o.createdAt).format(context),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _kTextMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: _kBorder),
          ),
          const SizedBox(height: 14),

          // ── Dirección ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTokens.danger.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: AppTokens.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kTextMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.fullAddress,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _kTextPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Cliente ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppTokens.info.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 18,
                    color: AppTokens.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cliente',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kTextMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.clientDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _kTextPrimary,
                        ),
                      ),
                      if (d.clientPhone != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          d.clientPhone!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTokens.brandPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: _kBorder),
          ),
          const SizedBox(height: 12),

          // ── Artículos del pedido ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Pedido',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _kTextMuted,
                letterSpacing: 0.3,
              ),
            ),
          ),
          itemsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTokens.brandPrimary,
                  ),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (items) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppTokens.brandPrimary
                                .withValues(alpha: 0.10),
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusSm),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTokens.brandPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.dishName ?? 'Plato',
                            style: GoogleFonts.inter(
                                fontSize: 14, color: _kTextPrimary),
                          ),
                        ),
                        Text(
                          Formatters.price(item.subtotal),
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              color: _kTextMuted,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (o.notes != null && o.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTokens.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  border: Border.all(
                      color: AppTokens.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sticky_note_2_rounded,
                        size: 14, color: AppTokens.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        o.notes!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTokens.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: _kBorder),
          ),
          const SizedBox(height: 14),

          // ── Importe + pago ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Importe a cobrar:',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _kTextMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.price(o.total),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _kTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PaymentBadge(order: o),
          ),

          const SizedBox(height: 14),

          // ── Botón acción ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _loading ? null : _primaryAction,
                style: FilledButton.styleFrom(
                  backgroundColor: _isReady
                      ? AppTokens.brandPrimary
                      : _isCash
                          ? Colors.orange.shade700
                          : AppTokens.info,
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTokens.radiusSm),
                  ),
                ),
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_isReady
                        ? Icons.delivery_dining_rounded
                        : _isCash
                            ? Icons.payments_rounded
                            : Icons.check_circle_rounded),
                label: _loading
                    ? const SizedBox.shrink()
                    : Text(
                        _isReady
                            ? 'Comenzar reparto'
                            : _isCash
                                ? 'Entregado y cobrado'
                                : 'Marcar como entregado',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge de pago ─────────────────────────────────────────────────────────────

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    if (order.paymentStatus == 'paid') {
      return _chip(Icons.check_circle_rounded, 'Pagado con tarjeta',
          AppTokens.success);
    }
    if (order.paymentMethod == 'cash') {
      return _chip(
          Icons.payments_rounded, 'COBRAR EN EFECTIVO', Colors.orange.shade800,
          bold: true);
    }
    return const SizedBox.shrink();
  }

  Widget _chip(IconData icon, String label, Color color, {bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyDelivery extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppTokens.brandLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.two_wheeler_rounded,
              size: 38,
              color: AppTokens.brandPrimary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Sin pedidos para repartir',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando un pedido esté listo aparecerá aquí',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _kTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
