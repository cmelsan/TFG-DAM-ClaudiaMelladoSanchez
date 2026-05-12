import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/admin/presentation/providers/admin_provider.dart';
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

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<Map<String, dynamic>?> orderRating(OrderRatingRef ref, String orderId) {
  return ref.watch(ordersRepositoryProvider).getOrderRating(orderId);
}

/// Devuelve true si el usuario es elegible para el descuento de primer pedido:
/// el descuento está activado en el admin Y el usuario no tiene pedidos
/// anteriores no cancelados.
@riverpod
Future<bool> isEligibleForFirstOrderDiscount(
  IsEligibleForFirstOrderDiscountRef ref, // ignore: deprecated_member_use_from_same_package
) async {
  final discountEnabled =
      await ref.watch(firstOrderDiscountEnabledProvider.future);
  if (!discountEnabled) return false;

  final myOrders = await ref.watch(ordersProvider.future);
  final nonCancelled = myOrders.where((o) => o.status != 'cancelled').toList();
  return nonCancelled.isEmpty;
}
