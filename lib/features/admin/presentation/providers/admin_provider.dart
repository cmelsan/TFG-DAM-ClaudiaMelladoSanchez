import 'dart:async';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/features/admin/data/repositories/admin_repository.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_event_request.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_user.dart';
import 'package:sabor_de_casa/features/admin/domain/models/business_config_item.dart';
import 'package:sabor_de_casa/features/admin/domain/models/schedule_entry.dart';
import 'package:sabor_de_casa/features/catering/domain/models/event_menu.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/menu/presentation/providers/menu_provider.dart';
import 'package:sabor_de_casa/features/orders/data/repositories/orders_repository.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order_item.dart';

part 'admin_provider.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<Map<String, dynamic>> adminDashboardStats(AdminDashboardStatsRef ref) {
  return ref.watch(adminRepositoryProvider).getDashboardStats();
}

/// Serie de ingresos por día (últimos 7) para gráficos.
@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Map<String, dynamic>>> adminRevenueLast7Days(
  AdminRevenueLast7DaysRef ref, // ignore: deprecated_member_use_from_same_package
) {
  return ref.watch(adminRepositoryProvider).getRevenueLastDays(7);
}

/// Serie de ingresos por día (últimos 30) para estadísticas.
@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Map<String, dynamic>>> adminRevenueLast30Days(
  AdminRevenueLast30DaysRef ref, // ignore: deprecated_member_use_from_same_package
) {
  return ref.watch(adminRepositoryProvider).getRevenueLastDays(30);
}

/// Top platos por unidades vendidas (últimos 30 días).
@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Map<String, dynamic>>> adminTopDishes(AdminTopDishesRef ref) {
  return ref.watch(adminRepositoryProvider).getTopDishes();
}

/// Estadísticas agregadas por usuario (orders_count, total_spent, last_order_at).
@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<Map<String, Map<String, dynamic>>> adminUsersStats(
  AdminUsersStatsRef ref, // ignore: deprecated_member_use_from_same_package
) {
  return ref.watch(adminRepositoryProvider).getUsersStats();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> adminOrders(AdminOrdersRef ref) {
  return ref.watch(adminRepositoryProvider).getAllOrders();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> adminOrdersToday(AdminOrdersTodayRef ref) {
  return ref.watch(adminRepositoryProvider).getOrdersToday();
}

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<List<Order>> adminOrdersWeek(AdminOrdersWeekRef ref) {
  return ref.watch(adminRepositoryProvider).getOrdersWeek();
}

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<List<OrderItem>> adminOrderItems(
  AdminOrderItemsRef ref, // ignore: deprecated_member_use_from_same_package
  String orderId,
) {
  return ref.watch(ordersRepositoryProvider).getOrderItems(orderId);
}

@riverpod
// ignore: deprecated_member_use_from_same_package
Future<AdminUser?> adminUserProfile(AdminUserProfileRef ref, String userId) {
  if (userId.isEmpty) return Future.value();
  return ref.watch(adminRepositoryProvider).getUserProfile(userId);
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
Future<List<EventMenu>> adminEventMenus(AdminEventMenusRef ref) {
  return ref.watch(adminRepositoryProvider).getEventMenus();
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

/// Controla si el descuento del 30% al primer pedido está activo.
/// El admin puede activarlo/desactivarlo desde el panel de configuración.
@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<bool> firstOrderDiscountEnabled(FirstOrderDiscountEnabledRef ref) async {
  final value = await ref
      .watch(adminRepositoryProvider)
      .getConfigValue('first_order_discount_enabled');
  return value != 'false';
}

/// Controla si el negocio está aceptando nuevos pedidos.
/// Cuando es false, el checkout bloquea los pedidos de domicilio y recogida.
@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
Future<bool> acceptingOrders(AcceptingOrdersRef ref) async {
  final value = await ref
      .watch(adminRepositoryProvider)
      .getConfigValue('accepting_orders');
  return value != 'false'; // por defecto true si la clave no existe
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
      () => ref
          .read(adminRepositoryProvider)
          .updateDishOffer(
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

  /// Activa o desactiva la aceptación de nuevos pedidos.
  Future<void> toggleAcceptingOrders({required bool accepting}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateBusinessConfigByKey(
            key: 'accepting_orders',
            value: accepting ? 'true' : 'false',
          ),
    );
    ref.invalidate(acceptingOrdersProvider);
  }

  /// Restaura todos los platos a disponible. Útil al inicio del servicio.
  Future<void> resetAllDishAvailability() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).resetAllDishAvailability(),
    );
    ref
      ..invalidate(adminDishesProvider)
      ..invalidate(offerDishesProvider);
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
  // ──────────────── EVENT MENU CRUD ──────────────────────────

  Future<void> createEventMenu({
    required String name,
    required double pricePerPerson,
    required int minGuests,
    required int maxGuests,
    String? description,
    String? imageUrl,
    String eventKind = 'small',
    int leadTimeMonths = 1,
    bool tastingAvailable = false,
    String? highlightLabel,
    bool isActive = true,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .createEventMenu(
            name: name,
            pricePerPerson: pricePerPerson,
            minGuests: minGuests,
            maxGuests: maxGuests,
            description: description,
            imageUrl: imageUrl,
            eventKind: eventKind,
            leadTimeMonths: leadTimeMonths,
            tastingAvailable: tastingAvailable,
            highlightLabel: highlightLabel,
            isActive: isActive,
          ),
    );
    ref.invalidate(adminEventMenusProvider);
  }

  Future<void> updateEventMenu({
    required String id,
    required String name,
    required double pricePerPerson,
    required int minGuests,
    required int maxGuests,
    required bool isActive,
    String? description,
    String? imageUrl,
    String eventKind = 'small',
    int leadTimeMonths = 1,
    bool tastingAvailable = false,
    String? highlightLabel,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateEventMenu(
            id: id,
            name: name,
            pricePerPerson: pricePerPerson,
            minGuests: minGuests,
            maxGuests: maxGuests,
            description: description,
            imageUrl: imageUrl,
            eventKind: eventKind,
            leadTimeMonths: leadTimeMonths,
            tastingAvailable: tastingAvailable,
            highlightLabel: highlightLabel,
            isActive: isActive,
          ),
    );
    ref.invalidate(adminEventMenusProvider);
  }

  Future<void> deleteEventMenu(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminRepositoryProvider).deleteEventMenu(id),
    );
    ref.invalidate(adminEventMenusProvider);
  }

  Future<void> updateEventRequestQuote({
    required String requestId,
    required String status,
    double? quotedTotal,
    String? adminNotes,
    DateTime? appointmentAt,
    String? appointmentNotes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(adminRepositoryProvider)
          .updateEventRequestQuote(
            requestId: requestId,
            status: status,
            quotedTotal: quotedTotal,
            adminNotes: adminNotes,
            appointmentAt: appointmentAt,
            appointmentNotes: appointmentNotes,
          ),
    );
    ref
      ..invalidate(adminEventRequestsProvider)
      ..invalidate(adminDashboardStatsProvider);
  }
}
