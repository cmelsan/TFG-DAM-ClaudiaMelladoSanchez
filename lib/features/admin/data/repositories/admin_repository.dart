import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_event_request.dart';
import 'package:sabor_de_casa/features/admin/domain/models/admin_user.dart';
import 'package:sabor_de_casa/features/admin/domain/models/business_config_item.dart';
import 'package:sabor_de_casa/features/admin/domain/models/schedule_entry.dart';
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
      await _client
          .from(SupabaseConstants.orders)
          .update({'status': status})
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
          .select()
          .order('created_at', ascending: false);
      return data.map(AdminEventRequest.fromJson).toList();
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
}
