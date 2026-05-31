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

  /// Igual que [getDeliveryOrders] pero trae la dirección y el perfil del
  /// cliente mediante join de Supabase PostgREST.
  Future<List<Map<String, dynamic>>> getDeliveryOrdersWithDetails() async {
    try {
      final data = await _client
          .from(SupabaseConstants.orders)
          .select(
            '*, '
            '${SupabaseConstants.addresses}(label, street, city, postal_code), '
            '${SupabaseConstants.profiles}!user_id(full_name, phone)',
          )
          .inFilter('status', ['ready', 'delivering'])
          .eq('order_type', 'domicilio')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getDeliveredOrdersWithDetailsToday()
      async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final data = await _client
          .from(SupabaseConstants.orders)
          .select(
            '*, '
            '${SupabaseConstants.addresses}(label, street, city, postal_code), '
            '${SupabaseConstants.profiles}!user_id(full_name, phone)',
          )
          .eq('status', 'delivered')
          .eq('order_type', 'domicilio')
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String())
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getDeliveredOrdersWithDetailsWeek()
      async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );

      final data = await _client
          .from(SupabaseConstants.orders)
          .select(
            '*, '
            '${SupabaseConstants.addresses}(label, street, city, postal_code), '
            '${SupabaseConstants.profiles}!user_id(full_name, phone)',
          )
          .eq('status', 'delivered')
          .eq('order_type', 'domicilio')
          .gte('created_at', start.toIso8601String())
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List);
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

  /// Pedidos de recogida que están listos para ser entregados al cliente.
  Future<List<Order>> getPickupReadyOrders() async {
    try {
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('order_type', 'recogida')
          .eq('status', 'ready')
          .order('created_at', ascending: false);
      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Busca un pedido por ID sin filtro de usuario (para el escáner QR del empleado).
  Future<Order?> getOrderForPickup(String orderId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('id', orderId)
          .maybeSingle();
      if (data == null) return null;
      return Order.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ── Mostrador: Encargos del día ──────────────────────────────────────────

  /// Encargos programados para hoy (todos los estados excepto cancelado).
  Future<List<Order>> getEncargosToday() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('order_type', 'encargo')
          .neq('status', 'cancelled')
          .gte('scheduled_at', start.toIso8601String())
          .lt('scheduled_at', end.toIso8601String())
          .order('scheduled_at', ascending: true);
      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Encargos programados para esta semana (lunes a domingo).
  Future<List<Order>> getEncargosWeek() async {
    try {
      final now = DateTime.now();
      // Lunes de esta semana
      final monday =
          DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final sunday = monday.add(const Duration(days: 7));
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('order_type', 'encargo')
          .neq('status', 'cancelled')
          .gte('scheduled_at', monday.toIso8601String())
          .lt('scheduled_at', sunday.toIso8601String())
          .order('scheduled_at', ascending: true);
      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Todos los pedidos de hoy para historial de cocina (cualquier estado, excluye encargos).
  Future<List<Order>> getAllKitchenOrdersToday() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .neq('order_type', 'encargo')
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

  /// Pedidos de mostrador y recogida de hoy (para la vista general del mostrador).
  Future<List<Order>> getCounterOrdersToday() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .inFilter('order_type', ['mostrador', 'recogida'])
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

  /// Crea un pedido de mostrador (sin cuenta de cliente, ya cobrado).
  Future<(String id, String? displayId)> createMostradorOrder({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String? notes,
  }) async {
    try {
      final subtotal = items.fold<double>(
        0,
        (sum, i) =>
            sum + ((i['unitPrice'] as double) * (i['quantity'] as int)),
      );

      final order = await _client
          .from(SupabaseConstants.orders)
          .insert({
            'user_id': null,
            'order_type': 'mostrador',
            'status': 'confirmed',      // Va directamente a cocina
            'payment_status': 'paid',   // Ya cobrado en el mostrador
            'payment_method': paymentMethod,
            'subtotal': subtotal,
            'delivery_fee': 0.0,
            'discount_amount': 0.0,
            'total': subtotal,
            if (notes != null && notes.trim().isNotEmpty)
              'notes': notes.trim(),
          })
          .select('id, display_id')
          .single();

      final orderId = order['id'] as String;
      final displayId = order['display_id'] as String?;
      final orderItems = items
          .map(
            (i) => {
              'order_id': orderId,
              'dish_id': i['dishId'],
              'quantity': i['quantity'],
              'unit_price': i['unitPrice'],
              'subtotal':
                  (i['unitPrice'] as double) * (i['quantity'] as int),
            },
          )
          .toList();

      await _client
          .from(SupabaseConstants.orderItems)
          .insert(orderItems);

      return (orderId, displayId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Marca solo el estado como entregado (para encargos ya pagados online).
  Future<void> markDelivered(String orderId) async {
    try {
      await _client
          .from(SupabaseConstants.orders)
          .update({'status': 'delivered'})
          .eq('id', orderId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
