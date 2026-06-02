import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sabor_de_casa/core/errors/failures.dart';
import 'package:sabor_de_casa/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'subscription_repository.g.dart';

@riverpod
// ignore: deprecated_member_use_from_same_package, Riverpod 2.x typed Ref
SubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  return SubscriptionRepository(ref.watch(supabaseClientProvider));
}

class SubscriptionRepository {
  SubscriptionRepository(this._client);

  final SupabaseClient _client;

  /// Inserta una nueva suscripción de newsletter o WhatsApp.
  /// [type] debe ser 'email' o 'whatsapp'.
  Future<void> subscribe({
    required String type,
    String? email,
    String? phone,
  }) async {
    try {
      if (type != 'email' || email == null) {
        throw ArgumentError('Solo se permite suscripcion por email');
      }

      final normalizedEmail = email.trim().toLowerCase();

      await _client.from('newsletter_subscribers').insert({
        'email': normalizedEmail,
        'source': 'home',
        'locale': 'es',
        'status': 'active',
      });

      unawaited(
        _client.functions
            .invoke(
              'send-newsletter-welcome',
              body: {
                'email': normalizedEmail,
              },
            )
            .then((_) {}, onError: (_) {}),
      );
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
}
