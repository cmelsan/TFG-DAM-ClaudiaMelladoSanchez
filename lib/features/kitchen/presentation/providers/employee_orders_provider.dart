import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/delivery/presentation/providers/delivery_provider.dart';
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
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> encargoKitchenOrders(EncargoKitchenOrdersRef ref) {
  return ref.watch(employeeOrdersRepositoryProvider).getEncargoKitchenOrders();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> pickupReadyOrders(PickupReadyOrdersRef ref) {
  return ref.watch(employeeOrdersRepositoryProvider).getPickupReadyOrders();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<Order?> orderForPickup(OrderForPickupRef ref, String orderId) {
  return ref.watch(employeeOrdersRepositoryProvider).getOrderForPickup(orderId);
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> encargosHoy(EncargosHoyRef ref) {
  return ref.watch(employeeOrdersRepositoryProvider).getEncargosToday();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> encargosSemana(EncargosSemanaRef ref) {
  return ref.watch(employeeOrdersRepositoryProvider).getEncargosWeek();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> counterOrdersToday(CounterOrdersTodayRef ref) {
  return ref.watch(employeeOrdersRepositoryProvider).getCounterOrdersToday();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> allKitchenOrdersToday(AllKitchenOrdersTodayRef ref) {
  return ref
      .watch(employeeOrdersRepositoryProvider)
      .getAllKitchenOrdersToday();
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
      () => ref
          .read(employeeOrdersRepositoryProvider)
          .updateOrderStatus(orderId: orderId, newStatus: newStatus),
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

  Future<void> markPaymentPaid(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(employeeOrdersRepositoryProvider).markPaymentPaid(orderId),
    );
    _refreshLists();
  }

  /// Para domicilio + efectivo: entrega y cobra en un solo paso.
  Future<void> markDeliveredAndPaid(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(employeeOrdersRepositoryProvider)
          .markDeliveredAndPaid(orderId),
    );
    _refreshLists();
  }

  /// Para encargos ya pagados online: solo marca entregado.
  Future<void> markDelivered(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(employeeOrdersRepositoryProvider)
          .markDelivered(orderId),
    );
    _refreshLists();
  }

  /// Crea un pedido de mostrador (sin cuenta, ya cobrado) y refresca listas.
  Future<(String id, String? displayId)?> createMostradorOrder({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String? notes,
  }) async {
    state = const AsyncLoading();
    (String, String?)? result;
    state = await AsyncValue.guard(() async {
      result = await ref
          .read(employeeOrdersRepositoryProvider)
          .createMostradorOrder(
            items: items,
            paymentMethod: paymentMethod,
            notes: notes,
          );
    });
    _refreshLists();
    return result;
  }

  void _refreshLists() {
    ref
      ..invalidate(kitchenOrdersProvider)
      ..invalidate(deliveryOrdersProvider)
      ..invalidate(deliveryDetailProvider)
      ..invalidate(posOrdersProvider)
      ..invalidate(encargoKitchenOrdersProvider)
      ..invalidate(pickupReadyOrdersProvider)
      ..invalidate(encargosHoyProvider)
      ..invalidate(encargosSemanaProvider)
      ..invalidate(counterOrdersTodayProvider);
  }
}
