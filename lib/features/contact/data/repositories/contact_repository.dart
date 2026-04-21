import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/constants/supabase_constants.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'contact_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
ContactRepository contactRepository(ContactRepositoryRef ref) {
  return ContactRepository(ref.watch(supabaseClientProvider));
}

class ContactRepository {
  ContactRepository(this._client);

  final SupabaseClient _client;

  Future<void> sendMessage({
    required String name,
    required String email,
    required String subject,
    required String message,
    String? phone,
  }) async {
    try {
      await _client.from(SupabaseConstants.contactMessages).insert({
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone?.trim().isEmpty ?? true ? null : phone?.trim(),
        'subject': subject.trim(),
        'message': message.trim(),
      });
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
