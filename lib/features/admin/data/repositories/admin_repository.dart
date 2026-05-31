import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_event_request.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_user.dart';
import 'package:sabor_de_casa/features/admin/domain/models/business_config_item.dart';
import 'package:sabor_de_casa/features/admin/domain/models/schedule_entry.dart';
import 'package:sabor_de_casa/features/catering/domain/models/event_menu.dart';
import 'package:sabor_de_casa/features/menu/domain/models/category.dart';
import 'package:sabor_de_casa/features/menu/domain/models/dish.dart';
import 'package:sabor_de_casa/features/orders/domain/models/order.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
AdminRepository adminRepository(AdminRepositoryRef ref) {
  return AdminRepository(ref.watch(supabaseClientProvider));
}

class AdminRepository {
  AdminRepository(this._client);

  final SupabaseClient _client;

  Future<Map<String, double>> getDashboardStats() async {
    try {
      final ordersData = await _client.from(SupabaseConstants.orders).select();
      final usersData = await _client
          .from(SupabaseConstants.profiles)
          .select('id, role, is_active');
      final eventData = await _client
          .from(SupabaseConstants.eventRequests)
          .select('id, status');
      final contactsData = await _client
          .from(SupabaseConstants.contactMessages)
          .select('id, is_read');

      final orders = ordersData.map(Order.fromJson).toList();
      final delivered = orders.where((o) => o.status == 'delivered');
      final pending = orders.where((o) => o.status == 'pending').length;
      final revenue = delivered.fold<double>(0, (sum, o) => sum + o.total);

      return {
        'orders_total': orders.length.toDouble(),
        'orders_pending': pending.toDouble(),
        'revenue_total': revenue,
        'users_total': usersData.length.toDouble(),
        'events_total': eventData.length.toDouble(),
        'contacts_unread': contactsData
            .where((c) => (c['is_read'] as bool?) == false)
            .length
            .toDouble(),
      };
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Order>> getAllOrders() async {
    try {
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .order('created_at', ascending: false);
      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Todos los pedidos del día actual.
  /// Pedidos regulares → filtro por created_at.
  /// Encargos → filtro por scheduled_at (fecha programada).
  Future<List<Order>> getOrdersToday() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final regularData = await _client
          .from(SupabaseConstants.orders)
          .select()
          .neq('order_type', 'encargo')
          .gte('created_at', start.toIso8601String())
          .lt('created_at', end.toIso8601String())
          .order('created_at', ascending: false);

      final encargoData = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('order_type', 'encargo')
          .gte('scheduled_at', start.toIso8601String())
          .lt('scheduled_at', end.toIso8601String())
          .order('scheduled_at', ascending: true);

      final regular = regularData.map(Order.fromJson).toList();
      final encargos = encargoData.map(Order.fromJson).toList();
      return [...regular, ...encargos]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Todos los pedidos de la semana actual (lunes–domingo).
  /// Pedidos regulares → created_at. Encargos → scheduled_at.
  Future<List<Order>> getOrdersWeek() async {
    try {
      final now = DateTime.now();
      final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
      final sunday = monday.add(const Duration(days: 7));

      final regularData = await _client
          .from(SupabaseConstants.orders)
          .select()
          .neq('order_type', 'encargo')
          .gte('created_at', monday.toIso8601String())
          .lt('created_at', sunday.toIso8601String())
          .order('created_at', ascending: false);

      final encargoData = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('order_type', 'encargo')
          .gte('scheduled_at', monday.toIso8601String())
          .lt('scheduled_at', sunday.toIso8601String())
          .order('scheduled_at', ascending: true);

      final regular = regularData.map(Order.fromJson).toList();
      final encargos = encargoData.map(Order.fromJson).toList();
      return [...regular, ...encargos]
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Obtiene el perfil de un usuario por su ID (para mostrar en pedidos).
  Future<AdminUser?> getUserProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.profiles)
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return AdminUser.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      return null;
    }
  }

  Future<List<Dish>> getAllDishes() async {
    try {
      final data = await _client
          .from(SupabaseConstants.dishes)
          .select()
          .order('name');
      return data.map(Dish.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> updateDishAvailability({
    required String dishId,
    required bool isAvailable,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.dishes)
          .update({'is_available': isAvailable})
          .eq('id', dishId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      // Fetch user_id and order_type before updating (needed for notification)
      final row = await _client
          .from(SupabaseConstants.orders)
          .select('user_id, order_type')
          .eq('id', orderId)
          .single();

      await _client
          .from(SupabaseConstants.orders)
          .update({'status': status})
          .eq('id', orderId);

      final orderType = row['order_type'] as String? ?? '';

      _sendStatusNotification(
        orderId: orderId,
        newStatus: status,
        userId: row['user_id'] as String? ?? '',
        orderType: orderType,
      );

      // Email con QR al confirmar un encargo
      if (status == 'confirmed' && orderType == 'encargo') {
        _sendEncargoConfirmation(orderId);
      }
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Marca el pago de un pedido como cobrado (payment_status = 'paid').
  /// Usado por el admin/dependiente cuando el cliente paga en local (efectivo o TPV).
  Future<void> markOrderPaymentPaid(String orderId) async {
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

  /// Para encargos/recogida que se entregan en tienda: marca entregado + cobrado.
  Future<void> markOrderDeliveredAndPaid(String orderId) async {
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

  Future<List<AdminEventRequest>> getEventRequests() async {
    try {
      final data = await _client
          .from(SupabaseConstants.eventRequests)
          .select(
            '*, ${SupabaseConstants.eventMenus}(name, price_per_person, event_kind, lead_time_months, tasting_available)',
          )
          .order('created_at', ascending: false);
      return data.map((row) {
        final json = Map<String, dynamic>.from(row);
        final menu = json[SupabaseConstants.eventMenus];
        if (menu is Map<String, dynamic>) {
          json
            ..['event_menu_name'] = menu['name']
            ..['event_menu_price_per_person'] = menu['price_per_person']
            ..['event_menu_event_kind'] = menu['event_kind']
            ..['event_menu_lead_time_months'] = menu['lead_time_months']
            ..['event_menu_tasting_available'] = menu['tasting_available'];
        }
        return AdminEventRequest.fromJson(json);
      }).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> updateEventRequestStatus({
    required String requestId,
    required String status,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.eventRequests)
          .update({'status': status})
          .eq('id', requestId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<AdminUser>> getUsers() async {
    try {
      final data = await _client
          .from(SupabaseConstants.profiles)
          .select()
          .order('created_at', ascending: false);
      return data.map(AdminUser.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> updateUserActive({
    required String userId,
    required bool isActive,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.profiles)
          .update({'is_active': isActive})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<BusinessConfigItem>> getBusinessConfig() async {
    try {
      final data = await _client
          .from(SupabaseConstants.businessConfig)
          .select()
          .order('key');
      return data.map(BusinessConfigItem.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<String?> getConfigValue(String key) async {
    try {
      final data = await _client
          .from(SupabaseConstants.businessConfig)
          .select('value')
          .eq('key', key)
          .maybeSingle();
      return data?['value'] as String?;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Order>> getPendingEncargos() async {
    try {
      final data = await _client
          .from(SupabaseConstants.orders)
          .select()
          .eq('order_type', 'encargo')
          .inFilter('status', ['pending', 'confirmed', 'preparing', 'ready'])
          .order('scheduled_at', ascending: true);
      return data.map(Order.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> updateBusinessConfig({
    required String id,
    required String value,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.businessConfig)
          .update({'value': value})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Actualiza un valor en business_config buscando por clave (no por id).
  Future<void> updateBusinessConfigByKey({
    required String key,
    required String value,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.businessConfig)
          .update({'value': value})
          .eq('key', key);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Restaura todos los platos a disponible (is_available = true).
  Future<void> resetAllDishAvailability() async {
    try {
      await _client
          .from(SupabaseConstants.dishes)
          .update({'is_available': true})
          .eq('is_available', false);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<ScheduleEntry>> getSchedule() async {
    try {
      final data = await _client
          .from(SupabaseConstants.schedule)
          .select()
          .order('day_of_week');
      return data.map(ScheduleEntry.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> updateSchedule({
    required String id,
    required bool isOpen,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.schedule)
          .update({'is_open': isOpen})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Sube una imagen al bucket `dish-images` y devuelve la URL pública.
  /// En Android/iOS: comprime a WebP (≤500 KB). En web: sube sin comprimir.
  Future<String> uploadDishImage({
    required String dishId,
    required Uint8List bytes,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      Uint8List toUpload;
      String contentType;
      String ext;

      if (!kIsWeb) {
        final compressed = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 800,
          minHeight: 600,
          quality: 85,
          format: CompressFormat.webp,
        );
        toUpload = compressed;
        contentType = 'image/webp';
        ext = 'webp';
      } else {
        toUpload = bytes;
        contentType = mimeType;
        ext = mimeType.contains('png') ? 'png' : 'jpg';
      }

      final path = 'dishes/$dishId.$ext';
      await _client.storage
          .from(SupabaseConstants.dishImagesBucket)
          .uploadBinary(
            path,
            toUpload,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );
      return _client.storage
          .from(SupabaseConstants.dishImagesBucket)
          .getPublicUrl(path);
    } on StorageException catch (e) {
      throw UnexpectedFailure(message: 'Storage error: ${e.message}');
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Actualiza el campo `image_url` de un plato en la base de datos.
  Future<void> updateDishImageUrl({
    required String dishId,
    required String imageUrl,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.dishes)
          .update({'image_url': imageUrl})
          .eq('id', dishId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ────────────────────────────────── DISH CRUD ──────────────────────────────

  Future<Dish> createDish(Dish dish) async {
    try {
      final payload = dish.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('updated_at');
      final data = await _client
          .from(SupabaseConstants.dishes)
          .insert(payload)
          .select()
          .single();
      return Dish.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<Dish> updateDish(Dish dish) async {
    try {
      final payload = dish.toJson()
        ..remove('created_at')
        ..remove('updated_at');
      final data = await _client
          .from(SupabaseConstants.dishes)
          .update(payload)
          .eq('id', dish.id)
          .select()
          .single();
      return Dish.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Actualiza solo los campos de oferta (más eficiente que updateDish completo).
  Future<void> updateDishOffer({
    required String dishId,
    required bool isOffer,
    double? offerPrice,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.dishes)
          .update({
            'is_offer': isOffer,
            'offer_price': isOffer ? offerPrice : null,
          })
          .eq('id', dishId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> deleteDish(String dishId) async {
    try {
      await _client.from(SupabaseConstants.dishes).delete().eq('id', dishId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ───────────────────────────────── CATEGORY CRUD ──────────────────────────

  Future<List<Category>> getAllCategories() async {
    try {
      final data = await _client
          .from(SupabaseConstants.categories)
          .select()
          .order('sort_order');
      return data.map(Category.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<Category> createCategory(Category category) async {
    try {
      final payload = category.toJson()
        ..remove('id')
        ..remove('created_at');
      final data = await _client
          .from(SupabaseConstants.categories)
          .insert(payload)
          .select()
          .single();
      return Category.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<Category> updateCategory(Category category) async {
    try {
      final payload = category.toJson()..remove('created_at');
      final data = await _client
          .from(SupabaseConstants.categories)
          .update(payload)
          .eq('id', category.id)
          .select()
          .single();
      return Category.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _client
          .from(SupabaseConstants.categories)
          .update({'is_active': false})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ────────────────────────────────── USER CRUD ─────────────────────────────

  Future<void> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.profiles)
          .update({'role': role})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ──────────────────────────────── SCHEDULE CRUD ───────────────────────────

  Future<void> updateScheduleHours({
    required String id,
    required String openTime,
    required String closeTime,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.schedule)
          .update({'open_time': openTime, 'close_time': closeTime})
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ──────────────────────────── EVENT MENU CRUD ──────────────────────────────

  Future<List<EventMenu>> getEventMenus() async {
    try {
      final data = await _client
          .from(SupabaseConstants.eventMenus)
          .select()
          .order('created_at', ascending: false);
      return data.map(EventMenu.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<EventMenu> createEventMenu({
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
    try {
      final payload = {
        'name': name,
        'price_per_person': pricePerPerson,
        'min_guests': minGuests,
        'max_guests': maxGuests,
        'description': description,
        'image_url': imageUrl,
        'event_kind': eventKind,
        'lead_time_months': leadTimeMonths,
        'tasting_available': tastingAvailable,
        'highlight_label': highlightLabel,
        'is_active': isActive,
      };
      final data = await _client
          .from(SupabaseConstants.eventMenus)
          .insert(payload)
          .select()
          .single();
      return EventMenu.fromJson(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
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
    try {
      await _client
          .from(SupabaseConstants.eventMenus)
          .update({
            'name': name,
            'price_per_person': pricePerPerson,
            'min_guests': minGuests,
            'max_guests': maxGuests,
            'description': description,
            'image_url': imageUrl,
            'event_kind': eventKind,
            'lead_time_months': leadTimeMonths,
            'tasting_available': tastingAvailable,
            'highlight_label': highlightLabel,
            'is_active': isActive,
          })
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> deleteEventMenu(String id) async {
    try {
      await _client.from(SupabaseConstants.eventMenus).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> updateEventRequestQuote({
    required String requestId,
    required String status,
    double? quotedTotal,
    String? adminNotes,
    DateTime? appointmentAt,
    String? appointmentNotes,
  }) async {
    try {
      await _client
          .from(SupabaseConstants.eventRequests)
          .update({
            'status': status,
            if (quotedTotal != null) 'quoted_total': quotedTotal,
            'admin_notes': adminNotes,
            'appointment_at': appointmentAt?.toIso8601String(),
            'appointment_notes': appointmentNotes,
          })
          .eq('id', requestId);
      _sendCateringNotification(requestId: requestId, status: status);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ────────────────────────────────── ORDER CRUD ────────────────────────────

  Future<void> cancelOrderWithReason({
    required String orderId,
    required String reason,
  }) async {
    try {
      // Fetch user_id and order_type for notification
      final row = await _client
          .from(SupabaseConstants.orders)
          .select('user_id, order_type')
          .eq('id', orderId)
          .single();

      await _client
          .from(SupabaseConstants.orders)
          .update({'status': 'cancelled', 'cancellation_reason': reason})
          .eq('id', orderId);

      _sendStatusNotification(
        orderId: orderId,
        newStatus: 'cancelled',
        userId: row['user_id'] as String? ?? '',
        orderType: row['order_type'] as String? ?? '',
      );
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Fire-and-forget: notifica al cliente via Edge Function.
  /// Fire-and-forget: envía email de confirmación con QR al cliente del encargo.
  void _sendEncargoConfirmation(String orderId) {
    _client.functions
        .invoke('send-encargo-confirmation', body: {'orderId': orderId})
        // ignore: avoid_redundant_argument_values
        .catchError((_) => FunctionResponse(data: null, status: 200));
  }

  void _sendCateringNotification({
    required String requestId,
    required String status,
  }) {
    _client.functions
        .invoke(
          'send-catering-notification',
          body: {'requestId': requestId, 'status': status},
        )
        // ignore: avoid_redundant_argument_values
        .catchError((_) => FunctionResponse(data: null, status: 200));
  }

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
        // ignore: avoid_redundant_argument_values
        .catchError((_) => FunctionResponse(data: null, status: 200));
  }
}
