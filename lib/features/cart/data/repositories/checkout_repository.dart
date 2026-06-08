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

      // — Bloquear pedidos inmediatos si el negocio está pausado —
      if (orderType != 'encargo') {
        final configRow = await _client
            .from(SupabaseConstants.businessConfig)
            .select('value')
            .eq('key', 'accepting_orders')
            .maybeSingle();
        final accepting = (configRow?['value'] as String?) != 'false';
        if (!accepting) throw const OrdersPausedFailure();
      }

      // Compatibilidad: algunos carritos antiguos guardaron el id de
      // daily_special en lugar de dishes.id para "Menú del día".
      final resolvedDishIds = <String>[];
      for (final item in items) {
        final dishId = await _resolveDishId(item.dishId);
        resolvedDishIds.add(dishId);
      }

      final subtotal = items.fold<double>(
        0,
        (sum, item) => sum + (item.unitPrice * item.quantity),
      );
      final deliveryFee = orderType == 'domicilio' ? 2.5 : 0.0;

      // — Descuento primer pedido (solo domicilio / recogida) —
      final discountAmount = await _computeFirstOrderDiscount(
        userId: userId,
        subtotal: subtotal,
        orderType: orderType,
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
      final orderItems = List.generate(
        items.length,
        (i) {
          final item = items[i];
          return {
              'order_id': orderId,
              'dish_id': resolvedDishIds[i],
              'quantity': item.quantity,
              'unit_price': item.unitPrice,
              'subtotal': item.unitPrice * item.quantity,
            };
        },
      );

      await _client.from(SupabaseConstants.orderItems).insert(orderItems);

      // Email de confirmación: se llama DESPUÉS de insertar los items para
      // evitar la race condition del webhook (items ya existen en BD).
      _sendOrderConfirmationEmail(
        orderId: orderId,
        userId: userId,
        orderType: orderType,
      );

      return orderId;
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<String> _resolveDishId(String rawDishId) async {
    final dish = await _client
        .from(SupabaseConstants.dishes)
        .select('id')
        .eq('id', rawDishId)
        .maybeSingle();

    if (dish != null) return rawDishId;

    final special = await _client
        .from(SupabaseConstants.dailySpecial)
        .select('dish_id')
        .eq('id', rawDishId)
        .maybeSingle();

    final specialDishId = special?['dish_id'] as String?;
    if (specialDishId != null && specialDishId.isNotEmpty) {
      return specialDishId;
    }

    throw const DatabaseFailure(
      message:
          'Uno de los productos del carrito ya no existe. Actualiza el carrito y vuelve a intentarlo.',
    );
  }

  /// Devuelve el importe del descuento de primer pedido (30% del subtotal)
  /// si el descuento está activo en la configuración y el usuario no tiene
  /// pedidos anteriores. En cualquier otro caso devuelve 0.
  Future<double> _computeFirstOrderDiscount({
    required String userId,
    required double subtotal,
    required String orderType,
  }) async {
    // El descuento de primer pedido solo aplica a domicilio y recogida.
    if (orderType != 'domicilio' && orderType != 'recogida') return 0.0;

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
  }

  /// Invoca el Edge Function de notificación DESPUÉS de insertar los items,
  /// evitando la race condition del webhook de base de datos.
  /// Fire-and-forget: los errores no bloquean la confirmación del pedido.
  void _sendOrderConfirmationEmail({
    required String orderId,
    required String userId,
    required String orderType,
  }) {
    _client.functions
        .invoke(
          'send-order-notification',
          body: {
            'type': 'INSERT',
            'record': {
              'id': orderId,
              'user_id': userId,
              'order_type': orderType,
              'status': 'pending',
            },
          },
        )
        .then((_) {}, onError: (_) {}); // Ignorar errores: el pedido ya está confirmado
  }
}
