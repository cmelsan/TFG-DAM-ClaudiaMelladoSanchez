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
      // Tabla aun no migrada: devuelve lista vacia en lugar de romper.
      if (e.code == 'PGRST205' || e.code == '42P01') return const [];
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  Future<void> subscribe({
    required String email,
    String? fullName,
    String source = 'web',
    String locale = 'es',
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      await _client.from(_table).insert({
        'email': normalizedEmail,
        'full_name': fullName,
        'source': source,
        'locale': locale,
        'status': 'active',
      });

      _sendWelcomeEmail(email: normalizedEmail, fullName: fullName);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const DatabaseFailure(
          message: 'Este correo ya esta suscrito',
          code: 'duplicate_email',
        );
      }
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }

  void _sendWelcomeEmail({required String email, String? fullName}) {
    _client.functions
        .invoke(
          'send-newsletter-welcome',
          body: {
            'email': email,
            'full_name': fullName,
          },
        )
        .then((_) {}, onError: (_) {});
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

  Future<int> sendCampaign({
    required String subject,
    required String body,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'send-newsletter-campaign',
        body: {
          'subject': subject,
          'body': body,
        },
      );

      if (response.status != 200) {
        throw const UnexpectedFailure(message: 'Error enviando campana');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final sent = data['sentCount'];
        if (sent is int) return sent;
        if (sent is num) return sent.toInt();
      }
      return 0;
    } on FunctionException catch (e) {
      throw UnexpectedFailure(
        message: e.details?.toString() ?? e.reasonPhrase ?? 'Error en funcion',
      );
    } on PostgrestException catch (e) {
      throw DatabaseFailure(message: e.message, code: e.code);
    } catch (e) {
      throw UnexpectedFailure(message: e.toString());
    }
  }
}
