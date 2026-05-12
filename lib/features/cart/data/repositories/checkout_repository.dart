import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/cart/domain/models/cart_item.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'checkout_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
CheckoutRepository checkoutRepository(CheckoutRepositoryRef ref) {
  return CheckoutRepository(ref.watch(supabaseClientProvider));
}

class CheckoutRepository {
  CheckoutRepository(this._client);

  final SupabaseClient _client;

  Future<String> createOrder({
    required List<CartItem> items,
    required String orderType,
    String? notes,
    String paymentMethod = 'cash',
    DateTime? scheduledAt,
    String paymentStatus = 'pending',
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(
          message: 'Debes iniciar sesión para finalizar el pedido',
        );
      }

      final subtotal = items.fold<double>(
        0,
        (sum, item) => sum + (item.unitPrice * item.quantity),
      );
      final deliveryFee = orderType == 'domicilio' ? 2.5 : 0.0;

      // — Descuento primer pedido —
      final discountAmount = await _computeFirstOrderDiscount(
        userId: userId,
        subtotal: subtotal,
      );

      final total = subtotal - discountAmount + deliveryFee;

      final order = await _client
          .from(SupabaseConstants.orders)
          .insert({
            'user_id': userId,
            'order_type': orderType,
            'status': 'pending',
            'payment_status': paymentStatus,
            'payment_method': paymentMethod,
            'subtotal': subtotal,
            'delivery_fee': deliveryFee,
            'discount_amount': discountAmount,
            'total': total,
            'notes': notes?.trim().isEmpty ?? true ? null : notes?.trim(),
            if (scheduledAt != null)
              'scheduled_at': scheduledAt.toIso8601String(),
          })
          .select('id')
          .single();

      final orderId = order['id'] as String;
      final orderItems = items
          .map(
            (item) => {
              'order_id': orderId,
              'dish_id': item.dishId,
              'quantity': item.quantity,
              'unit_price': item.unitPrice,
              'subtotal': item.unitPrice * item.quantity,
            },
          )
          .toList();

      await _client.from(SupabaseConstants.orderItems).insert(orderItems);
      return orderId;
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Devuelve el importe del descuento de primer pedido (30% del subtotal)
  /// si el descuento está activo en la configuración y el usuario no tiene
  /// pedidos anteriores. En cualquier otro caso devuelve 0.
  Future<double> _computeFirstOrderDiscount({
    required String userId,
    required double subtotal,
  }) async {
    try {
      // 1. ¿Está el descuento habilitado en la configuración?
      final configRow = await _client
          .from('business_config')
          .select('value')
          .eq('key', 'first_order_discount_enabled')
          .maybeSingle();

      final discountEnabled = configRow?['value'] as String?;
      if (discountEnabled == 'false') return 0.0;

      // 2. ¿Tiene el usuario pedidos anteriores (no cancelados)?
      final countResult = await _client
          .from(SupabaseConstants.orders)
          .select('id')
          .eq('user_id', userId)
          .neq('status', 'cancelled');

      if ((countResult as List).isNotEmpty) return 0.0;

      // 3. Primer pedido elegible → 30% de descuento sobre el subtotal.
      return double.parse((subtotal * 0.30).toStringAsFixed(2));
    } catch (_) {
      // En caso de error de red, no bloqueamos el pedido; sin descuento.
      return 0.0;
    }
  }
}
