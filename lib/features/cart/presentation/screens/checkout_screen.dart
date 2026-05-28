import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/formatters.dart';
import 'package:sabor_de_casa/core/utils/web_storage.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/checkout_provider.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _notesCtrl = TextEditingController();
  bool _stripeLoading = false;
  String _orderType = 'domicilio';
  String _paymentMethod = 'card';
  DateTime? _scheduledAt;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartItemsProvider);
    final submitState = ref.watch(checkoutSubmitProvider);
    final eligibilityAsync = ref.watch(isEligibleForFirstOrderDiscountProvider);
    final acceptingAsync = ref.watch(acceptingOrdersProvider);
    final isOrdersPaused = acceptingAsync.valueOrNull == false &&
        _orderType != 'encargo';
    final discountOrderTypes = ['domicilio', 'recogida'];
    final isEligible = (eligibilityAsync.valueOrNull ?? false) &&
        discountOrderTypes.contains(_orderType);
    final isEligibilityLoading = eligibilityAsync.isLoading &&
        discountOrderTypes.contains(_orderType);
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
    final discountAmount = isEligible
        ? double.parse((subtotal * 0.30).toStringAsFixed(2))
        : 0.0;
    final deliveryFee = _orderType == 'domicilio' ? 2.50 : 0.0;
    final total = subtotal - discountAmount + deliveryFee;

    ref.listen(checkoutSubmitProvider, (prev, next) {
      if ((prev?.isLoading ?? false) && next.hasValue && next.value != null) {
        ref.invalidate(ordersProvider);
        ref.read(cartNotifierProvider.notifier).clearCart();
        // Navegar a la pantalla de confirmación con el orderId devuelto.
        context.goNamed(
          RouteNames.orderConfirmation,
          pathParameters: {'orderId': next.value!},
        );
      }
      if ((prev?.isLoading ?? false) && next.hasError) {
        final err = next.error;
        showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error al realizar el pedido'),
            content: Text(err.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    });

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirmar pago')),
        body: const Center(child: Text('No hay productos en el carrito')),
      );
    }

    final isWide = MediaQuery.sizeOf(context).width > 850;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Navbar ──────────────────────────────────────────────────────────
          Container(
            height: 68,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1160),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.goNamed(RouteNames.cart),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 15,
                                color: Color(0xFF444444),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Mi carrito',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF444444),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Confirmar pedido',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111111),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Content ─────────────────────────────────────────────────────────
          Expanded(
            child: isWide
                ? SingleChildScrollView(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1160),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Confirmar pedido',
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF111111),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Elige cómo quieres recibir tu pedido y cómo pagar.',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 32),
                                    _buildDeliverySection(isWide: true),
                                    const SizedBox(height: 32),
                                    _buildPaymentSection(isWide: true),
                                    const SizedBox(height: 32),
                                    _buildNotesSection(isWide: true),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 32),
                              SizedBox(
                                width: 360,
                                child: _buildSummaryPanel(
                                  items: items,
                                  subtotal: subtotal,
                                  discountAmount: discountAmount,
                                  deliveryFee: deliveryFee,
                                  total: total,
                                  isEligible: isEligible,
                                  isEligibilityLoading: isEligibilityLoading,
                                  isOrdersPaused: isOrdersPaused,
                                  submitState: submitState,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDeliverySection(),
                        const SizedBox(height: 24),
                        _buildPaymentSection(),
                        const SizedBox(height: 24),
                        _buildNotesSection(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
      bottomSheet: isWide ? null : Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Subtotal',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    Formatters.price(subtotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (isEligibilityLoading) ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comprobando descuento…',
                      style: TextStyle(
                        color: Colors.black38,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AppTokens.brandPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ] else if (isEligible) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🎉 Dto. primer pedido (30%)',
                      style: TextStyle(
                        color: AppTokens.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '- ${Formatters.price(discountAmount)}',
                      style: const TextStyle(
                        color: AppTokens.brandPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Envío', style: TextStyle(color: Colors.black54)),
                  Text(
                    Formatters.price(deliveryFee),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total a pagar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    Formatters.price(total),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: AppTokens.brandPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Banner de pedidos pausados
              if (isOrdersPaused)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.pause_circle_outline_rounded,
                        color: Color(0xFF856404),
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'El negocio no est\u00e1 aceptando pedidos en este momento. Int\u00e9ntalo m\u00e1s tarde.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF856404),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (submitState.isLoading ||
                          _stripeLoading ||
                          isEligibilityLoading ||
                          isOrdersPaused)
                      ? null
                      : () async {
                          if (_orderType == 'encargo' && _scheduledAt == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Selecciona una fecha para el encargo',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          if (_paymentMethod == 'card') {
                            await _processStripePayment(
                              items: items,
                              total: total,
                            );
                          } else {
                            unawaited(
                              ref
                                  .read(checkoutSubmitProvider.notifier)
                                  .submit(
                                    items: items,
                                    orderType: _orderType,
                                    notes: _notesCtrl.text,
                                    paymentMethod: _paymentMethod,
                                    scheduledAt: _scheduledAt,
                                  ),
                            );
                          }
                        },
                  child: (submitState.isLoading || _stripeLoading)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Realizar pedido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── UI Helpers ────────────────────────────────────────────────────────────

  Widget _sectionTitle(IconData icon, String text, {bool isWide = false}) {
    if (isWide) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: Color(0xFF111111),
            letterSpacing: -0.2,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTokens.brandLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppTokens.brandPrimary),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF111111)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection({bool isWide = false}) {
    if (isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.local_shipping_outlined, 'Opciones de entrega', isWide: true),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _deliveryCard(
                    value: 'domicilio',
                    icon: Icons.directions_bike_outlined,
                    title: 'A domicilio',
                    subtitle: '20-30 min',
                    badge: '+\u202f2,50\u202f€',
                    isWide: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _deliveryCard(
                    value: 'recogida',
                    icon: Icons.storefront_outlined,
                    title: 'Recoger en local',
                    subtitle: '10-15 min',
                    badge: 'Gratis',
                    isWide: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _deliveryCard(
                    value: 'encargo',
                    icon: Icons.calendar_month_outlined,
                    title: 'Encargo',
                    subtitle: 'Fecha futura',
                    badge: null,
                    isWide: true,
                  ),
                ),
              ],
            ),
          ),
          if (_orderType == 'encargo') ...[
            const SizedBox(height: 14),
            _DatePickerTile(
              selectedDate: _scheduledAt,
              onDateSelected: (date) => setState(() => _scheduledAt = date),
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.local_shipping_outlined, 'Opciones de entrega'),
        _deliveryCard(
          value: 'domicilio',
          icon: Icons.directions_bike_outlined,
          title: 'Entrega a domicilio',
          subtitle: '20-30 min',
          badge: '+\u202f2,50\u202f€',
        ),
        const SizedBox(height: 8),
        _deliveryCard(
          value: 'recogida',
          icon: Icons.storefront_outlined,
          title: 'Recoger en restaurante',
          subtitle: '10-15 min',
          badge: 'Gratis',
        ),
        const SizedBox(height: 8),
        _deliveryCard(
          value: 'encargo',
          icon: Icons.calendar_month_outlined,
          title: 'Encargo',
          subtitle: 'Programar fecha futura',
          badge: null,
        ),
        if (_orderType == 'encargo') ...[
          const SizedBox(height: 10),
          _DatePickerTile(
            selectedDate: _scheduledAt,
            onDateSelected: (date) => setState(() => _scheduledAt = date),
          ),
        ],
      ],
    );
  }

  Widget _deliveryCard({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    required String? badge,
    bool isWide = false,
  }) {
    final isSelected = _orderType == value;

    if (isWide) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() {
            _orderType = value;
            _paymentMethod = 'card';
            if (value != 'encargo') _scheduledAt = null;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTokens.brandLight : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppTokens.brandPrimary : const Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? AppTokens.brandPrimary : const Color(0xFF888888),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppTokens.brandPrimary,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isSelected ? AppTokens.brandDark : const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTokens.brandPrimary : const Color(0xFFF0F0EE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF666666),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Versión estrecha (móvil)
    return GestureDetector(
      onTap: () => setState(() {
        _orderType = value;
        _paymentMethod = 'card';
        if (value != 'encargo') _scheduledAt = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTokens.brandLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTokens.brandPrimary : const Color(0xFFE5E5E3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? AppTokens.brandPrimary : const Color(0xFFF0F0EE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF666666), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected ? AppTokens.brandDark : const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF888888))),
                ],
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppTokens.brandPrimary : const Color(0xFFF0F0EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF666666),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 10),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppTokens.brandPrimary : const Color(0xFFCCCCCC),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection({bool isWide = false}) {
    final options = _getPaymentOptions(_orderType);
    if (isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.payment_outlined, 'Método de pago', isWide: true),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int i = 0; i < options.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _paymentCard(
                      value: options[i]['value'] as String,
                      icon: options[i]['icon'] as IconData,
                      title: options[i]['title'] as String,
                      subtitle: options[i]['subtitle'] as String?,
                      isWide: true,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.payment_outlined, 'Método de pago'),
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _paymentCard(
            value: options[i]['value'] as String,
            icon: options[i]['icon'] as IconData,
            title: options[i]['title'] as String,
            subtitle: options[i]['subtitle'] as String?,
          ),
        ],
      ],
    );
  }

  Widget _paymentCard({
    required String value,
    required IconData icon,
    required String title,
    String? subtitle,
    bool isWide = false,
  }) {
    final isSelected = _paymentMethod == value;

    if (isWide) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _paymentMethod = value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTokens.brandLight : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppTokens.brandPrimary : const Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: isSelected ? AppTokens.brandPrimary : const Color(0xFF888888),
                    ),
                    const Spacer(),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppTokens.brandPrimary,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isSelected ? AppTokens.brandDark : const Color(0xFF111111),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Versión estrecha (móvil)
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTokens.brandLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTokens.brandPrimary : const Color(0xFFE5E5E3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? []
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTokens.brandPrimary : const Color(0xFF666666), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                      color: isSelected ? AppTokens.brandDark : const Color(0xFF111111),
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTokens.brandPrimary : const Color(0xFFCCCCCC),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection({bool isWide = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _sectionTitle(Icons.edit_note_outlined, 'Notas del pedido', isWide: isWide),
      TextField(
        controller: _notesCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: _orderType == 'domicilio'
              ? 'Ej. Alergias, instrucciones para el repartidor...'
              : 'Ej. Alergias, instrucciones especiales...',
          hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 14),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E5E3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5E5E3)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTokens.brandPrimary, width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    ],
  );

  List<Map<String, dynamic>> _getPaymentOptions(String orderType) {
    final card = <String, dynamic>{
      'value': 'card',
      'icon': Icons.credit_card_outlined,
      'title': 'Tarjeta de crédito/débito',
      'subtitle': 'Pago seguro con Stripe',
    };
    if (orderType == 'domicilio') {
      return [
        card,
        <String, dynamic>{
          'value': 'cash',
          'icon': Icons.money_outlined,
          'title': 'Efectivo (al repartidor)',
          'subtitle': null,
        },
      ];
    }
    return [
      card,
      <String, dynamic>{
        'value': 'cash',
        'icon': Icons.money_outlined,
        'title': 'Efectivo (en el local)',
        'subtitle': null,
      },
      <String, dynamic>{
        'value': 'tpv',
        'icon': Icons.point_of_sale_outlined,
        'title': 'Tarjeta en local (TPV)',
        'subtitle': null,
      },
    ];
  }

  Widget _buildSummaryPanel({
    required List<CartItem> items,
    required double subtotal,
    required double discountAmount,
    required double deliveryFee,
    required double total,
    required bool isEligible,
    required bool isEligibilityLoading,
    required bool isOrdersPaused,
    required AsyncValue<String?> submitState,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Resumen del pedido',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111111),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 20),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppTokens.brandLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTokens.brandPrimary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        Formatters.price(item.unitPrice * item.quantity),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 28),
              _summaryRow('Subtotal', Formatters.price(subtotal)),
              if (isEligibilityLoading) ...[
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Expanded(
                      child: Text('Comprobando descuento…', style: TextStyle(color: Color(0xFF888888), fontSize: 13)),
                    ),
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTokens.brandPrimary),
                    ),
                  ],
                ),
              ] else if (isEligible) ...[
                const SizedBox(height: 10),
                _summaryRow('🎉 Dto. primer pedido (30%)', '- ${Formatters.price(discountAmount)}', green: true),
              ],
              const SizedBox(height: 10),
              _summaryRow(
                _orderType == 'domicilio' ? 'Envío a domicilio' : 'Envío',
                Formatters.price(deliveryFee),
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total a pagar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    Formatters.price(total),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: AppTokens.brandPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isOrdersPaused) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFC107).withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.pause_circle_outline_rounded, color: Color(0xFF856404), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'El negocio no está aceptando pedidos en este momento.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF856404)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTokens.brandPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  onPressed: (submitState.isLoading || _stripeLoading || isEligibilityLoading || isOrdersPaused)
                      ? null
                      : () async {
                          if (_orderType == 'encargo' && _scheduledAt == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Selecciona fecha y hora para el encargo'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }
                          if (_paymentMethod == 'card') {
                            await _processStripePayment(items: items, total: total);
                          } else {
                            unawaited(
                              ref.read(checkoutSubmitProvider.notifier).submit(
                                items: items,
                                orderType: _orderType,
                                notes: _notesCtrl.text,
                                paymentMethod: _paymentMethod,
                                scheduledAt: _scheduledAt,
                              ),
                            );
                          }
                        },
                  child: (submitState.isLoading || _stripeLoading)
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Realizar pedido'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: Color(0xFF888888)),
                  const SizedBox(width: 6),
                  Text(
                    'Pago 100% seguro',
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ],
          ),
      );

  Widget _summaryRow(String label, String value, {bool green = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: green ? AppTokens.brandPrimary : const Color(0xFF555555),
            fontWeight: green ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: green ? AppTokens.brandPrimary : const Color(0xFF111111),
          ),
        ),
      ],
    ),
  );

  Future<void> _processStripePayment({
    required List<CartItem> items,
    required double total,
  }) async {
    // En web flutter_stripe (PaymentSheet) no funciona → Stripe Checkout redirect
    if (kIsWeb) {
      await _processWebStripePayment(items: items, total: total);
      return;
    }

    setState(() => _stripeLoading = true);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    try {
      // 1. Solicitar PaymentIntent a la Edge Function
      final response = await Supabase.instance.client.functions.invoke(
        'create-payment-intent',
        body: {'amount': (total * 100).ceil(), 'currency': 'eur'},
      );

      final data = response.data as Map<String, dynamic>? ?? {};
      final clientSecret = data['clientSecret'] as String?;
      if (clientSecret == null) {
        throw Exception(data['error'] ?? 'Error al iniciar el pago');
      }

      // 2. Inicializar PaymentSheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Sabor de Casa',
          style: isDark ? ThemeMode.dark : ThemeMode.light,
        ),
      );

      // 3. Presentar PaymentSheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Pago aceptado → crear pedido como 'paid'
      if (!mounted) return;
      unawaited(
        ref
            .read(checkoutSubmitProvider.notifier)
            .submit(
              items: items,
              orderType: _orderType,
              notes: _notesCtrl.text,
              paymentMethod: 'card',
              scheduledAt: _scheduledAt,
              paymentStatus: 'paid',
            ),
      );
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return; // usuario canceló
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error de pago: ${e.error.localizedMessage ?? e.error.message}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _stripeLoading = false);
    }
  }

  /// Pago web: guarda el pedido en sessionStorage y redirige a Stripe Checkout.
  Future<void> _processWebStripePayment({
    required List<CartItem> items,
    required double total,
  }) async {
    setState(() => _stripeLoading = true);
    try {
      // Serializar datos del pedido para recuperarlos tras el redirect
      final orderData = jsonEncode({
        'items': items.map((i) => i.toJson()).toList(),
        'orderType': _orderType,
        'notes': _notesCtrl.text,
        'scheduledAt': _scheduledAt?.toIso8601String(),
      });
      WebStorage.setItem('pendingOrder', orderData);

      final origin = WebStorage.currentOrigin;
      final response = await Supabase.instance.client.functions.invoke(
        'create-payment-intent',
        body: {
          'type': 'checkout',
          'amount': (total * 100).ceil(),
          'currency': 'eur',
          'successUrl': '$origin/#/payment/success',
          'cancelUrl': '$origin/#/cart',
        },
      );

      if (response.data == null) {
        throw Exception('Respuesta vacía del servidor de pagos');
      }
      final webData = response.data as Map<String, dynamic>;
      final url = webData['url'] as String?;
      if (url == null) {
        final err = webData['error'] ?? 'Error desconocido';
        throw Exception(err);
      }

      // Redirigir al hosted checkout de Stripe
      WebStorage.redirectTo(url);
    } catch (e) {
      WebStorage.removeItem('pendingOrder'); // limpiar si falla
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      setState(() => _stripeLoading = false);
    }
  }

}

