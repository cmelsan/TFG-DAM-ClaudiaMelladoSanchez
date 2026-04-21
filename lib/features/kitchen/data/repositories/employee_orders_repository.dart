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
    return _getOrdersByStatuses(['pending', 'confirmed', 'preparing']);
  }

  Future<List<Order>> getDeliveryOrders() async {
    return _getOrdersByStatuses(['ready', 'delivering']);
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
      await _client
          .from(SupabaseConstants.orders)
          .update({'status': newStatus})
          .eq('id', orderId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
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

  Future<List<Order>> _getOrdersByStatuses(List<String> statuses) async {
    try {
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .inFilter('status', statuses)
          .order('created_at', ascending: false);
      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
