import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

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

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen> {
  String _statusFilter = 'all';
  String _typeFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return AdminShell(
      title: 'Pedidos',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTokens.brandPrimary),
          tooltip: 'Actualizar',
          onPressed: () => ref.invalidate(adminOrdersProvider),
        ),
        const SizedBox(width: 8),
      ],
      child: ordersAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => Center(
          child: ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(adminOrdersProvider),
          ),
        ),
        data: (orders) {
          final filtered = orders.where((o) {
            final statusOk = _statusFilter == 'all' || o.status == _statusFilter;
            final typeOk = _typeFilter == 'all' || o.orderType == _typeFilter;
            return statusOk && typeOk;
          }).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FilterSection(
                orders: orders,
                statusFilter: _statusFilter,
                typeFilter: _typeFilter,
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onTypeChanged: (v) => setState(() => _typeFilter = v),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F0F0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.inbox_rounded,
                                  size: 28, color: Color(0xFF9E9E9E)),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No hay pedidos con estos filtros',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF9E9E9E),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (ctx, i) =>
                            _OrderCard(order: filtered[i], index: i),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Filtros ───────────────────────────────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.orders,
    required this.statusFilter,
    required this.typeFilter,
    required this.onStatusChanged,
    required this.onTypeChanged,
  });

  final List<Order> orders;
  final String statusFilter;
  final String typeFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onTypeChanged;

  int _count(String status) => status == 'all'
      ? orders.length
      : orders.where((o) => o.status == status).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _PillChip(
                  label: 'Todos',
                  count: _count('all'),
                  selected: statusFilter == 'all',
                  color: const Color(0xFF1A1A2E),
                  onTap: () => onStatusChanged('all'),
                ),
                for (final s in _statusOptions)
                  _PillChip(
                    label: _statusLabels[s]!,
                    count: _count(s),
                    selected: statusFilter == s,
                    color: _statusColor(s),
                    onTap: () => onStatusChanged(s),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Tipo
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _PillChip(
                  label: 'Todos los tipos',
                  selected: typeFilter == 'all',
                  color: const Color(0xFF1A1A2E),
                  onTap: () => onTypeChanged('all'),
                ),
                for (final e in _typeLabels.entries)
                  _PillChip(
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

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          border: Border.all(
            color: selected ? color : const Color(0xFFDDDDDD),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : const Color(0xFF666680),
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.25)
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusPill),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : color,
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
                    '#${o.id.substring(0, 8).toUpperCase()}',
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
                      value: o.status,
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
                  Row(
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
                      const Spacer(),
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
                          Divider(
                            height: 1,
                            color: const Color(0xFFEEEEEE),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
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
                                child: Text(
                                  items[i].dishName ?? 'Producto',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: const Color(0xFF1A1A2E),
                                  ),
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
