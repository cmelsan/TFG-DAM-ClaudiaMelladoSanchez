import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/auth/domain/models/user_profile.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profile_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
ProfileRepository profileRepository(ProfileRepositoryRef ref) {
  return ProfileRepository(ref.watch(supabaseClientProvider));
}

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<UserProfile> getMyProfile() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(message: 'No hay sesión activa');
      }

      final data = await _client
          .from(SupabaseConstants.profiles)
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(data);
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<UserProfile> updateMyProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(message: 'No hay sesión activa');
      }

      await _client
          .from(SupabaseConstants.profiles)
          .update({
            'full_name': fullName.trim(),
            'phone': (phone?.trim().isEmpty ?? true) ? null : phone?.trim(),
          })
          .eq('id', userId);

      return getMyProfile();
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  // ─────────────────────── Direcciones de entrega ───────────────────────

  Future<List<Map<String, dynamic>>> getAddresses() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(message: 'No hay sesión activa');
      }
      final data = await _client
          .from(SupabaseConstants.addresses)
          .select()
          .eq('user_id', userId)
          .order('is_default', ascending: false)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data as List);
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> addAddress({
    required String label,
    required String street,
    required String city,
    required String postalCode,
    String? notes,
    bool isDefault = false,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(message: 'No hay sesión activa');
      }
      if (isDefault) {
        await _client
            .from(SupabaseConstants.addresses)
            .update({'is_default': false})
            .eq('user_id', userId);
      }
      await _client.from(SupabaseConstants.addresses).insert({
        'user_id': userId,
        'label': label.trim(),
        'street': street.trim(),
        'city': city.trim(),
        'postal_code': postalCode.trim(),
        if (notes != null && notes.isNotEmpty) 'notes': notes.trim(),
        'is_default': isDefault,
      });
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> deleteAddress(String id) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthFailure(message: 'No hay sesión activa');
      }
      await _client
          .from(SupabaseConstants.addresses)
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } on Failure {
      rethrow;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
