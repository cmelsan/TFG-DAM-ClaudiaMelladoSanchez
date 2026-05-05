import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';
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
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.unitPrice * item.quantity),
    );
    final deliveryFee = _orderType == 'domicilio' ? 2.50 : 0.0;
    final total = subtotal + deliveryFee;

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

    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      appBar: AppBar(title: const Text('Confirmar pago'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen de pedido
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del pedido',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(
                            '${item.quantity}x',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTokens.brandPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            Formatters.price(item.unitPrice * item.quantity),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Detalles de entrega
            const Text(
              'Opciones de entrega',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E3)),
              ),
              child: RadioGroup<String>(
                groupValue: _orderType,
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _orderType = value;
                    _paymentMethod = 'card';
                    if (value == 'encargo') _scheduledAt = null;
                  });
                },
                child: Column(
                  children: [
                    const RadioListTile<String>(
                      title: Text(
                        'Entrega a domicilio',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '20-30 min · 2,50 €',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      activeColor: AppTokens.brandPrimary,
                      value: 'domicilio',
                    ),
                    const Divider(height: 1),
                    const RadioListTile<String>(
                      title: Text(
                        'Recoger en restaurante',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        '10-15 min',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      activeColor: AppTokens.brandPrimary,
                      value: 'recogida',
                    ),
                    const Divider(height: 1),
                    const RadioListTile<String>(
                      title: Text(
                        'Encargo',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Programar fecha futura',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      activeColor: AppTokens.brandPrimary,
                      value: 'encargo',
                    ),
                    if (_orderType == 'encargo')
                      _DatePickerTile(
                        selectedDate: _scheduledAt,
                        onDateSelected: (date) =>
                            setState(() => _scheduledAt = date),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Detalles de entrega
            const Text(
              'Método de pago',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E5E3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _paymentMethod,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: _buildPaymentItems(_orderType),
                  onChanged: (value) {
                    if (value != null) setState(() => _paymentMethod = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notas
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: _orderType == 'domicilio'
                    ? 'Ej. Alergias, instrucciones para el repartidor...'
                    : 'Ej. Alergias, instrucciones especiales...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE5E5E3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTokens.brandPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
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
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (submitState.isLoading || _stripeLoading)
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

  List<DropdownMenuItem<String>> _buildPaymentItems(String orderType) {
    // Opciones online (tarjeta): siempre disponible
    const cardItem = DropdownMenuItem<String>(
      value: 'card',
      child: Row(
        children: [
          Icon(Icons.credit_card, color: Colors.black54),
          SizedBox(width: 12),
          Text(
            'Tarjeta de crédito/débito',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );

    if (orderType == 'domicilio') {
      return [
        cardItem,
        const DropdownMenuItem<String>(
          value: 'cash',
          child: Row(
            children: [
              Icon(Icons.money, color: Colors.black54),
              SizedBox(width: 12),
              Text(
                'Efectivo (al repartidor)',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ];
    }

    // encargo / recogida: pago online o en local
    return [
      cardItem,
      const DropdownMenuItem<String>(
        value: 'cash',
        child: Row(
          children: [
            Icon(Icons.money, color: Colors.black54),
            SizedBox(width: 12),
            Text(
              'Efectivo (en el local)',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      const DropdownMenuItem<String>(
        value: 'tpv',
        child: Row(
          children: [
            Icon(Icons.point_of_sale, color: Colors.black54),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Tarjeta en local (TPV)',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    ];
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
          );
          if (date != null) onDateSelected(date);
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
                          ? 'Fecha: ${Formatters.date(selectedDate!)}'
                          : 'Selecciona la fecha del encargo',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selectedDate != null
                            ? AppTokens.brandPrimary
                            : Colors.orange.shade700,
                      ),
                    ),
                    Text(
                      'Mínimo $minDays ${minDays == 1 ? 'día' : 'días'} de antelación',
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
