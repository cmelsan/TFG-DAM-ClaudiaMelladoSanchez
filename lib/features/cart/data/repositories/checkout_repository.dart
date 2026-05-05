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
      final total = subtotal + deliveryFee;

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
}
