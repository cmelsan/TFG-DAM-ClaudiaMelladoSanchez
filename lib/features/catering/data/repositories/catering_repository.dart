import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/catering/domain/models/event_menu.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'catering_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
CateringRepository cateringRepository(CateringRepositoryRef ref) {
  return CateringRepository(ref.watch(supabaseClientProvider));
}

class CateringRepository {
  CateringRepository(this._client);

  final SupabaseClient _client;

  Future<List<EventMenu>> getActiveMenus() async {
    try {
      final data = await _client
          .from(SupabaseConstants.eventMenus)
          .select()
          .eq('is_active', true)
          .order('name');

      return data.map(EventMenu.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> sendRequest({
    required String menuId,
    required int guestCount,
    required DateTime eventDate,
    required String location,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthFailure(message: 'No autenticado');
    try {
      await _client.from(SupabaseConstants.eventRequests).insert({
        'user_id': userId,
        'menu_id': menuId,
        'guest_count': guestCount,
        'event_date': eventDate.toIso8601String(),
        'location': location,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getMyRequests() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthFailure(message: 'No autenticado');
    try {
      final data = await _client
          .from(SupabaseConstants.eventRequests)
          .select('*, ${SupabaseConstants.eventMenus}(name, price_per_person)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
