import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/core/widgets/status_badge.dart';
import 'package:sabor_de_casa/features/kitchen/presentation/providers/employee_orders_provider.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Paleta KDS oscura ─────────────────────────────────────────────────────────

const _kBg = Color(0xFF0F1117);
const _kSurface = Color(0xFF1A1D27);
const _kBorder = Color(0xFF2E3244);
const _kTextPrimary = Color(0xFFF0F0F0);
const _kTextMuted = Color(0xFF8A8FA8);

// ── Pantalla principal ────────────────────────────────────────────────────────

class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  Timer? _autoRefresh;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    // Auto-refresh cada 30 segundos como fallback
    _autoRefresh = Timer.periodic(const Duration(seconds: 30), (_) {
      _refreshAll();
    });
    // Supabase Realtime: actualiza al instante cuando cambia cualquier pedido
    _setupRealtime();
  }

  void _setupRealtime() {
    _realtimeChannel = ref
        .read(supabaseClientProvider)
        .channel('kitchen-orders-rt')
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

  @override
  void dispose() {
    _tabCtrl.dispose();
    _autoRefresh?.cancel();
    _realtimeChannel?.unsubscribe();
    super.dispose();
  }

  void _refreshAll() {
    ref
      ..invalidate(kitchenOrdersProvider)
      ..invalidate(encargoKitchenOrdersProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Escucha errores del action provider y muestra snackbar
    ref.listen<AsyncValue<void>>(employeeOrderActionProvider, (_, next) {
      next.whenOrNull(
        error: (e, __) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTokens.danger,
            content: Text(
              'Error al actualizar: $e',
              style: GoogleFonts.inter(color: Colors.white),
            ),
          ),
        ),
      );
    });

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _kBg,
        tabBarTheme: const TabBarThemeData(
          indicatorColor: AppTokens.brandPrimary,
          labelColor: AppTokens.brandPrimary,
          unselectedLabelColor: _kTextMuted,
        ),
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        appBar: AppBar(
          backgroundColor: _kSurface,
          elevation: 0,
          iconTheme: const IconThemeData(color: _kTextPrimary),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppTokens.brandPrimary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'KDS – Cocina',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kTextPrimary,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: _kTextMuted),
              tooltip: 'Actualizar',
              onPressed: _refreshAll,
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _kBorder)),
              ),
              child: TabBar(
                controller: _tabCtrl,
                indicatorColor: AppTokens.brandPrimary,
                indicatorWeight: 3,
                labelColor: AppTokens.brandPrimary,
                unselectedLabelColor: _kTextMuted,
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle:
                    GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.local_fire_department_rounded, size: 18),
                    text: 'Cocina',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                  Tab(
                    icon: Icon(Icons.assignment_rounded, size: 18),
                    text: 'Encargos',
                    iconMargin: EdgeInsets.only(bottom: 2),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabCtrl,
          children: const [_KitchenTab(), _EncargosTab()],
        ),
      ),
    );
  }
}

// ── Cocina Tab ────────────────────────────────────────────────────────────────

class _KitchenTab extends ConsumerWidget {
  const _KitchenTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(kitchenOrdersProvider);
    return ordersAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(kitchenOrdersProvider),
      ),
      data: (orders) {
        if (orders.isEmpty) {
          return const _EmptyKds(
            icon: Icons.check_circle_outline_rounded,
            label: 'Cocina limpia',
            sub: 'No hay tickets activos',
          );
        }

        // Columnas adaptativas según ancho
        final screenW = MediaQuery.sizeOf(context).width;
        final cols = screenW < 700
            ? 1
            : screenW < 1100
                ? 2
                : screenW < 1500
                    ? 3
                    : 4;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: 310,
          ),
          itemCount: orders.length,
          itemBuilder: (_, i) => _KitchenCard(order: orders[i]),
        );
      },
    );
  }
}

// ── Encargos Tab ──────────────────────────────────────────────────────────────

class _EncargosTab extends ConsumerWidget {
  const _EncargosTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final encargosAsync = ref.watch(encargoKitchenOrdersProvider);
    return encargosAsync.when(
      loading: () => const Center(child: LoadingIndicator()),
      error: (e, _) => ErrorView(
        message: e.toString(),
        onRetry: () => ref.invalidate(encargoKitchenOrdersProvider),
      ),
      data: (encargos) {
        if (encargos.isEmpty) {
          return const _EmptyKds(
            icon: Icons.assignment_outlined,
            label: 'Sin encargos',
            sub: 'No hay encargos en preparación',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: encargos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _EncargoCard(order: encargos[i]),
        );
      },
    );
  }
}

// ── Kitchen Card ──────────────────────────────────────────────────────────────

class _KitchenCard extends ConsumerStatefulWidget {
  const _KitchenCard({required this.order});
  final Order order;

