import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/admin/data/repositories/admin_repository.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_event_request.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_user.dart';
import 'package:sabor_de_casa/features/admin/domain/models/business_config_item.dart';
import 'package:sabor_de_casa/features/admin/domain/models/schedule_entry.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';
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

// Provider categorías admin
@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Category>> adminCategories(AdminCategoriesRef ref) {
  return ref.watch(adminRepositoryProvider).getAllCategories();
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
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> adminEncargos(AdminEncargosRef ref) {
  return ref.watch(adminRepositoryProvider).getPendingEncargos();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<int> encargoMinDays(EncargoMinDaysRef ref) async {
  final value = await ref
      .watch(adminRepositoryProvider)
      .getConfigValue('encargo_min_days_advance');
  return int.tryParse(value ?? '2') ?? 2;
}

/// Controla si la sección "En oferta" debe mostrarse en la home web.
/// Editable desde el panel de configuración del admin.
@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<bool> showOffersSection(ShowOffersSectionRef ref) async {
  final value = await ref
      .watch(adminRepositoryProvider)
      .getConfigValue('show_offers_section');
  return value != 'false';
}

/// Controla si la sección "Platos de temporada" debe mostrarse en la home web.
/// Editable desde el panel de configuración del admin.
@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<bool> showSeasonalSection(ShowSeasonalSectionRef ref) async {
  final value = await ref
      .watch(adminRepositoryProvider)
      .getConfigValue('show_seasonal_section');
  return value != 'false';
}

@riverpod
class AdminAction extends _$AdminAction {
  @override
  FutureOr<void> build() {
    // Prevent auto-dispose while async operations are in-flight.
    // Without this, Riverpod disposes the provider (no watchers) during
    // network calls and the internal Completer throws "Future already completed".
    ref.keepAlive();
  }

  Future<void> updateDishAvailability({
    required String dishId,
    required bool isAvailable,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateDishAvailability(dishId: dishId, isAvailable: isAvailable),
    );
    ref.invalidate(adminDishesProvider);
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateOrderStatus(orderId: orderId, status: status),
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
      () => ref
          .read(adminRepositoryProvider)
          .updateEventRequestStatus(requestId: requestId, status: status),
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
      () => ref
          .read(adminRepositoryProvider)
          .updateUserActive(userId: userId, isActive: isActive),
    );
    ref.invalidate(adminUsersProvider);
  }

  Future<void> updateConfig({required String id, required String value}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateBusinessConfig(id: id, value: value),
    );
    ref.invalidate(adminConfigProvider);
  }

  Future<void> updateSchedule({
    required String id,
    required bool isOpen,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateSchedule(id: id, isOpen: isOpen),
    );
    ref.invalidate(adminScheduleProvider);
  }

  Future<void> acceptEncargo(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateOrderStatus(orderId: orderId, status: 'confirmed'),
    );
    ref
      ..invalidate(adminEncargosProvider)
      ..invalidate(adminOrdersProvider)
      ..invalidate(adminDashboardStatsProvider);
  }

  Future<void> rejectEncargo(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateOrderStatus(orderId: orderId, status: 'cancelled'),
    );
    ref
      ..invalidate(adminEncargosProvider)
      ..invalidate(adminOrdersProvider)
      ..invalidate(adminDashboardStatsProvider);
  }

  /// El dependiente marca el pago como cobrado (efectivo o TPV en tienda).
  Future<void> markPaymentPaid(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).markOrderPaymentPaid(orderId),
    );
    ref
      ..invalidate(adminOrdersProvider)
      ..invalidate(adminEncargosProvider)
      ..invalidate(adminDashboardStatsProvider);
  }

  /// Para encargos/recogida: el dependiente entrega en mano y marca cobrado.
  Future<void> markDeliveredAndPaid(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () =>
          ref.read(adminRepositoryProvider).markOrderDeliveredAndPaid(orderId),
    );
    ref
      ..invalidate(adminOrdersProvider)
      ..invalidate(adminEncargosProvider)
      ..invalidate(adminDashboardStatsProvider);
  }

  /// Comprime (en móvil), sube la imagen al bucket y actualiza image_url en BD.
  Future<void> uploadDishImage({
    required String dishId,
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final url = await ref
          .read(adminRepositoryProvider)
          .uploadDishImage(dishId: dishId, bytes: bytes, mimeType: mimeType);
      await ref
          .read(adminRepositoryProvider)
          .updateDishImageUrl(dishId: dishId, imageUrl: url);
    });
    ref.invalidate(adminDishesProvider);
  }

  // ──────────────────── DISH CRUD ────────────────────────────────────────────

  Future<Dish?> createDish(Dish dish) async {
    state = const AsyncLoading();
    Dish? created;
    state = await AsyncValue.guard(() async {
      created = await ref.read(adminRepositoryProvider).createDish(dish);
    });
    ref.invalidate(adminDishesProvider);
    return created;
  }

  Future<void> updateDish(Dish dish) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).updateDish(dish),
    );
    ref.invalidate(adminDishesProvider);
  }

  /// Activa/desactiva la oferta de un plato sin abrir el formulario completo.
  Future<void> toggleDishOffer({
    required String dishId,
    required bool isOffer,
    double? offerPrice,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).updateDishOffer(
            dishId: dishId,
            isOffer: isOffer,
            offerPrice: offerPrice,
          ),
    );
    ref
      ..invalidate(adminDishesProvider)
      ..invalidate(offerDishesProvider);
  }

  Future<void> deleteDish(String dishId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).deleteDish(dishId),
    );
    ref.invalidate(adminDishesProvider);
  }

  // ──────────────────── CATEGORY CRUD ───────────────────────────────────────

  Future<void> createCategory(Category category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).createCategory(category),
    );
    ref.invalidate(adminCategoriesProvider);
  }

  Future<void> updateCategory(Category category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).updateCategory(category),
    );
    ref.invalidate(adminCategoriesProvider);
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).deleteCategory(id),
    );
    ref.invalidate(adminCategoriesProvider);
  }

  // ──────────────────── USER ROLE ───────────────────────────────────────────

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateUserRole(userId: userId, role: role),
    );
    ref.invalidate(adminUsersProvider);
  }

  // ──────────────────── SCHEDULE HOURS ──────────────────────────────────────

  Future<void> updateScheduleHours({
    required String id,
    required String openTime,
    required String closeTime,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateScheduleHours(
            id: id,
            openTime: openTime,
            closeTime: closeTime,
          ),
    );
    ref.invalidate(adminScheduleProvider);
  }

  // ──────────────────── ORDER CANCEL ────────────────────────────────────────

  Future<void> cancelOrderWithReason({
    required String orderId,
    required String reason,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .cancelOrderWithReason(orderId: orderId, reason: reason),
    );
    ref
      ..invalidate(adminOrdersProvider)
      ..invalidate(adminDashboardStatsProvider);
  }
}
