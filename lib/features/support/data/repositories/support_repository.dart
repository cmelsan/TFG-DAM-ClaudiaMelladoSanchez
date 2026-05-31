import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_message.dart';
import 'package:sabor_de_casa/features/support/domain/models/support_thread.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'support_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
SupportRepository supportRepository(SupportRepositoryRef ref) {
  return SupportRepository(ref.watch(supabaseClientProvider));
}

class SupportRepository {
  SupportRepository(this._client);

  final SupabaseClient _client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<List<SupportThread>> getMyThreads() async {
    final userId = currentUserId;
    if (userId == null) return [];
    try {
      final data = await _client
          .from('support_threads')
          .select()
          .eq('user_id', userId)
          .order('last_message_at', ascending: false);
      return data.map(SupportThread.fromSupabaseJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<SupportThread>> getAllThreads() async {
    try {
      final data = await _client
          .from('support_threads')
          .select('*, profiles:user_id(full_name, email)')
          .order('last_message_at', ascending: false);
      return data.map(SupportThread.fromSupabaseJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<List<SupportMessage>> getMessages(String threadId) async {
    try {
      final data = await _client
          .from('support_messages')
          .select()
          .eq('thread_id', threadId)
          .order('created_at');
      return data.map(SupportMessage.fromJson).toList();
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<String> createThread({
    required String subject,
    required String category,
    required String message,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw const AuthFailure(
        message: 'Debes iniciar sesion para abrir un chat.',
      );
    }
    try {
      final thread = await _client
          .from('support_threads')
          .insert({
            'user_id': userId,
            'subject': subject.trim(),
            'category': category,
            'status': 'waiting_admin',
            'last_message': message.trim(),
            'last_message_at': DateTime.now().toIso8601String(),
            'unread_for_admin': 1,
          })
          .select('id')
          .single();
      final threadId = thread['id'] as String;
      await _client.from('support_messages').insert({
        'thread_id': threadId,
        'sender_id': userId,
        'sender_role': 'client',
        'body': message.trim(),
      });
      return threadId;
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      if (e is Failure) rethrow;
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> sendMessage({
    required String threadId,
    required String body,
    required bool asAdmin,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw const AuthFailure(message: 'Debes iniciar sesion para responder.');
    }
    final cleanBody = body.trim();
    try {
      await _client.from('support_messages').insert({
        'thread_id': threadId,
        'sender_id': userId,
        'sender_role': asAdmin ? 'admin' : 'client',
        'body': cleanBody,
      });
      await _client
          .from('support_threads')
          .update({
            'last_message': cleanBody,
            'last_message_at': DateTime.now().toIso8601String(),
            'status': asAdmin ? 'waiting_customer' : 'waiting_admin',
            if (asAdmin) 'unread_for_customer': 1 else 'unread_for_admin': 1,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', threadId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> markRead(String threadId, {required bool asAdmin}) async {
    try {
      await _client
          .from('support_threads')
          .update({
            if (asAdmin) 'unread_for_admin': 0 else 'unread_for_customer': 0,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', threadId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> closeThread(String threadId) async {
    try {
      await _client
          .from('support_threads')
          .update({
            'status': 'closed',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', threadId);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
