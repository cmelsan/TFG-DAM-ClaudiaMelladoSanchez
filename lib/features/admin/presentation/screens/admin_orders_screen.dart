import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/widgets/error_view.dart';
import 'package:sabor_de_casa/core/widgets/loading_indicator.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/admin/presentation/widgets/admin_shell.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

const _statusOptions = [
  'pending',
  'confirmed',
  'preparing',
  'ready',
  'delivering',
  'delivered',
  'cancelled',
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
const _statusColors = {
  'pending': Colors.orange,
  'confirmed': Colors.blue,
  'preparing': Colors.purple,
  'ready': Colors.teal,
  'delivering': Colors.indigo,
  'delivered': Colors.green,
  'cancelled': Colors.red,
};
const _typeLabels = {
  'delivery': 'Reparto',
  'domicilio': 'Domicilio',
  'recogida': 'Recogida',
  'encargo': 'Encargo',
  'mostrador': 'Mostrador',
};

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
      child: ordersAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: () => ref.invalidate(adminOrdersProvider),
        ),
        data: (orders) {
          final filtered = orders.where((o) {
            final statusOk =
                _statusFilter == 'all' || o.status == _statusFilter;
            final typeOk = _typeFilter == 'all' || o.orderType == _typeFilter;
            return statusOk && typeOk;
          }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return Column(
            children: [
              _FilterBar(
                statusFilter: _statusFilter,
                typeFilter: _typeFilter,
                orders: orders,
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onTypeChanged: (v) => setState(() => _typeFilter = v),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay pedidos con estos filtros',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) =>
                            _OrderCard(order: filtered[i], index: i, ref: ref),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Filter Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.statusFilter,
    required this.typeFilter,
    required this.orders,
    required this.onStatusChanged,
    required this.onTypeChanged,
  });

  final String statusFilter;
  final String typeFilter;
  final List<Order> orders;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onTypeChanged;

  int _count(List<Order> orders, String status) => status == 'all'
      ? orders.length
      : orders.where((o) => o.status == status).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          // Status chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'Todos (${_count(orders, 'all')})',
                  selected: statusFilter == 'all',
                  onTap: () => onStatusChanged('all'),
                ),
                for (final s in _statusOptions)
                  _FilterChip(
                    label: '${_statusLabels[s]} (${_count(orders, s)})',
                    selected: statusFilter == s,
                    color: _statusColors[s] as Color?,
                    onTap: () => onStatusChanged(s),
                  ),
              ],
            ),
          ),
          // Type chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  label: 'Todos los tipos',
                  selected: typeFilter == 'all',
                  onTap: () => onTypeChanged('all'),
                ),
                for (final e in _typeLabels.entries)
                  _FilterChip(
                    label: e.value,
                    selected: typeFilter == e.key,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppTokens.brandPrimary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? activeColor : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Order Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _OrderCard extends StatefulWidget {
  const _OrderCard({
    required this.order,
    required this.index,
    required this.ref,
  });
  final Order order;
  final int index;
  final WidgetRef ref;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  Color get _statusColor =>
      (_statusColors[widget.order.status] as Color?) ?? Colors.grey;

  String get _statusLabel =>
      _statusLabels[widget.order.status] ?? widget.order.status;

  String get _typeLabel =>
      _typeLabels[widget.order.orderType] ?? widget.order.orderType;

  void _showCancelDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar pedido'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Motivo de cancelación…',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Volver'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              widget.ref
                  .read(adminActionProvider.notifier)
                  .cancelOrderWithReason(
                    orderId: widget.order.id,
                    reason: controller.text.trim(),
                  );
            },
            child: const Text('Confirmar cancelación'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isCancelled = order.status == 'cancelled';
    final needsPayment =
        order.paymentStatus == 'pending' &&
        (order.paymentMethod == 'cash' || order.paymentMethod == 'tpv') &&
        (order.orderType == 'recogida' ||
            order.orderType == 'encargo' ||
            order.orderType == 'mostrador') &&
        order.status == 'ready';

    return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: needsPayment
                ? Border.all(color: Colors.orange, width: 2)
                : Border.all(color: Colors.transparent),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Cabecera
              InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Status dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      // ID + tipo + fecha
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${order.id.substring(0, 8).toUpperCase()}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Color(0xFF111111),
                              ),
                            ),
                            Text(
                              '$_typeLabel • ${Formatters.dateTime(order.createdAt)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Total
                      Text(
                        Formatters.price(order.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // Detalle expandible
              if (_expanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badges
                      Wrap(
                        spacing: 8,
                        children: [
                          _Badge(label: _statusLabel, color: _statusColor),
                          _Badge(
                            label: order.paymentStatus == 'paid'
                                ? 'Pagado'
                                : 'Pdte. pago',
                            color: order.paymentStatus == 'paid'
                                ? Colors.green
                                : Colors.orange,
                          ),
                          if (order.paymentMethod != null)
                            _Badge(
                              label: order.paymentMethod!.toUpperCase(),
                              color: Colors.blueGrey,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Cambiar estado
                      if (!isCancelled) ...[
                        const Text(
                          'ESTADO DEL PEDIDO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: order.status,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            isDense: true,
                          ),
                          items: _statusOptions
                              .where((s) => s != 'cancelled')
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(_statusLabels[s] ?? s),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v == null || v == order.status) return;
                            widget.ref
                                .read(adminActionProvider.notifier)
                                .updateOrderStatus(
                                  orderId: order.id,
                                  status: v,
                                );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Notas
                      if (order.notes != null && order.notes!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E5E3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Nota: ${order.notes}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // Acciones
                      Row(
                        children: [
                          if (!isCancelled)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              onPressed: _showCancelDialog,
                              icon: const Icon(Icons.cancel_outlined, size: 16),
                              label: const Text(
                                'Cancelar pedido',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          const Spacer(),
                          if (needsPayment)
                            FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              onPressed: () => widget.ref
                                  .read(adminActionProvider.notifier)
                                  .markPaymentPaid(order.id),
                              icon: const Icon(
                                Icons.payments_outlined,
                                size: 16,
                              ),
                              label: const Text(
                                'Cobrar',
                                style: TextStyle(fontSize: 12),
                              ),
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
        .fadeIn(duration: 250.ms, delay: (widget.index * 30).ms)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: 250.ms,
          delay: (widget.index * 30).ms,
        );
  }
}

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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
