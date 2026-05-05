import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sabor_de_casa/core/router/route_names.dart';
import 'package:sabor_de_casa/core/theme/app_tokens.dart';
import 'package:sabor_de_casa/core/utils/web_storage.dart';
import 'package:sabor_de_casa/features/cart/data/repositories/checkout_repository.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';
import 'package:sabor_de_casa/features/cart/presentation/providers/cart_provider.dart';
import 'package:sabor_de_casa/features/orders/presentation/providers/orders_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pantalla de retorno tras un pago web con Stripe Checkout.
/// Stripe redirige aquí con ?session_id=cs_xxx cuando el pago tiene éxito.
/// Lee los datos del pedido desde sessionStorage, lo crea en Supabase y
/// redirige a la pantalla de confirmación con el orderId obtenido.
class PaymentSuccessScreen extends ConsumerStatefulWidget {
  const PaymentSuccessScreen({super.key, this.sessionId});

  /// session_id devuelto por Stripe (en query params de la URL).
  final String? sessionId;

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    // Diferir hasta después del primer frame para evitar modificar providers
    // durante el build del árbol de widgets (requisito de Riverpod).
    WidgetsBinding.instance.addPostFrameCallback((_) => _createOrder());
  }

  Future<void> _createOrder() async {
    try {
      final raw = WebStorage.getItem('pendingOrder');
      if (raw == null) {
        // Sin datos pendientes Ã¢â€ ’ probablemente recarga manual; ir a pedidos.
        if (mounted) context.goNamed(RouteNames.orders);
        return;
      }

      // Esperar sesión sin pasar por Riverpod: authNotifierProvider.future puede
      // lanzar "Bad state: Future already completed" (bug interno de gotrue-dart
      // al completar dos veces el mismo Completer durante la restauración de sesión
      // tras un redirect de Stripe). Aquí sondeamos directamente el cliente.
      for (var i = 0; i < 30; i++) {
        if (Supabase.instance.client.auth.currentUser != null) break;
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      if (!mounted) return;

      if (Supabase.instance.client.auth.currentUser == null) {
        context.goNamed(RouteNames.login);
        return;
      }

      final data = jsonDecode(raw) as Map<String, dynamic>;
      WebStorage.removeItem('pendingOrder');

      final itemsList = (data['items'] as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .toList();

      // Usar el repositorio directamente (keepAlive: true) en lugar de
      // checkoutSubmitProvider (auto-dispose) para evitar que el notifier
      // sea destruido mientras la operación async está en vuelo.
      final orderId = await ref
          .read(checkoutRepositoryProvider)
          .createOrder(
            items: itemsList,
            orderType: data['orderType'] as String,
            notes: (data['notes'] as String?) ?? '',
            paymentMethod: 'card',
            scheduledAt: data['scheduledAt'] != null
                ? DateTime.parse(data['scheduledAt'] as String)
                : null,
            paymentStatus: 'paid',
          );

      if (!mounted) return;

      // Limpiar carrito e invalidar caché de pedidos en background.
      ref.invalidate(ordersProvider);
      ref.read(cartNotifierProvider.notifier).clearCart();

      // Navegar a la pantalla de confirmación con el orderId real.
      context.goNamed(
        RouteNames.orderConfirmation,
        pathParameters: {'orderId': orderId},
      );
    } catch (e) {
      WebStorage.removeItem('pendingOrder'); // limpiar en caso de error
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTokens.pageBg,
      body: Center(
        child: _error != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al crear el pedido',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _error = null;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.brandPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reintentar'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context.goNamed(RouteNames.cart),
                    child: const Text('Volver al carrito'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppTokens.brandPrimary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Procesando tu pedido...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por favor, no cierres esta ventana',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
      ),
    );
  }
}
