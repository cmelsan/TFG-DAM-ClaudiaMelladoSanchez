import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/admin/data/repositories/admin_repository.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_event_request.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_user.dart';
import 'package:sabor_de_casa/features/admin/domain/models/business_config_item.dart';
import 'package:sabor_de_casa/features/admin/domain/models/schedule_entry.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';

part 'admin_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<Map<String, double>> adminDashboardStats(AdminDashboardStatsRef ref) {
  return ref.watch(adminRepositoryProvider).getDashboardStats();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> adminOrders(AdminOrdersRef ref) {
  return ref.watch(adminRepositoryProvider).getAllOrders();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Dish>> adminDishes(AdminDishesRef ref) {
  return ref.watch(adminRepositoryProvider).getAllDishes();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<AdminEventRequest>> adminEventRequests(AdminEventRequestsRef ref) {
  return ref.watch(adminRepositoryProvider).getEventRequests();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<AdminUser>> adminUsers(AdminUsersRef ref) {
  return ref.watch(adminRepositoryProvider).getUsers();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<BusinessConfigItem>> adminConfig(AdminConfigRef ref) {
  return ref.watch(adminRepositoryProvider).getBusinessConfig();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<ScheduleEntry>> adminSchedule(AdminScheduleRef ref) {
  return ref.watch(adminRepositoryProvider).getSchedule();
}

@riverpod
class AdminAction extends _$AdminAction {
  @override
  FutureOr<void> build() {}

  Future<void> updateDishAvailability({
    required String dishId,
    required bool isAvailable,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).updateDishAvailability(
            dishId: dishId,
            isAvailable: isAvailable,
          ),
    );
    ref.invalidate(adminDishesProvider);
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).updateOrderStatus(
            orderId: orderId,
            status: status,
          ),
    );
    ref
      ..invalidate(adminOrdersProvider)
      ..invalidate(adminDashboardStatsProvider);
  }

  Future<void> updateEventRequestStatus({
    required String requestId,
    required String status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).updateEventRequestStatus(
            requestId: requestId,
            status: status,
          ),
    );
    ref
      ..invalidate(adminEventRequestsProvider)
      ..invalidate(adminDashboardStatsProvider);
  }

  Future<void> updateUserActive({
    required String userId,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).updateUserActive(
            userId: userId,
            isActive: isActive,
          ),
    );
    ref.invalidate(adminUsersProvider);
  }

  Future<void> updateConfig({
    required String id,
    required String value,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).updateBusinessConfig(
            id: id,
            value: value,
          ),
    );
    ref.invalidate(adminConfigProvider);
  }

  Future<void> updateSchedule({
    required String id,
    required bool isOpen,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).updateSchedule(
            id: id,
            isOpen: isOpen,
          ),
    );
    ref.invalidate(adminScheduleProvider);
  }
}
