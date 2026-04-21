import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_item.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'orders_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
OrdersRepository ordersRepository(OrdersRepositoryRef ref) {
  return OrdersRepository(ref.watch(supabaseClientProvider));
}

class OrdersRepository {
  OrdersRepository(this._client);

  final SupabaseClient _client;

  Future<List<Order>> getMyOrders() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(
          message: 'Debes iniciar sesión para ver pedidos',
        );
      }

      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return data.map(Order.fromJson).toList();
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<Order> getOrderById(String orderId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(
          message: 'Debes iniciar sesión para ver pedidos',
        );
      }

      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('id', orderId)
          .eq('user_id', userId)
          .single();

      return Order.fromJson(data);
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.orderItems)
          .select(
            'id, order_id, dish_id, quantity, unit_price, subtotal, notes, '
            'dishes(name, image_url)',
          )
          .eq('order_id', orderId)
          .order('id');

      return data.map((json) {
        final dish = json['dishes'] as Map<String, dynamic>?;
        final enriched = <String, dynamic>{
          ...json,
          'dish_name': dish?['name'],
          'dish_image_url': dish?['image_url'],
        };
        return OrderItem.fromJson(enriched);
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
