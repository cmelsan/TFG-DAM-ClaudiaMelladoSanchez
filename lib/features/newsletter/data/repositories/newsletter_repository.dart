import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/features/newsletter/domain/models/newsletter_subscriber.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'newsletter_repository.g.dart';

@Riverpod(keepAlive: true)
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
NewsletterRepository newsletterRepository(NewsletterRepositoryRef ref) {
  return NewsletterRepository(ref.watch(supabaseClientProvider));
}

class NewsletterRepository {
  NewsletterRepository(this._client);

  static const _table = 'newsletter_subscribers';
  final SupabaseClient _client;

  Future<List<NewsletterSubscriber>> list() async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      return data.map(NewsletterSubscriber.fromJson).toList();
    } on PostgrestException catch (e) {
      // Tabla aún no migrada: devuelve lista vacía en lugar de romper.
      if (e.code == 'PGRST205' || e.code == '42P01') return const [];
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  /// Alta pública desde el footer / contacto.
  Future<void> subscribe({
    required String email,
    String? fullName,
    String source = 'web',
    String locale = 'es',
  }) async {
    try {
      await _client.from(_table).insert({
        'email': email.trim().toLowerCase(),
        'full_name': fullName,
        'source': source,
        'locale': locale,
        'status': 'active',
      });
    } on PostgrestException catch (e) {
      // Email duplicado → tratamos como éxito silencioso.
      if (e.code == '23505') return;
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    try {
      await _client
          .from(_table)
          .update({
            'status': status,
            if (status == 'unsubscribed')
              'unsubscribed_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> remove(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
