import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/orders/data/repositories/orders_repository.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_item.dart';

part 'orders_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> orders(OrdersRef ref) {
  return ref.watch(ordersRepositoryProvider).getMyOrders();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<Order> orderDetail(OrderDetailRef ref, String orderId) {
  return ref.watch(ordersRepositoryProvider).getOrderById(orderId);
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<OrderItem>> orderItems(OrderItemsRef ref, String orderId) {
  return ref.watch(ordersRepositoryProvider).getOrderItems(orderId);
}