  @override
  ConsumerState<_KitchenCard> createState() => _KitchenCardState();
}

class _KitchenCardState extends ConsumerState<_KitchenCard> {
  bool _loading = false;

  // ── Lógica de estado ──────────────────────────────────────────────────────

  // Siguiente estado en el flujo de cocina
  static String? _nextStatus(String current) => switch (current) {
        'pending' => 'confirmed',
        'confirmed' => 'preparing',
        'preparing' => 'ready',
        _ => null,
      };

  static String _buttonLabel(String status) => switch (status) {
        'pending' => 'CONFIRMAR',
        'confirmed' => 'EMPEZAR',
        'preparing' => 'MARCAR LISTO',
        _ => '—',
      };

  static Color _buttonColor(String status) => switch (status) {
        'pending' => AppTokens.info,
        'confirmed' => AppTokens.brandPrimary,
        'preparing' => AppTokens.success,
        _ => AppTokens.brandPrimary,
      };

  static Color _accentColor(Order o) {
    final mins = DateTime.now().difference(o.createdAt).inMinutes;
    if (o.status == 'pending') return AppTokens.info;
    if (mins > 20) return AppTokens.danger;
    if (o.status == 'preparing') return AppTokens.warning;
    return AppTokens.brandPrimary;
  }

  Future<void> _advance() async {
    final next = _nextStatus(widget.order.status);
    if (next == null) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(employeeOrderActionProvider.notifier)
          .updateStatus(orderId: widget.order.id, newStatus: next);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        title: Text(
          'Cancelar pedido',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        content: Text(
          '¿Seguro que quieres cancelar el pedido\n#${widget.order.id.substring(0, 6).toUpperCase()}?',
          style: GoogleFonts.inter(color: _kTextMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No, volver',
              style: GoogleFonts.inter(color: _kTextMuted),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
            ),
            child: Text(
              'Sí, cancelar',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(employeeOrderActionProvider.notifier)
          .updateStatus(orderId: widget.order.id, newStatus: 'cancelled');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Timer display ─────────────────────────────────────────────────────────
  static String _elapsed(DateTime t) {
    final m = DateTime.now().difference(t).inMinutes;
    if (m < 1) return 'Ahora';
    if (m < 60) return '${m}min';
    return '${(m / 60).floor()}h ${m % 60}min';
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final accent = _accentColor(o);
    final next = _nextStatus(o.status);
    final elapsed = DateTime.now().difference(o.createdAt).inMinutes;
    final isUrgent = elapsed > 20 && o.status != 'pending';
    // Carga los platos del ticket desde Supabase
    final itemsAsync = ref.watch(orderItemsProvider(o.id));

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Barra de color de estado ──────────────────────────────────
          Container(height: 4, color: accent),
          // ── Header ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '#${o.id.substring(0, 6).toUpperCase()}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _kTextPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                StatusBadge.fromString(o.status),
                const SizedBox(width: 4),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: 'Cancelar pedido',
                    onPressed: _loading ? null : _cancel,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: _kTextMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Tipo + hora ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Row(
              children: [
                OrderTypeBadge.fromString(o.orderType),
                const Spacer(),
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
          const SizedBox(height: 10),
          Container(height: 1, color: _kBorder),
          // ── Timer ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isUrgent ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isUrgent
                            ? Icons.warning_amber_rounded
                            : Icons.timer_outlined,
                        size: 13,
                        color: accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isUrgent
                            ? '¡${_elapsed(o.createdAt)}!'
                            : _elapsed(o.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
                if (o.notes != null && o.notes!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      o.notes!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _kTextMuted,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ── Platos del ticket ──────────────────────────────────────
          itemsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: _kBorder,
                color: AppTokens.brandPrimary,
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              final visible = items.take(4).toList();
              final more = items.length - visible.length;
              return Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1, color: _kBorder),
                    const SizedBox(height: 6),
                    ...visible.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagen del plato
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: item.dishImageUrl != null &&
                                      item.dishImageUrl!.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item.dishImageUrl!,
                                      width: 36,
                                      height: 36,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          _KitchenDishPlaceholder(),
                                      placeholder: (_, __) =>
                                          _KitchenDishPlaceholder(),
                                    )
                                  : _KitchenDishPlaceholder(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${item.quantity}\u00d7',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: AppTokens.brandPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: Text(
                                          item.dishName ?? '–',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: _kTextPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (item.notes != null &&
                                      item.notes!.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 2),
                                      child: Text(
                                        item.notes!,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: _kTextMuted,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (more > 0)
                      Text(
                        '+$more m\u00e1s...',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _kTextMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),
          // ── Botón acción ───────────────────────────────────────────────
          if (next != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SizedBox(
                height: 46,
                child: FilledButton(
                  onPressed: _loading ? null : _advance,
                  style: FilledButton.styleFrom(
                    backgroundColor: _buttonColor(o.status),
                    disabledBackgroundColor:
                        _buttonColor(o.status).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _buttonLabel(o.status),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: AppTokens.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  border: Border.all(
                    color: AppTokens.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: AppTokens.success,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LISTO',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTokens.success,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Encargo Card ──────────────────────────────────────────────────────────────

class _EncargoCard extends ConsumerStatefulWidget {
  const _EncargoCard({required this.order});
  final Order order;

  @override
  ConsumerState<_EncargoCard> createState() => _EncargoCardState();
}

class _EncargoCardState extends ConsumerState<_EncargoCard> {
  bool _loading = false;

  Future<void> _advance() async {
    final o = widget.order;
    final next = o.status == 'confirmed'
        ? 'preparing'
        : o.status == 'preparing'
            ? 'ready'
            : null;
    if (next == null) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(employeeOrderActionProvider.notifier)
          .updateStatus(orderId: o.id, newStatus: next);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    final o = widget.order;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _kSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        ),
        title: Text(
          'Cancelar encargo',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: _kTextPrimary,
          ),
        ),
        content: Text(
          '¿Seguro que quieres cancelar el encargo\n#${o.id.substring(0, 6).toUpperCase()}?',
          style: GoogleFonts.inter(color: _kTextMuted, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No, volver',
              style: GoogleFonts.inter(color: _kTextMuted),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTokens.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
            ),
            child: Text(
              'Sí, cancelar',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(employeeOrderActionProvider.notifier)
          .updateStatus(orderId: o.id, newStatus: 'cancelled');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final scheduled = o.scheduledAt;
    final daysUntil = scheduled?.difference(DateTime.now()).inDays;
    final isUrgent = daysUntil != null && daysUntil <= 1;
    final isPreparing = o.status == 'preparing';
    final isReady = o.status == 'ready';
    final accent = isUrgent ? AppTokens.danger : AppTokens.warning;
    final buttonLabel = isPreparing ? 'MARCAR LISTO' : 'EMPEZAR A PREPARAR';
    final buttonColor = isPreparing ? AppTokens.success : AppTokens.warning;

    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(
          color: isUrgent
              ? AppTokens.danger.withValues(alpha: 0.5)
              : _kBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: accent),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ID + urgencia
                Row(
                  children: [
                    Text(
                      '#${o.id.substring(0, 6).toUpperCase()}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (!isReady)
                      SizedBox(
                        width: 30,
                        height: 30,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Cancelar encargo',
                          onPressed: _loading ? null : _cancel,
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: _kTextMuted,
                          ),
                        ),
                      ),
                    const SizedBox(width: 4),
                    if (isUrgent)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTokens.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                          border: Border.all(
                            color: AppTokens.danger.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          daysUntil == 0 ? '⚠ HOY' : '⚠ MAÑANA',
                          style: GoogleFonts.inter(
                            color: AppTokens.danger,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      )
                    else
                      StatusBadge.fromString(o.status),
                  ],
                ),
                const SizedBox(height: 10),
                // Fecha programada
                if (scheduled != null)
                  Row(
                    children: [
                      Icon(Icons.event_rounded, size: 14, color: accent),
                      const SizedBox(width: 6),
                      Text(
                        Formatters.date(scheduled),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                      if (daysUntil != null && !isUrgent) ...[
                        const SizedBox(width: 6),
                        Text(
                          'en $daysUntil días',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _kTextMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                // Notas
                if (o.notes != null && o.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes_rounded,
                        size: 14,
                        color: _kTextMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          o.notes!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _kTextMuted,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                // Botón
                if (!isReady)
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _advance,
                      style: FilledButton.styleFrom(
                        backgroundColor: buttonColor,
                        disabledBackgroundColor:
                            buttonColor.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTokens.radiusSm),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              buttonLabel,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                    ),
                  )
                else
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTokens.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(
                        color: AppTokens.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_rounded,
                            color: AppTokens.success,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ENCARGO LISTO',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTokens.success,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
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

// ── _KitchenDishPlaceholder ───────────────────────────────────────────────────

class _KitchenDishPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _kBorder),
      ),
      child: const Icon(
        Icons.restaurant_menu_rounded,
        size: 16,
        color: _kTextMuted,
      ),
    );
  }
}

// ── Empty state KDS ───────────────────────────────────────────────────────────

class _EmptyKds extends StatelessWidget {
  const _EmptyKds({
    required this.icon,
    required this.label,
    required this.sub,
  });
  final IconData icon;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTokens.brandPrimary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: AppTokens.brandPrimary),
          ),
          const SizedBox(height: 18),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: GoogleFonts.inter(fontSize: 14, color: _kTextMuted),
          ),
        ],
      ),
    );
  }
}
