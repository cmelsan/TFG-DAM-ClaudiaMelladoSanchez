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

// ── Pantalla principal ────────────────────────────────────────────────────────

class DeliveryScreen extends ConsumerStatefulWidget {
  const DeliveryScreen({super.key});

  @override
  ConsumerState<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends ConsumerState<DeliveryScreen> {
  Timer? _autoRefresh;

  @override
  void initState() {
    super.initState();
    _autoRefresh = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(deliveryDetailProvider);
    });
  }

  @override
  void dispose() {
    _autoRefresh?.cancel();
    super.dispose();
  }

  void _refresh() => ref.invalidate(deliveryDetailProvider);

  @override
  Widget build(BuildContext context) {
    // Escucha errores del action provider
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

    final detailAsync = ref.watch(deliveryDetailProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Panel Reparto',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppTokens.brandPrimary,
            ),
            tooltip: 'Actualizar',
            onPressed: _refresh,
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => ErrorView(
          message: e.toString(),
          onRetry: _refresh,
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return _EmptyDelivery();
          }

          // Separar por estado
          final ready =
              orders.where((d) => d.order.status == 'ready').toList();
          final delivering =
              orders.where((d) => d.order.status == 'delivering').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              if (ready.isNotEmpty) ...[
                _SectionHeader(
                  icon: Icons.hourglass_top_rounded,
                  label: 'Listos para recoger',
                  count: ready.length,
                  color: AppTokens.brandPrimary,
                ),
                const SizedBox(height: 10),
                ...ready.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DeliveryCard(detail: d),
                    )),
              ],
              if (delivering.isNotEmpty) ...[
                if (ready.isNotEmpty) const SizedBox(height: 8),
                _SectionHeader(
                  icon: Icons.delivery_dining_rounded,
                  label: 'En reparto',
                  count: delivering.length,
                  color: AppTokens.warning,
                ),
                const SizedBox(height: 10),
                ...delivering.map((d) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DeliveryCard(detail: d),
                    )),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Cabecera de sección ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
          ),
          child: Text(
            '$count',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
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
                  '#${o.id.substring(0, 6).toUpperCase()}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                StatusBadge.fromString(o.status),
                const SizedBox(width: 10),
                Text(
                  TimeOfDay.fromDateTime(o.createdAt).format(context),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF8A8FA8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(height: 1, color: const Color(0xFFF0F0F0)),
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
                          color: const Color(0xFF8A8FA8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.fullAddress,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A2E),
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
                          color: const Color(0xFF8A8FA8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        d.clientDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1A2E),
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
            child: Container(height: 1, color: const Color(0xFFF0F0F0)),
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
                    color: const Color(0xFF8A8FA8),
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.price(o.total),
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1A1A2E),
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
            decoration: BoxDecoration(
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
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cuando un pedido esté listo aparecerá aquí',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF8A8FA8),
            ),
          ),
        ],
      ),
    );
  }
}
