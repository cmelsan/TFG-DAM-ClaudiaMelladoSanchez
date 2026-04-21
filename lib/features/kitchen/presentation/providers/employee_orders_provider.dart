import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/kitchen/data/repositories/employee_orders_repository.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

part 'employee_orders_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> kitchenOrders(KitchenOrdersRef ref) {
  return ref.watch(employeeOrdersRepositoryProvider).getKitchenOrders();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> deliveryOrders(DeliveryOrdersRef ref) {
  return ref.watch(employeeOrdersRepositoryProvider).getDeliveryOrders();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> posOrders(PosOrdersRef ref) {
  return ref.watch(employeeOrdersRepositoryProvider).getPosOrders();
}

@riverpod
class EmployeeOrderAction extends _$EmployeeOrderAction {
  @override
  FutureOr<void> build() {}

  Future<void> updateStatus({
    required String orderId,
    required String newStatus,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(employeeOrdersRepositoryProvider).updateOrderStatus(
            orderId: orderId,
            newStatus: newStatus,
          ),
    );
    _refreshLists();
  }

  Future<void> assignToMe(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(employeeOrdersRepositoryProvider)
          .assignOrderToCurrentDriver(orderId),
    );
    _refreshLists();
  }

  void _refreshLists() {
    ref
      ..invalidate(kitchenOrdersProvider)
      ..invalidate(deliveryOrdersProvider)
      ..invalidate(posOrdersProvider);
  }
}
