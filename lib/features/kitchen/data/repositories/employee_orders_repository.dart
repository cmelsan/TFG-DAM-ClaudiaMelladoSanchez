import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'employee_orders_repository.g.dart';

@Riverpod(keepAlive: true)
EmployeeOrdersRepository employeeOrdersRepository(
  // ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
  EmployeeOrdersRepositoryRef ref,
) {
  return EmployeeOrdersRepository(ref.watch(supabaseClientProvider));
}

class EmployeeOrdersRepository {
  EmployeeOrdersRepository(this._client);

  final SupabaseClient _client;

  Future<List<Order>> getKitchenOrders() async {
    try {
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .inFilter('status', ['pending', 'confirmed', 'preparing'])
          .neq('order_type', 'encargo')
          .order('created_at', ascending: false);
      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Order>> getEncargoKitchenOrders() async {
    try {
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('order_type', 'encargo')
          .inFilter('status', ['confirmed', 'preparing'])
          .order('scheduled_at', ascending: true);
      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Order>> getDeliveryOrders() async {
    try {
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .inFilter('status', ['ready', 'delivering'])
          .eq('order_type', 'domicilio')
          .order('created_at', ascending: false);
      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Order>> getPosOrders() async {
    try {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = start.add(const Duration(days: 1));

      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('order_type', 'mostrador')
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String())
          .order('created_at', ascending: false);

      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    try {
      // Obtener tipo de pedido antes de actualizar (para la notificación)
      final orderData = await _client
          .from(SupabaseConstants.orders)
          .select('user_id, order_type')
          .eq('id', orderId)
          .single();

      await _client
          .from(SupabaseConstants.orders)
          .update({'status': newStatus})
          .eq('id', orderId);

      // Fire-and-forget: notificar al cliente (no bloqueamos si falla)
      _sendStatusNotification(
        orderId: orderId,
        newStatus: newStatus,
        userId: orderData['user_id'] as String,
        orderType: orderData['order_type'] as String,
      );
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Llama a la edge function send-order-notification en background.
  /// Los errores se ignoran intencionadamente (notificación es best-effort).
  void _sendStatusNotification({
    required String orderId,
    required String newStatus,
    required String userId,
    required String orderType,
  }) {
    _client.functions
        .invoke(
          'send-order-notification',
          body: {
            'orderId': orderId,
            'newStatus': newStatus,
            'userId': userId,
            'orderType': orderType,
          },
        )
        .catchError(
          // ignore: avoid_redundant_argument_values
          (_) => FunctionResponse(data: null, status: 200),
        );
  }

  Future<void> assignOrderToCurrentDriver(String orderId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(message: 'No hay sesión activa');
      }

      await _client
          .from(SupabaseConstants.orders)
          .update({'assigned_driver_id': userId, 'status': 'delivering'})
          .eq('id', orderId);
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Marca el pago de un pedido como cobrado (payment_status = 'paid').
  /// Usar cuando el repartidor cobra en mano o el dependiente cobra en tienda.
  Future<void> markPaymentPaid(String orderId) async {
    try {
      await _client
          .from(SupabaseConstants.orders)
          .update({'payment_status': 'paid'})
          .eq('id', orderId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Marca el pedido como entregado Y el pago como cobrado en una sola transacción.
  /// Para domicilio con pago en efectivo: el repartidor cobra al entregar.
  Future<void> markDeliveredAndPaid(String orderId) async {
    try {
      await _client
          .from(SupabaseConstants.orders)
          .update({'status': 'delivered', 'payment_status': 'paid'})
          .eq('id', orderId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