class _DatePickerTile extends ConsumerWidget {
  const _DatePickerTile({
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minDaysAsync = ref.watch(encargoMinDaysProvider);
    final minDays = minDaysAsync.valueOrNull ?? 2;
    final firstDate = DateTime.now().add(Duration(days: minDays));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? firstDate,
            firstDate: firstDate,
            lastDate: DateTime.now().add(const Duration(days: 365)),
            helpText: 'Selecciona la fecha del encargo',
            locale: const Locale('es'),
            builder: (ctx, child) {
              final wide = MediaQuery.sizeOf(ctx).width > 850;
              if (!wide) return child!;
              return MediaQuery(
                data: MediaQuery.of(ctx).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: child!,
              );
            },
          );
          if (date == null || !context.mounted) return;

          final time = await showTimePicker(
            context: context,
            initialTime: selectedDate != null
                ? TimeOfDay.fromDateTime(selectedDate!)
                : const TimeOfDay(hour: 12, minute: 0),
            helpText: 'Selecciona la hora de recogida',
          );
          if (time == null) return;

          onDateSelected(DateTime(date.year, date.month, date.day, time.hour, time.minute));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: selectedDate != null
                ? AppTokens.brandPrimary.withValues(alpha: 0.1)
                : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedDate != null
                  ? AppTokens.brandPrimary.withValues(alpha: 0.4)
                  : Colors.orange.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event,
                color: selectedDate != null
                    ? AppTokens.brandPrimary
                    : Colors.orange.shade700,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedDate != null
                          ? 'Fecha: ${Formatters.dateTime(selectedDate!)}'
                          : 'Selecciona fecha y hora del encargo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selectedDate != null
                            ? AppTokens.brandPrimary
                            : Colors.orange.shade700,
                      ),
                    ),
                    Text(
                      selectedDate == null ? 'Mínimo $minDays ${minDays == 1 ? 'día' : 'días'} de antelación · Elige fecha y hora' : 'Mínimo $minDays ${minDays == 1 ? 'día' : 'días'} de antelación',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
